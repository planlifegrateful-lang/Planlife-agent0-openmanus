#!/usr/bin/env bash
# End-to-end local verification: content → video (zero API)
set -euo pipefail

CONTENT_URL="${CONTENT_URL:-http://localhost:8100}"
VIDEO_URL="${VIDEO_URL:-http://localhost:8000}"
TOPIC="${1:-morning routine tips}"
PLATFORM="${2:-tiktok}"

echo "========================================"
echo " E2E Local Pipeline Test"
echo " Topic: $TOPIC | Platform: $PLATFORM"
echo "========================================"

echo ""
echo "[1/4] Checking content-agent..."
if ! curl -sf "$CONTENT_URL/health" > /dev/null; then
  echo "FAIL: content-agent not up at $CONTENT_URL"
  echo "Start it: cd ../ai-ugc && docker compose up --build -d"
  exit 1
fi
echo "OK"

echo ""
echo "[2/4] Checking video pipeline..."
if ! curl -sf "$VIDEO_URL/health" > /dev/null; then
  echo "FAIL: video webhook not up at $VIDEO_URL"
  echo "Start it: docker compose up --build -d  (in this repo)"
  exit 1
fi
echo "OK"

echo ""
echo "[3/4] Generating content..."
CONTENT_JSON=$(curl -s -X POST "$CONTENT_URL/generate" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"$TOPIC\", \"platform\": \"$PLATFORM\"}")

if command -v jq >/dev/null 2>&1; then
  echo "$CONTENT_JSON" | jq '.content | {hook, script, cta}'
  SCRIPT=$(echo "$CONTENT_JSON" | jq -r '.content.script')
  TITLE=$(echo "$CONTENT_JSON" | jq -r '.content.topic')
else
  echo "$CONTENT_JSON"
  SCRIPT="Create something great about $TOPIC today."
  TITLE="$TOPIC"
fi

echo ""
echo "[4/4] Building video (this can take 15-60s)..."
VIDEO_JSON=$(curl -s -X POST "$VIDEO_URL/webhook" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"$TITLE\", \"script\": \"$SCRIPT\"}")

if command -v jq >/dev/null 2>&1; then
  echo "$VIDEO_JSON" | jq .
else
  echo "$VIDEO_JSON"
fi

echo ""
echo "========================================"
echo " E2E complete. Check video-output volume."
echo " docker volume ls | grep video"
echo "========================================"
