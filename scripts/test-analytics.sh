#!/bin/bash
# Verifies CF Web Analytics beacon is present in all rendered pages
# Requires: npm run build to have been run (or run this script which builds first)

set -e

DIST_DIR="./dist"
PAGES=("index.html" "about/index.html" "features/index.html" "contact/index.html")
FAILURES=0

echo "--- Building site ---"
npm run build
echo ""

echo "--- Verifying CF Web Analytics beacon in built HTML ---"
echo ""

for page in "${PAGES[@]}"; do
  FILE="$DIST_DIR/$page"
  if [ ! -f "$FILE" ]; then
    echo "FAIL: $FILE not found"
    FAILURES=$((FAILURES + 1))
    continue
  fi
  if grep -q "static.cloudflareinsights.com/beacon.min.js" "$FILE"; then
    echo "PASS: beacon present in $page"
  else
    echo "FAIL: beacon NOT found in $page"
    FAILURES=$((FAILURES + 1))
  fi
done

echo ""

echo "--- Verifying data-track-event attributes in built HTML ---"
echo ""

# Check pages that should have CTA tracking attributes
CTA_PAGES=("index.html" "about/index.html" "features/index.html")
for page in "${CTA_PAGES[@]}"; do
  FILE="$DIST_DIR/$page"
  if [ ! -f "$FILE" ]; then
    continue
  fi
  if grep -q "data-track-event" "$FILE"; then
    echo "PASS: CTA tracking attributes present in $page"
  else
    echo "FAIL: CTA tracking attributes NOT found in $page"
    FAILURES=$((FAILURES + 1))
  fi
done

echo ""
if [ $FAILURES -eq 0 ]; then
  echo "All checks passed. ANLX-01 satisfied."
  exit 0
else
  echo "$FAILURES check(s) failed."
  exit 1
fi
