#!/usr/bin/env bash
# Tail logs for the Planlife stack
# Usage: ./scripts/logs.sh [service]
#   service = video-builder | webhook-listener | openmanus | n8n | all (default)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SERVICE="${1:-all}"

if ! command -v docker >/dev/null 2>&1; then
  echo "docker not found — cannot tail container logs"
  echo "Native mode? Check ./output/ and any *.log files in the repo root."
  exit 1
fi

case "$SERVICE" in
  video-builder|webhook-listener|openmanus|n8n)
    echo "Tailing ${SERVICE} (Ctrl+C to stop)..."
    docker logs -f --tail 100 "$SERVICE" 2>&1
    ;;
  all|*)
    echo "Tailing all Planlife containers (Ctrl+C to stop)..."
    docker compose -f "$ROOT/docker-compose.yml" logs -f --tail 50 2>&1
    ;;
esac
