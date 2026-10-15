#!/usr/bin/env bash
# Ultra-fast individual service probes (no content generation)
# Usage: ./scripts/smoke.sh
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "${GREEN}✓${NC} $*"; }
fail() { echo -e "${RED}✗${NC} $*"; FAILS=$((FAILS+1)); }

FAILS=0
CONTENT_URL="${CONTENT_URL:-http://localhost:8100}"
VIDEO_URL="${VIDEO_URL:-http://localhost:8000}"
BUILDER_URL="${BUILDER_URL:-http://localhost:8001}"

echo -e "${BOLD}Smoke probes${NC}"

# content-agent
if curl -sf --max-time 2 "${CONTENT_URL}/health" >/dev/null 2>&1; then
  ok "content-agent /health"
else
  fail "content-agent /health"
fi

# webhook
if curl -sf --max-time 2 "${VIDEO_URL}/health" >/dev/null 2>&1; then
  ok "webhook-listener /health"
else
  fail "webhook-listener /health"
fi

# video-builder
if curl -sf --max-time 2 "${BUILDER_URL}/health" >/dev/null 2>&1; then
  ok "video-builder /health"
else
  fail "video-builder /health"
fi

echo ""
if [ "$FAILS" -eq 0 ]; then
  echo -e "${GREEN}${BOLD}All smoke probes passed${NC}"
  exit 0
else
  echo -e "${RED}${BOLD}${FAILS} probe(s) failed${NC}"
  exit 1
fi
