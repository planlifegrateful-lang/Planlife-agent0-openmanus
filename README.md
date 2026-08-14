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
docker compose up --build -d
curl http://localhost:8000/health
```

---

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
