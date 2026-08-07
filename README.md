# Planlife OpenManus Pipeline (Zero-API)

Fully local video generation. **No API keys.**

Pillow slides + espeak-ng voice + ffmpeg → real MP4.

## 60-second local run

```bash
git clone https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus.git
cd Planlife-agent0-openmanus
cp .env.example .env
docker compose up --build -d

# Health
curl http://localhost:8000/health
curl http://localhost:8001/health

# Real video
curl -X POST http://localhost:8000/webhook \
  -H "Content-Type: application/json" \
  -d '{"title":"Morning Routine","script":"Wake up. Drink water. Move. Win."}'
```

## Full chain (content → video)

1. Start **ai-ugc** on :8100  
2. Start this stack on :8000 / :8001  
3. Run:
```bash
chmod +x scripts/e2e-local.sh
./scripts/e2e-local.sh "morning routine" tiktok
```

## n8n Cloud automation
See **[N8N_CLOUD_SETUP.md](N8N_CLOUD_SETUP.md)**  
Import **[n8n/full-pipeline-cloud.json](n8n/full-pipeline-cloud.json)** into `limitlessmindset.app.n8n.cloud`

## Distribution
See **[DISTRIBUTION.md](DISTRIBUTION.md)** (manual now; auto-post when you add tokens)

## Architecture
```
[Trigger] → ai-ugc :8100 → script/caption
                ↓
         Planlife :8000 → real MP4 in video-output volume
                ↓
         (optional) n8n → post to platforms
```
