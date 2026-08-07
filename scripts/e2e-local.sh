#!/usr/bin/env bash
# End-to-end local verification: content → video (zero API)
# Usage: ./scripts/e2e-local.sh [topic] [platform]
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
echo "[1/4] Checking content-agent ($CONTENT_URL)..."
if ! curl -sf "$CONTENT_URL/health" > /dev/null; then
  echo "FAIL: content-agent not up"
  echo "  → cd path/to/ai-ugc && docker compose up --build -d"
  exit 1
fi
echo "OK"

echo ""
echo "[2/4] Checking video webhook ($VIDEO_URL)..."
if ! curl -sf "$VIDEO_URL/health" > /dev/null; then
  echo "FAIL: video pipeline not up"
  echo "  → docker compose up --build -d  (in this repo)"
  exit 1
fi
echo "OK"

echo ""
echo "[3/4] Generating content..."
CONTENT_JSON=$(curl -s -X POST "$CONTENT_URL/generate" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"$TOPIC\", \"platform\": \"$PLATFORM\"}")

if echo "$CONTENT_JSON" | grep -q '"status": "error"'; then
  echo "FAIL: content generate error"
  echo "$CONTENT_JSON"
  exit 1
fi

if command -v jq >/dev/null 2>&1; then
  echo "$CONTENT_JSON" | jq '.content | {hook, script, cta, hashtags}'
  SCRIPT=$(echo "$CONTENT_JSON" | jq -r '.content.script // empty')
  TITLE=$(echo "$CONTENT_JSON" | jq -r '.content.topic // empty')
  CAPTION=$(echo "$CONTENT_JSON" | jq -r '.content.caption // empty')
else
  echo "$CONTENT_JSON"
  SCRIPT="Create something great about $TOPIC today."
  TITLE="$TOPIC"
  CAPTION=""
fi

if [ -z "$SCRIPT" ] || [ "$SCRIPT" = "null" ]; then
  SCRIPT="Create something great about $TOPIC today."
fi
if [ -z "$TITLE" ] || [ "$TITLE" = "null" ]; then
  TITLE="$TOPIC"
fi

echo ""
echo "[4/4] Building video (15–90s depending on machine)..."
VIDEO_JSON=$(curl -s -X POST "$VIDEO_URL/webhook" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"$TITLE\", \"script\": \"$SCRIPT\"}")

if command -v jq >/dev/null 2>&1; then
  echo "$VIDEO_JSON" | jq .
  STATUS=$(echo "$VIDEO_JSON" | jq -r '.status // empty')
  FILENAME=$(echo "$VIDEO_JSON" | jq -r '.filename // empty')
else
  echo "$VIDEO_JSON"
  STATUS=""
  FILENAME=""
fi

echo ""
echo "========================================"
if [ "$STATUS" = "ok" ] || echo "$VIDEO_JSON" | grep -q '"status": "ok"'; then
  echo " SUCCESS"
  [ -n "$FILENAME" ] && echo " File: $FILENAME"
  echo " Pull videos:"
  echo "   mkdir -p out && docker run --rm -v planlife-agent0-openmanus_video-output:/data -v \$(pwd)/out:/out alpine cp -r /data/. /out/"
else
  echo " CHECK OUTPUT ABOVE (status may still be ok without jq)"
fi
echo "========================================"
