#!/usr/bin/env bash
# Safely stop the Planlife local stack without removing containers or killing unrelated processes.
# Usage: ./scripts/stop-all.sh
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
info() { echo -e "${CYAN}→${NC} $*"; }
ok()   { echo -e "${GREEN}✓${NC} $*"; }
warn() { echo -e "${YELLOW}! ${NC} $*"; }

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_UGC_DIR="${AI_UGC_DIR:-$(dirname "$ROOT")/ai-ugc}"
if [ -d "$AI_UGC_DIR" ]; then
  AI_UGC_DIR="$(cd "$AI_UGC_DIR" && pwd)"
else
  AI_UGC_DIR=""
fi

echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "${BOLD} Stopping Planlife Full Stack${NC}"
echo -e "${BOLD}══════════════════════════════════════${NC}"

# Stop only this project's Compose services. Keep containers, networks, and volumes intact.
if command -v docker >/dev/null 2>&1; then
  if [ -f "$ROOT/docker-compose.yml" ]; then
    info "Stopping Docker services in this repo (containers and volumes are preserved)..."
    (cd "$ROOT" && docker compose stop) || warn "Could not stop this repo's Docker services."
  fi

  if [ -n "$AI_UGC_DIR" ] && [ -f "$AI_UGC_DIR/docker-compose.yml" ]; then
    info "Stopping ai-ugc Docker services (containers and volumes are preserved)..."
    (cd "$AI_UGC_DIR" && docker compose stop) || warn "Could not stop ai-ugc Docker services."
  fi
else
  warn "Docker not found; skipping Compose services."
fi

# Native processes are stopped only when their cwd or command path identifies them as
# belonging to one of the two known project directories. Unknown listeners are left alone.
stop_owned_pid() {
  local pid="$1"
  local process_cwd process_cmd owned=false

  [[ "$pid" =~ ^[0-9]+$ ]] || return 0
  kill -0 "$pid" 2>/dev/null || return 0

  process_cwd="$(readlink -f "/proc/$pid/cwd" 2>/dev/null || true)"
  process_cmd="$(ps -p "$pid" -o args= 2>/dev/null || true)"

  case "$process_cwd" in
    "$ROOT"|"$ROOT"/*) owned=true ;;
  esac
  if [ -n "$AI_UGC_DIR" ]; then
    case "$process_cwd" in
      "$AI_UGC_DIR"|"$AI_UGC_DIR"/*) owned=true ;;
    esac
  fi
  case "$process_cmd" in
    *"$ROOT"*) owned=true ;;
  esac
  if [ -n "$AI_UGC_DIR" ]; then
    case "$process_cmd" in
      *"$AI_UGC_DIR"*) owned=true ;;
    esac
  fi

  if [ "$owned" != true ]; then
    warn "Leaving PID $pid running; it listens on a Planlife port but is not identified as a Planlife process."
    return 0
  fi

  info "Sending SIGTERM to Planlife process $pid..."
  kill -TERM "$pid" 2>/dev/null || return 0
  for _ in 1 2 3 4 5; do
    kill -0 "$pid" 2>/dev/null || { ok "stopped process $pid"; return 0; }
    sleep 1
  done
  warn "Process $pid did not exit after SIGTERM; left running rather than force-killing it."
}

info "Checking native listeners on known ports..."
if command -v lsof >/dev/null 2>&1; then
  for port in 8000 8001 8002 8100 8200 5678; do
    pids="$(lsof -tiTCP:"$port" -sTCP:LISTEN 2>/dev/null || true)"
    if [ -n "$pids" ]; then
      while IFS= read -r pid; do
        stop_owned_pid "$pid"
      done <<< "$pids"
    fi
  done
else
  warn "lsof not found; native listeners were not stopped because ownership could not be checked safely."
fi

ok "Stop request complete. Unrecognized processes were left running; Docker containers and volumes were preserved."
