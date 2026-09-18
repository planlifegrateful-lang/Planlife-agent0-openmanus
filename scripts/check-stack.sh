#!/usr/bin/env bash
# Live stack health: ports, Docker containers, HTTP health endpoints
# Usage: ./scripts/check-stack.sh
set -euo pipefail

RED='\033[0;31m'; GREEN='\033[0;32m'; YELLOW='\033[1;33m'; CYAN='\033[0;36m'; BOLD='\033[1m'; NC='\033[0m'
ok()   { echo -e "  ${GREEN}✓${NC} $*"; }
fail() { echo -e "  ${RED}✗${NC} $*"; }
warn() { echo -e "  ${YELLOW}!${NC} $*"; }
info() { echo -e "${CYAN}$*${NC}"; }

CONTENT_URL="${CONTENT_URL:-http://localhost:8100}"
VIDEO_URL="${VIDEO_URL:-http://localhost:8000}"
BUILDER_URL="${BUILDER_URL:-http://localhost:8001}"
OPENMANUS_URL="${OPENMANUS_URL:-http://localhost:8002}"
OTTO_URL="${OTTO_URL:-http://localhost:8200}"
N8N_URL="${N8N_URL:-http://localhost:5678}"

echo -e "${BOLD}══════════════════════════════════════${NC}"
echo -e "${BOLD} Planlife Stack Health Check${NC}"
echo -e "${BOLD}══════════════════════════════════════${NC}"

# ── Ports ──────────────────────────────────────────────
echo ""
info "[Ports]"
check_port() {
  local port=$1 name=$2
  if command -v ss >/dev/null 2>&1; then
    if ss -tlnp 2>/dev/null | grep -q ":${port} "; then
      ok "port ${port} listening (${name})"
    else
      fail "port ${port} NOT listening (${name})"
    fi
  elif command -v lsof >/dev/null 2>&1; then
    if lsof -iTCP:"${port}" -sTCP:LISTEN >/dev/null 2>&1; then
      ok "port ${port} listening (${name})"
    else
      fail "port ${port} NOT listening (${name})"
    fi
  else
    warn "cannot check ports (no ss/lsof) — ${name}:${port}"
  fi
}

check_port 8100 "content-agent (ai-ugc)"
check_port 8000 "webhook-listener"
check_port 8001 "video-builder"
check_port 8002 "openmanus"
check_port 8200 "otto (optional)"
check_port 5678 "n8n (optional)"

# ── Docker containers ──────────────────────────────────
echo ""
info "[Docker containers]"
if command -v docker >/dev/null 2>&1; then
  for c in video-builder webhook-listener openmanus n8n; do
    if docker ps --format '{{.Names}}' 2>/dev/null | grep -q "^${c}$"; then
      status=$(docker inspect -f '{{.State.Status}}' "$c" 2>/dev/null || echo unknown)
      health=$(docker inspect -f '{{if .State.Health}}{{.State.Health.Status}}{{else}}no-healthcheck{{end}}' "$c" 2>/dev/null || echo unknown)
      ok "${c}  status=${status}  health=${health}"
    else
      fail "${c}  not running"
    fi
  done
else
  warn "docker not available"
fi

# ── HTTP health endpoints ──────────────────────────────
echo ""
info "[HTTP health]"
probe() {
  local url=$1 name=$2
  if curl -sf --max-time 2 "${url}/health" >/dev/null 2>&1 || curl -sf --max-time 2 "${url}" >/dev/null 2>&1; then
    ok "${name}  ${url}"
  else
    fail "${name}  ${url}  (no response)"
  fi
}

probe "$CONTENT_URL"   "content-agent"
probe "$VIDEO_URL"     "webhook-listener"
probe "$BUILDER_URL"   "video-builder"
probe "$OPENMANUS_URL" "openmanus"
probe "$OTTO_URL"      "otto (optional)"
probe "$N8N_URL"       "n8n (optional)"

echo ""
echo -e "${BOLD}══════════════════════════════════════${NC}"
echo "Run full E2E:  ./scripts/e2e-local.sh"
echo "Start stack:   ./scripts/start-all.sh"
echo "Stop stack:    ./scripts/stop-all.sh"
echo -e "${BOLD}══════════════════════════════════════${NC}"
