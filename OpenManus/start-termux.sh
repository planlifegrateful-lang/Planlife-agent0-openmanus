#!/data/data/com.termux/files/usr/bin/bash
# start-termux.sh - Full Planlife pipeline on Termux (Android)
# Run inside Termux: bash start-termux.sh

set -e

echo "=== Planlife Termux Starter ==="

# 1. Packages
echo "--> Installing packages (this may take a few minutes)..."
pkg update -y
pkg install -y python nodejs-lts git ffmpeg espeak clang make libjpeg-turbo libpng tmux curl

# 2. Storage
termux-setup-storage 2>/dev/null || true

# 3. Clone repos if missing
cd ~
if [ ! -d ai-ugc ]; then
  git clone https://github.com/planlifegrateful-lang/ai-ugc.git
fi
if [ ! -d Planlife-agent0-openmanus ]; then
  git clone https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus.git
fi

# 4. Setup Python services
setup_venv() {
  local dir="$1"
  local pkgs="$2"
  cd "$dir"
  if [ ! -d venv ]; then
    python -m venv venv
    source venv/bin/activate
    pip install --upgrade pip
    pip install $pkgs
    deactivate
  fi
}

setup_venv ~/ai-ugc/content-agent "flask"
setup_venv ~/Planlife-agent0-openmanus/video-builder "flask pillow"
setup_venv ~/Planlife-agent0-openmanus/webhook-listener "flask"

# 5. Launch in tmux
echo "--> Starting services in tmux session 'planlife'..."
tmux kill-session -t planlife 2>/dev/null || true
tmux new-session -d -s planlife -n services

# Pane 0: content-agent
tmux send-keys -t planlife:0 "cd ~/ai-ugc/content-agent && source venv/bin/activate && python app.py" Enter

# Pane 1: video-builder
tmux split-window -t planlife:0 -v
tmux send-keys -t planlife:0.1 "cd ~/Planlife-agent0-openmanus/video-builder && source venv/bin/activate && python app.py" Enter

# Pane 2: webhook-listener
tmux split-window -t planlife:0 -h
tmux send-keys -t planlife:0.2 "cd ~/Planlife-agent0-openmanus/webhook-listener && source venv/bin/activate && export VIDEO_BUILDER_URL=http://127.0.0.1:8001/build && python app.py" Enter

tmux select-layout -t planlife:0 tiled

echo ""
echo "=== Done ==="
echo "Services running inside tmux session: planlife"
echo "Attach with:  tmux attach -t planlife"
echo ""
echo "Endpoints:"
echo "  Content:  http://127.0.0.1:8100"
echo "  Webhook:  http://127.0.0.1:8000"
echo "  Video:    http://127.0.0.1:8001"
echo ""
echo "Test:"
echo "  curl http://127.0.0.1:8100/health"
echo "  curl -X POST http://127.0.0.1:8000/webhook -H 'Content-Type: application/json' -d '{\"title\":\"Test\",\"script\":\"Hello from Termux\"}'"
echo ""
echo "Optional n8n: npm install -g n8n && n8n"
