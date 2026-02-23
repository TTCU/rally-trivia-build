#!/bin/bash
# Test Worker /api/contact endpoint
# Requires: wrangler dev running on port 8787

# Test 1: POST with valid payload and test Turnstile token
RESPONSE=$(curl -s -X POST http://localhost:8787/api/contact \
  -H "Content-Type: application/json" \
  -d '{"Name": "Test User", "Email": "test@example.com", "turnstileToken": "test-token"}')
echo "Response: $RESPONSE"
if echo "$RESPONSE" | grep -q '"ok":true'; then
  echo "PASS: POST /api/contact with valid payload returns { ok: true }"
else
  echo "FAIL: unexpected response from POST /api/contact with valid payload"
  exit 1
fi

# Test 2: GET returns 405
RESPONSE_GET=$(curl -s http://localhost:8787/api/contact)
echo "GET Response: $RESPONSE_GET"
if echo "$RESPONSE_GET" | grep -q '"Method not allowed"'; then
  echo "PASS: GET /api/contact returns 405"
else
  echo "FAIL: GET /api/contact did not return 405"
  exit 1
fi

# Test 3: POST missing Turnstile token returns { ok: false }
RESPONSE_NO_TOKEN=$(curl -s -X POST http://localhost:8787/api/contact \
  -H "Content-Type: application/json" \
  -d '{"Name": "Test", "Email": "test@example.com"}')
echo "No-token Response: $RESPONSE_NO_TOKEN"
if echo "$RESPONSE_NO_TOKEN" | grep -q '"ok":false'; then
  echo "PASS: POST without turnstileToken returns { ok: false }"
else
  echo "FAIL: POST without turnstileToken did not return { ok: false }"
  exit 1
fi

echo ""
echo "All tests passed."
