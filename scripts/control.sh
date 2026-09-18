#!/usr/bin/env bash
# Single entrypoint for the entire Planlife local control plane
# Usage: ./scripts/control.sh <command> [args]
#
# Commands:
#   start [--native]   Start full stack
#   stop               Stop full stack
#   check              Live health matrix (ports + Docker + HTTP)
#   smoke              Ultra-fast probes
#   e2e [topic] [plat] Full content → video test
#   logs [service]     Tail logs
#   debug              Environment dump
#   help               This help
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CMD="${1:-help}"
shift || true

case "$CMD" in
  start)  exec bash "$ROOT/scripts/start-all.sh" "$@" ;;
  stop)   exec bash "$ROOT/scripts/stop-all.sh"  "$@" ;;
  check)  exec bash "$ROOT/scripts/check-stack.sh" "$@" ;;
  smoke)  exec bash "$ROOT/scripts/smoke.sh"     "$@" ;;
  e2e)    exec bash "$ROOT/scripts/e2e-local.sh" "$@" ;;
  logs)   exec bash "$ROOT/scripts/logs.sh"      "$@" ;;
  debug)  exec bash "$ROOT/scripts/debug-env.sh" "$@" ;;
  help|-h|--help)
    cat <<EOF
Planlife Local Control Plane

Usage: ./scripts/control.sh <command> [args]

  start [--native]     Start full stack (Docker by default)
  stop                 Stop everything cleanly
  check                Live ports + Docker + HTTP health matrix
  smoke                Ultra-fast individual probes
  e2e [topic] [plat]   Full content → video end-to-end test
  logs [service]       Tail logs (all | video-builder | webhook-listener | ...)
  debug                Full environment dump for support
  help                 Show this help

Examples:
  ./scripts/control.sh start
  ./scripts/control.sh check
  ./scripts/control.sh e2e "morning gratitude" tiktok
  ./scripts/control.sh logs webhook-listener
EOF
    ;;
  *)
    echo "Unknown command: $CMD"
    echo "Run: ./scripts/control.sh help"
    exit 1
    ;;
esac
