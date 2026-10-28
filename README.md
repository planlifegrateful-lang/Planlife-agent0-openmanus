# Planlife OpenManus Pipeline (Zero-API)

Fully local video generation. **No API keys. No Docker required.**

Pillow slides + espeak-ng voice + ffmpeg → real MP4.

---

## Fastest path (Native – recommended)

```bash
git clone https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus.git
cd Planlife-agent0-openmanus

# System deps (Ubuntu/Debian)
sudo apt update && sudo apt install -y ffmpeg espeak-ng fonts-dejavu-core python3-venv

# One command start
bash OpenManus/start-native.sh
```

Then:
```bash
curl -X POST http://127.0.0.1:8000/webhook \
  -H "Content-Type: application/json" \
  -d '{"title":"Morning Routine","script":"Wake up. Drink water. Move. Win."}'
```

Videos appear in `./output/`

### Termux (Android)
```bash
bash OpenManus/start-termux.sh
```

### Manus / OpenManus agent
See prompts in `OpenManus/TASK_PROMPT_*.md`

---

## Full stack with Otto (recommended for production)

Otto is the 10/10 automatic controller + live dashboard.

```bash
git clone https://github.com/planlifegrateful-lang/otto-server-wow.git
cd otto-server-wow
bash start_otto_stack.sh
```

Opens dashboard at http://127.0.0.1:8200  
One-click trigger of content → video pipeline.

---

## Docker path (optional)

```bash
cp .env.example .env
docker compose config --quiet
docker compose up --build -d
curl http://127.0.0.1:8000/health
```

The published ports bind to `127.0.0.1` by default, keeping the helper services local to the host. The Compose file pins n8n to the reviewed `2.45.4` release instead of mutable `:latest`.

n8n uses its built-in owner/user-management login. On first startup, open the local n8n page and create the owner account; the old `N8N_BASIC_AUTH_*` variables were removed in n8n v1. Keep the `n8n-data` volume because it stores instance state and credentials.

**Remote access warning:** do not change all services to `0.0.0.0`. If you need to open the n8n editor from a phone on your trusted LAN, set only `N8N_BIND_ADDRESS` to the laptop's LAN IP and update `N8N_HOST` and `WEBHOOK_URL` to match. Keep helper-service bindings on loopback unless you have separately added authentication and firewall restrictions. Do not expose plain HTTP directly to the public internet; use a properly configured HTTPS reverse proxy.

## Ports
| Service            | Port |
|--------------------|------|
| Content Agent      | 8100 |
| Webhook Listener   | 8000 |
| Video Builder      | 8001 |
| **Otto Controller**| 8200 |

## Architecture
```
[Trigger] → ai-ugc :8100 → script/caption
                ↓
         Planlife :8000 → real MP4 in ./output
                ↓
         Otto :8200 (dashboard + auto)
                ↓
         (optional) n8n → post to platforms
```

## n8n Cloud
See [N8N_CLOUD_SETUP.md](N8N_CLOUD_SETUP.md)  
Import [n8n/full-pipeline-cloud.json](n8n/full-pipeline-cloud.json)

---

## Bing Video Creator clips → 2-minute vertical master

Use the local assembler for clips you generated and downloaded yourself in Bing Video Creator. It requires no API keys and does not automate Bing or bypass Microsoft's limits.

See [Bing Clip Studio setup](bing-workflow/README.md) and the [faceless prompt pack](bing-workflow/PROMPT_PACK.md).

Quick start from the repository root after installing FFmpeg/FFprobe:

```bash
mkdir -p bing-workflow/input
# Copy downloaded, numbered clips into bing-workflow/input/ (clip01.mp4, clip02.mp4, ...)
python3 bing-workflow/assemble.py
```

Output: `output/bing-master-2min.mp4`. Optional licensed music: `python3 bing-workflow/assemble.py --music path/to/music.mp3`. The default export is silent so you can add narration, captions, and platform-approved music in your editor.
