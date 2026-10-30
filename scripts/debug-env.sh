#!/usr/bin/env bash
# Redacted stack environment summary for support / debugging
# Usage: ./scripts/debug-env.sh
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

echo "══════════════════════════════════════"
echo " Planlife Redacted Environment Summary"
echo " $(date -u +%Y-%m-%dT%H:%M:%SZ)"
echo "══════════════════════════════════════"

echo ""
echo "[System]"
uname -a 2>/dev/null || true
echo "Shell: ${SHELL:-unknown}"
echo "PWD: $(pwd)"
echo "ROOT: $ROOT"

echo ""
echo "[Tools]"
for cmd in docker docker-compose curl jq python3 ffmpeg espeak-ng ss lsof; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "  ✓ $cmd  → $(command -v "$cmd")"
  else
    echo "  ✗ $cmd  (missing)"
  fi
done

echo ""
echo "[Docker]"
if command -v docker >/dev/null 2>&1; then
  docker version --format 'Client: {{.Client.Version}}  Server: {{.Server.Version}}' 2>/dev/null || docker version 2>/dev/null | head -5
  echo ""
  echo "Containers:"
  docker ps -a --filter name=video-builder --filter name=webhook-listener --filter name=openmanus --filter name=n8n --format 'table {{.Names}}\t{{.Status}}\t{{.Ports}}' 2>/dev/null || true
else
  echo "  docker not available"
fi

echo ""
echo "[Ports in use]"
if command -v ss >/dev/null 2>&1; then
  ss -tlnp 2>/dev/null | grep -E ':(8000|8001|8002|8100|8200|5678)\s' || echo "  (none of the Planlife ports)"
elif command -v lsof >/dev/null 2>&1; then
  lsof -iTCP -sTCP:LISTEN 2>/dev/null | grep -E ':(8000|8001|8002|8100|8200|5678)\s' || echo "  (none)"
else
  echo "  no ss/lsof"
fi

echo ""
echo "[Env vars relevant to stack (secret values redacted)]"
found=false
while IFS='=' read -r name value; do
  case "$name" in
    AI_UGC_DIR|VIDEO_BUILDER_PORT|WEBHOOK_LISTENER_PORT|OPENMANUS_PORT|N8N_HOST|N8N_PORT|N8N_PROTOCOL)
      printf '  %s=%s\n' "$name" "$value"
      found=true
      ;;
    N8N_*|*_URL|*_KEY|*_TOKEN|*_SECRET|*_PASSWORD|*_CREDENTIAL*|*_AUTH*)
      printf '  %s=[REDACTED]\n' "$name"
      found=true
      ;;
  esac
done < <(env | sort)
$found || echo "  (none set)"

echo ""
echo "[Repo files]"
ls -la "$ROOT/scripts/" 2>/dev/null || true
ls -la "$ROOT/docker-compose.yml" "$ROOT/.env" "$ROOT/.env.example" 2>/dev/null || true

echo ""
echo "[Quick health]"
for url in http://localhost:8100/health http://localhost:8000/health http://localhost:8001/health; do
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 2 "$url" 2>/dev/null || echo "000")
  echo "  $url → HTTP $code"
done

echo ""
echo "══════════════════════════════════════"
echo "End of redacted summary. Share this output when asking for help."
