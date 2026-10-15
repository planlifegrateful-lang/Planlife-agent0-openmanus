#!/usr/bin/env bash
# End-to-end local verification: content → video (zero API)
# Usage: ./scripts/e2e-local.sh [topic] [platform]
set -euo pipefail

CONTENT_URL="${CONTENT_URL:-http://localhost:8100}"
VIDEO_URL="${VIDEO_URL:-http://localhost:8000}"
TOPIC="${1:-morning routine tips}"
PLATFORM="${2:-tiktok}"

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'

ok()   { echo -e "${GREEN}✓${NC} $*"; }
fail() { echo -e "${RED}✗${NC} $*"; exit 1; }
info() { echo -e "${CYAN}→${NC} $*"; }

echo -e "${BOLD}========================================${NC}"
echo -e "${BOLD} E2E Local Pipeline Test${NC}"
echo -e " Topic: ${TOPIC} | Platform: ${PLATFORM}"
echo -e "${BOLD}========================================${NC}"

echo ""
info "[1/4] Checking content-agent (${CONTENT_URL})..."
if ! curl -sf --max-time 3 "${CONTENT_URL}/health" > /dev/null 2>&1; then
  fail "content-agent not up on ${CONTENT_URL}"
  echo "  → Start it: cd ../ai-ugc && docker compose up --build -d   (or ./run.sh)"
fi
ok "content-agent healthy"

echo ""
info "[2/4] Checking video webhook (${VIDEO_URL})..."
if ! curl -sf --max-time 3 "${VIDEO_URL}/health" > /dev/null 2>&1; then
  fail "video pipeline not up on ${VIDEO_URL}"
  echo "  → Start it: docker compose up --build -d   (in this repo)"
  echo "  → Or native: bash OpenManus/start-native.sh"
fi
ok "video webhook healthy"

echo ""
info "[3/4] Generating content..."
CONTENT_JSON=$(curl -s -X POST "${CONTENT_URL}/generate" \
  -H "Content-Type: application/json" \
  -d "{\"topic\": \"${TOPIC}\", \"platform\": \"${PLATFORM}\"}" || true)

if [ -z "$CONTENT_JSON" ]; then
  fail "empty response from content-agent /generate"
fi

if echo "$CONTENT_JSON" | grep -q '"status": "error"'; then
  fail "content generate error"
  echo "$CONTENT_JSON"
fi

if command -v jq >/dev/null 2>&1; then
  echo "$CONTENT_JSON" | jq '.content | {hook, script, cta, hashtags}' 2>/dev/null || echo "$CONTENT_JSON"
  SCRIPT=$(echo "$CONTENT_JSON" | jq -r '.content.script // empty')
  TITLE=$(echo "$CONTENT_JSON" | jq -r '.content.topic // .content.title // empty')
  CAPTION=$(echo "$CONTENT_JSON" | jq -r '.content.caption // empty')
else
  echo "$CONTENT_JSON"
  SCRIPT="Create something great about ${TOPIC} today."
  TITLE="${TOPIC}"
  CAPTION=""
fi

[[ -z "$SCRIPT" || "$SCRIPT" == "null" ]] && SCRIPT="Create something great about ${TOPIC} today."
[[ -z "$TITLE"  || "$TITLE"  == "null" ]] && TITLE="${TOPIC}"

ok "Content generated (script length: ${#SCRIPT} chars)"

echo ""
info "[4/4] Building video (15–90s depending on machine)..."
START_TS=$(date +%s)
VIDEO_JSON=$(curl -s -X POST "${VIDEO_URL}/webhook" \
  -H "Content-Type: application/json" \
  -d "{\"title\": \"${TITLE}\", \"script\": \"${SCRIPT}\"}" || true)
END_TS=$(date +%s)
DURATION=$((END_TS - START_TS))

if [ -z "$VIDEO_JSON" ]; then
  fail "empty response from video webhook"
fi

if command -v jq >/dev/null 2>&1; then
  echo "$VIDEO_JSON" | jq . 2>/dev/null || echo "$VIDEO_JSON"
  STATUS=$(echo "$VIDEO_JSON" | jq -r '.status // empty')
  FILENAME=$(echo "$VIDEO_JSON" | jq -r '.filename // .file // empty')
else
  echo "$VIDEO_JSON"
  STATUS=""
  FILENAME=""
fi

echo ""
echo -e "${BOLD}========================================${NC}"
if [[ "$STATUS" == "ok" ]] || echo "$VIDEO_JSON" | grep -q '"status": "ok"'; then
  echo -e "${GREEN}${BOLD} SUCCESS${NC}  (${DURATION}s)"
  [[ -n "$FILENAME" && "$FILENAME" != "null" ]] && echo -e " File: ${FILENAME}"
  echo ""
  echo "Pull videos from Docker volume:"
  echo "  mkdir -p out && docker run --rm -v planlife-agent0-openmanus_video-output:/data -v \$(pwd)/out:/out alpine cp -r /data/. /out/"
  echo "Or check native output: ls -la ./output/"
else
  echo -e "${YELLOW} CHECK OUTPUT ABOVE${NC} (status may still be ok without jq)"
  echo "$VIDEO_JSON"
fi
echo -e "${BOLD}========================================${NC}"
