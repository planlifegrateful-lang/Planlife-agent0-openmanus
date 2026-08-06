# Planlife OpenManus Pipeline (Zero-API)

Self-hostable **fully local** video generation pipeline. **No API keys. No cloud AI.**

## What it does

1. Receives webhook with title + script/prompt
2. Builds text slides with Pillow
3. Generates voiceover with `espeak-ng` (offline TTS)
4. Assembles real playable MP4 with `ffmpeg`
5. Saves to volume `/data/output`

Also includes n8n + webhook-listener + placeholder OpenManus service.

## Quick Start

```bash
git clone https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus.git
cd Planlife-agent0-openmanus
cp .env.example .env
# only change N8N password if you want

docker compose up --build -d

# Health
curl http://localhost:8000/health
curl http://localhost:8001/health

# Generate a real video
curl -X POST http://localhost:8000/webhook \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Morning Routine",
    "script": "Wake up early. Drink water. Move your body. Win the day."
  }'
```

Videos land in the `video-output` Docker volume.

## Architecture

```
[Webhook / n8n] → webhook-listener:8000 → video-builder:8001 → /data/output/*.mp4
                                         ↘ openmanus:8002 (optional)
```

## Zero-API stack
- Slides: Pillow
- Voice: espeak-ng
- Video: ffmpeg
- No OpenAI, no Anthropic, no ElevenLabs, no cloud

## Next level (optional)
- Swap espeak for Piper TTS voice models (still offline)
- Feed scripts from the ai-ugc content-agent
- Add your own background clips or music
