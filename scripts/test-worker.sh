#!/bin/bash
# Test Worker stub endpoint
# Requires: wrangler dev running on port 8787

RESPONSE=$(curl -s -X POST http://localhost:8787/api/contact \
  -H "Content-Type: application/json" \
  -d '{}')
echo "Response: $RESPONSE"
if echo "$RESPONSE" | grep -q '"ok":true'; then
  echo "PASS: POST /api/contact returns { ok: true }"
else
  echo "FAIL: unexpected response from POST /api/contact"
  exit 1
fi

# Test 405 for GET
RESPONSE_GET=$(curl -s http://localhost:8787/api/contact)
echo "GET Response: $RESPONSE_GET"
if echo "$RESPONSE_GET" | grep -q '"Method not allowed"'; then
  echo "PASS: GET /api/contact returns 405"
else
  echo "FAIL: GET /api/contact did not return 405"
  exit 1
fi

echo ""
echo "All tests passed."
