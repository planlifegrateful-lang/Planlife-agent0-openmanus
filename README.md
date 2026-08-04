# Planlife OpenManus pipeline

This commit adds a simple self-hostable pipeline skeleton for OpenManus:
- docker-compose.yml to run services
- video-builder (Flask placeholder service that "builds" a video file)
- webhook-listener (forwards webhooks to the video builder)
- OpenManus Dockerfile (placeholder)
- .env.example with environment variables
- n8n workflow to receive webhooks and forward to the listener

How to run (local dev):
1. Copy .env.example to .env and fill values.
2. docker compose up --build
3. POST JSON to http://localhost:${WEBHOOK_LISTENER_PORT:-8000}/webhook or configure n8n webhook to trigger it.

This is an initial scaffold — replace placeholder logic with real OpenManus implementations.
