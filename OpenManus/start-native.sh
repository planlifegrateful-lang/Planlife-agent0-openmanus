#!/usr/bin/env bash
# start-native.sh - Run Planlife zero-API video pipeline WITHOUT Docker
# Usage: bash OpenManus/start-native.sh

set -e

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AI_UGC_DIR="${AI_UGC_DIR:-$HOME/ai-ugc}"
PLANLIFE_DIR="$ROOT_DIR"
OUTPUT_DIR="${OUTPUT_DIR:-$PLANLIFE_DIR/output}"

mkdir -p "$OUTPUT_DIR"

echo "=== Planlife Native Starter (No Docker) ==="
echo "Planlife: $PLANLIFE_DIR"
echo "ai-ugc:   $AI_UGC_DIR"
echo "Output:   $OUTPUT_DIR"

check_cmd() {
  if ! command -v "$1" &>/dev/null; then
    echo "ERROR: '$1' not found."
    echo "Install: sudo apt install ffmpeg espeak-ng fonts-dejavu-core python3-venv  (or brew on mac)"
    exit 1
  fi
}

check_cmd python3
check_cmd ffmpeg
command -v espeak-ng &>/dev/null || command -v espeak &>/dev/null || {
  echo "WARNING: espeak-ng not found — video TTS will fail. Install espeak-ng."
}
echo "Deps OK"

start_service() {
  local name="$1"
  local dir="$2"
  local port="$3"
  local reqs="$4"
  shift 4
  local extra_env=("$@")

  echo "--> Starting $name on :$port"
  cd "$dir"

  if [ ! -d venv ]; then
    python3 -m venv venv
    # shellcheck disable=SC1091
    source venv/bin/activate
    pip install --upgrade pip -q
    pip install $reqs -q
  else
    # shellcheck disable=SC1091
    source venv/bin/activate
  fi

  # free port if something is already listening
  if command -v fuser &>/dev/null; then
    fuser -k "${port}/tcp" 2>/dev/null || true
  fi

  # export any extra env
  for e in "${extra_env[@]}"; do
    export "$e"
  done

  nohup env "${extra_env[@]}" python app.py > "/tmp/${name}.log" 2>&1 &
  echo $! > "/tmp/${name}.pid"
  echo "    PID $(cat /tmp/${name}.pid)  log=/tmp/${name}.log"
  deactivate 2>/dev/null || true
}

# --- content-agent (optional but useful) ---
if [ ! -d "$AI_UGC_DIR/content-agent" ]; then
  echo "Cloning ai-ugc..."
  git clone --depth 1 https://github.com/planlifegrateful-lang/ai-ugc.git "$AI_UGC_DIR" || true
fi
if [ -d "$AI_UGC_DIR/content-agent" ]; then
  start_service "content-agent" "$AI_UGC_DIR/content-agent" 8100 "flask"
else
  echo "Skipping content-agent (ai-ugc not available)"
fi

# --- video-builder ---
start_service "video-builder" "$PLANLIFE_DIR/video-builder" 8001 "flask pillow" \
  "OUTPUT_DIR=$OUTPUT_DIR" "PORT=8001"

# --- webhook-listener (must point at localhost video-builder) ---
start_service "webhook-listener" "$PLANLIFE_DIR/webhook-listener" 8000 "flask requests" \
  "VIDEO_BUILDER_URL=http://127.0.0.1:8001/build" "PORT=8000"

sleep 2
echo ""
echo "=== Services up ==="
echo "Content Agent:    http://127.0.0.1:8100"
echo "Webhook Listener: http://127.0.0.1:8000"
echo "Video Builder:    http://127.0.0.1:8001"
echo "Videos saved to:  $OUTPUT_DIR"
echo ""
echo "Health:"
echo "  curl -s http://127.0.0.1:8000/health"
echo "  curl -s http://127.0.0.1:8001/health"
echo ""
echo "Make a video:"
echo "  curl -X POST http://127.0.0.1:8000/webhook \\"
echo "    -H 'Content-Type: application/json' \\"
echo "    -d '{\"title\":\"Morning Routine\",\"script\":\"Wake up. Drink water. Move. Win.\"}'"
echo ""
echo "Stop: kill \$(cat /tmp/content-agent.pid /tmp/video-builder.pid /tmp/webhook-listener.pid 2>/dev/null)"
