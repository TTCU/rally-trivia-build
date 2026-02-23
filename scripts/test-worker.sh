#!/bin/bash
# Test Worker /api/contact endpoint
# Requires: wrangler dev running on port 8787
# Note: Turnstile verification calls Cloudflare's API, so test tokens
# will fail unless TURNSTILE_SECRET_KEY is set to the Turnstile test secret key:
# 1x0000000000000000000000000000000AA (always passes)

BASE_URL="${1:-http://localhost:8787}"

# Test 1: POST with valid payload (expects Turnstile test secret configured)
echo "--- Test 1: POST /api/contact with valid payload ---"
RESPONSE=$(curl -s -X POST "$BASE_URL/api/contact" \
  -H "Content-Type: application/json" \
  -d '{"Name": "Test User", "Email": "test@example.com", "turnstileToken": "test-token"}')
echo "Response: $RESPONSE"
if echo "$RESPONSE" | grep -q '"ok"'; then
  echo "PASS: POST /api/contact returned a valid JSON response"
else
  echo "FAIL: unexpected response from POST /api/contact"
  exit 1
fi

# Test 2: GET returns 405
echo ""
echo "--- Test 2: GET /api/contact ---"
RESPONSE_GET=$(curl -s "$BASE_URL/api/contact")
echo "Response: $RESPONSE_GET"
if echo "$RESPONSE_GET" | grep -q '"Method not allowed"'; then
  echo "PASS: GET /api/contact returns 405"
else
  echo "FAIL: GET /api/contact did not return 405"
  exit 1
fi

# Test 3: Unknown API path returns 404
echo ""
echo "--- Test 3: GET /api/unknown ---"
RESPONSE_404=$(curl -s "$BASE_URL/api/unknown")
echo "Response: $RESPONSE_404"
if echo "$RESPONSE_404" | grep -q '"Not found"'; then
  echo "PASS: GET /api/unknown returns 404"
else
  echo "FAIL: GET /api/unknown did not return 404"
  exit 1
fi

echo ""
echo "All tests passed."
