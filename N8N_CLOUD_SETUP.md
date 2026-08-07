# Wire into limitlessmindset.app.n8n.cloud

## Problem
n8n Cloud cannot reach `localhost` on your machine. You must expose the two local services.

## Fastest path: Cloudflare Tunnel (free)

```bash
# Install cloudflared, then:
cloudflared tunnel --url http://localhost:8100   # content-agent → copy the https URL
cloudflared tunnel --url http://localhost:8000   # video webhook → copy the https URL
```

## In n8n cloud
1. Open https://limitlessmindset.app.n8n.cloud
2. Workflows → Import from File → `n8n/full-pipeline-cloud.json`
3. Edit the two HTTP Request nodes:
   - **Generate Content** URL → `https://YOUR-TUNNEL-1.trycloudflare.com/generate`
   - **Build Video** URL → `https://YOUR-TUNNEL-2.trycloudflare.com/webhook`
4. Activate workflow
5. Test webhook path: `POST https://limitlessmindset.app.n8n.cloud/webhook/ugc-pipeline`
   ```json
   { "topic": "focus tips", "platform": "tiktok" }
   ```

## Alternative: run services on a cheap VPS
Deploy both docker-compose stacks on a VPS with a domain → permanent URLs, no tunnel needed.

## Local n8n (already in docker-compose)
If you use the bundled n8n on port 5678 instead of cloud:
- Import `n8n/openmanus-workflow.json`
- URLs can stay as `http://webhook-listener:8000` (Docker network)
- Login: admin / value from `.env`
