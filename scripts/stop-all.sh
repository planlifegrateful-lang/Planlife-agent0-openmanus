#!/usr/bin/env bash
# Clean stop of the full Planlife local stack
# Usage: ./scripts/stop-all.sh
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "${CYAN}→${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_UGC_DIR="${AI_UGC_DIR:-$(dirname "$ROOT")/ai-ugc}"

echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "${BOLD} Stopping Planlife Full Stack${NC}"
echo -e "${BOLD}══════════════════════════════════════${NC}"

# Docker services in this repo
if command -v docker >/dev/null 2>&1; then
  info "Stopping Docker services in this repo..."
  (cd "$ROOT" && docker compose down --remove-orphans 2>/dev/null) || true
  ok "this-repo containers stopped"

  if [ -d "$AI_UGC_DIR" ] && [ -f "$AI_UGC_DIR/docker-compose.yml" ]; then
    info "Stopping ai-ugc containers..."
    (cd "$AI_UGC_DIR" && docker compose down --remove-orphans 2>/dev/null) || true
    ok "ai-ugc containers stopped"
  fi
fi

# Kill any native processes on known ports
info "Killing native processes on known ports (if any)..."
for port in 8000 8001 8002 8100 8200 5678; do
  if command -v lsof >/dev/null 2>&1; then
    pids=$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)
    if [ -n "$pids" ]; then
      echo "$pids" | xargs -r kill -9 2>/dev/null || true
      ok "killed process(es) on port $port"
    fi
  elif command -v fuser >/dev/null 2>&1; then
    fuser -k "${port}/tcp" 2>/dev/null || true
  fi
done

ok "Stack stopped."
