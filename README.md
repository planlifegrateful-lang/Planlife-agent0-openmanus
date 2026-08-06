# Planlife OpenManus Pipeline

Self-hostable skeleton for an OpenManus-powered video generation / agent pipeline.

## Architecture

```
[External Trigger / n8n] 
        |
        v
[webhook-listener :8000]  --->  [video-builder :8001]  --->  /data/output/*.mp4
        |
        +-- optional [openmanus :8002] (placeholder agent)
```

- **webhook-listener**: Receives POSTs, forwards JSON to video-builder
- **video-builder**: Placeholder that writes a dummy .mp4 (replace with real OpenManus + ffmpeg pipeline)
- **openmanus**: Placeholder Flask service (swap for real agent image)
- **n8n**: Workflow automation (import `n8n/openmanus-workflow.json`)

## Quick Start

```bash
# 1. Configure
cp .env.example .env
# edit .env — especially change N8N_BASIC_AUTH_PASSWORD

# 2. Launch
docker compose up --build -d

# 3. Health checks
curl http://localhost:8000/health
curl http://localhost:8001/health
curl http://localhost:8002/health

# 4. Trigger a build
curl -X POST http://localhost:8000/webhook \
  -H "Content-Type: application/json" \
  -d '{"title": "My First Video", "prompt": "demo"}'

# 5. n8n UI
open http://localhost:5678
# login with values from .env
```

## Import n8n Workflow

1. Open n8n → Workflows → Import from File
2. Select `n8n/openmanus-workflow.json`
3. Activate the workflow
4. Use the generated webhook URL or POST to the listener directly

## Next Steps (replace placeholders)

1. Replace `video-builder/app.py` build logic with real OpenManus / LLM + media pipeline
2. Swap `OpenManus/` image for official or custom agent image
3. Add auth (API keys / JWT) on webhook-listener
4. Persist real video assets and add cleanup policies
5. Wire Telegram / social media using the env vars

## Development Notes

- All services run as non-root
- Healthchecks + restart policies enabled
- Named volumes for output and n8n data
- No secrets committed (use `.env`)

This is an aggressive production-ready scaffold. Fill in the real OpenManus logic and you have a working pipeline.
