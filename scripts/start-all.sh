#!/usr/bin/env bash
# One-command start of the full Planlife local stack
# Usage: ./scripts/start-all.sh [--native]
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "${CYAN}→${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_UGC_DIR="${AI_UGC_DIR:-$(dirname "$ROOT")/ai-ugc}"
NATIVE=false
[[ "${1:-}" == "--native" ]] && NATIVE=true

echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "${BOLD} Starting Planlife Full Stack${NC}"
echo -e "${BOLD}══════════════════════════════════════${NC}"

# ── content-agent (ai-ugc) ─────────────────────────────
if [ -d "$AI_UGC_DIR" ]; then
  info "Starting content-agent from ${AI_UGC_DIR}..."
  if [ -f "$AI_UGC_DIR/docker-compose.yml" ]; then
    (cd "$AI_UGC_DIR" && docker compose up --build -d)
    ok "content-agent (docker) started → :8100"
  elif [ -f "$AI_UGC_DIR/run.sh" ]; then
    (cd "$AI_UGC_DIR" && bash run.sh &) 
    ok "content-agent (run.sh) started → :8100"
  else
    echo -e "${RED}No docker-compose.yml or run.sh found in ai-ugc${NC}"
  fi
else
  echo -e "${RED}ai-ugc not found at ${AI_UGC_DIR}${NC}"
  echo "  Clone it: git clone https://github.com/planlifegrateful-lang/ai-ugc.git ../ai-ugc"
  echo "  Or set AI_UGC_DIR=/path/to/ai-ugc"
fi

# ── this repo (video pipeline) ─────────────────────────
if $NATIVE; then
  info "Starting native video pipeline..."
  if [ -f "$ROOT/OpenManus/start-native.sh" ]; then
    bash "$ROOT/OpenManus/start-native.sh" &
    ok "native pipeline started"
  else
    echo -e "${RED}OpenManus/start-native.sh not found${NC}"
  fi
else
  info "Starting Docker video pipeline..."
  (cd "$ROOT" && docker compose up --build -d)
  ok "video-builder :8001 + webhook-listener :8000 + openmanus :8002 started"
fi

echo ""
info "Waiting 8s for healthchecks..."
sleep 8

echo ""
bash "$ROOT/scripts/check-stack.sh"

echo ""
ok "Stack start complete."
echo "  E2E test:  ./scripts/e2e-local.sh \"your topic\""
echo "  Logs:      ./scripts/logs.sh"
