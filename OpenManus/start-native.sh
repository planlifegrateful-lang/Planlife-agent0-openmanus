#!/usr/bin/env bash
# start-native.sh - Run Planlife zero-API video pipeline without Docker
# Usage: bash start-native.sh

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_UGC_DIR="${AI_UGC_DIR:-$HOME/ai-ugc}"
PLANLIFE_DIR="$ROOT_DIR"

echo "=== Planlife Native Starter ==="
echo "Planlife dir: $PLANLIFE_DIR"
echo "ai-ugc dir:   $AI_UGC_DIR"

# ---------- System deps check ----------
check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo "ERROR: '$1' not found. Install it first."
    exit 1
  fi
}

check_cmd python3
check_cmd ffmpeg
echo "ffmpeg and python3 OK"

# ---------- Helper: start a service in background ----------
start_service() {
  local name="$1"
  local dir="$2"
  local port="$3"
  local reqs="$4"

  echo "--> Starting $name on :$port"
  cd "$dir"

  if [ ! -d venv ]; then
    python3 -m venv venv
    source venv/bin/activate
    pip install --upgrade pip -q
    pip install $reqs -q
  else
    source venv/bin/activate
  fi

  # Kill old process on port if any
  fuser -k "${port}/tcp" 2>/dev/null || true

  nohup python app.py > "/tmp/${name}.log" 2>&1 &
  echo $! > "/tmp/${name}.pid"
  echo "    PID $(cat /tmp/${name}.pid)  log: /tmp/${name}.log"
  deactivate 2>/dev/null || true
}

# ---------- ai-ugc (content-agent) ----------
if [ ! -d "$AI_UGC_DIR/content-agent" ]; then
  echo "Cloning ai-ugc..."
  git clone https://github.com/planlifegrateful-lang/ai-ugc.git "$AI_UGC_DIR"
fi
start_service "content-agent" "$AI_UGC_DIR/content-agent" 8100 "flask"

# ---------- video-builder ----------
start_service "video-builder" "$PLANLIFE_DIR/video-builder" 8001 "flask pillow"

# ---------- webhook-listener ----------
# Ensure it points to local video-builder
if grep -q "VIDEO_BUILDER_URL" "$PLANLIFE_DIR/webhook-listener/app.py" 2>/dev/null; then
  export VIDEO_BUILDER_URL="http://127.0.0.1:8001/build"
fi
start_service "webhook-listener" "$PLANLIFE_DIR/webhook-listener" 8000 "flask"

echo ""
echo "=== Services started ==="
echo "Content Agent:    http://127.0.0.1:8100"
echo "Webhook Listener: http://127.0.0.1:8000"
echo "Video Builder:    http://127.0.0.1:8001"
echo ""
echo "Health checks:"
echo "  curl http://127.0.0.1:8100/health"
echo "  curl http://127.0.0.1:8000/health"
echo "  curl http://127.0.0.1:8001/health"
echo ""
echo "Test video:"
echo "  curl -X POST http://127.0.0.1:8000/webhook \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"title\":\"Morning Routine\",\"script\":\"Wake up. Drink water. Move. Win.\"}'"
echo ""
echo "Logs are in /tmp/*.log   PIDs in /tmp/*.pid"
echo "Stop with: kill \$(cat /tmp/content-agent.pid /tmp/video-builder.pid /tmp/webhook-listener.pid)"
