# Distribution — 4 phases to zero daily decisions

## Phase 1 — Manual pull (now, zero tokens)
Run pipeline → MP4 in Docker volume → copy out → upload in apps.

```bash
mkdir -p out
docker run --rm \
  -v planlife-agent0-openmanus_video-output:/data \
  -v "$(pwd)/out":/out \
  alpine cp -r /data/. /out/
ls -la out/
```

## Phase 2 — Alert when done (still zero platform tokens)
After **Build Video** in n8n, add Email / Telegram / Discord node with:
- title, script, filename, caption
You still upload the file yourself; you just get notified.

## Phase 3 — Auto-post (needs tokens)
1. Create TikTok / Meta / YouTube / X developer apps + tokens
2. In n8n: credentials for each platform
3. After Build Video:
   - Upload MP4 to storage with a public URL (S3, R2, or n8n binary)
   - Call each platform API or community node
4. Keep generation zero-API; only distribution uses keys

## Phase 4 — Daily cron endgame (the system)
Import `n8n/full-pipeline-cloud.json`:

| Time | What happens |
|------|----------------|
| 09:00 daily | Schedule fires |
| | Topic picked from rotation (day of week) |
| | ai-ugc generates hook/script/caption |
| | Planlife builds spoken MP4 |
| | (Phase 3) post to TikTok / Reels / Shorts |

**Zero daily decisions.** You only maintain tunnel URLs + tokens.

### Topic rotation (editable in n8n Code node)
- morning routine tips
- focus and deep work
- habit stacking
- sleep hygiene
- productivity systems
- mindset shifts
- tiny daily wins

### Webhook override anytime
```bash
curl -X POST https://limitlessmindset.app.n8n.cloud/webhook/ugc-pipeline \
  -H "Content-Type: application/json" \
  -d '{"topic": "cold exposure", "platform": "tiktok"}'
```

## Order of operations
1. `./scripts/e2e-local.sh "morning routine" tiktok` — prove local works
2. Cloudflare Tunnel both ports — prove cloud can reach you
3. Import workflow — replace the two `REPLACE_*_TUNNEL` URLs
4. Activate Daily 9am
5. Phase 1–2 until tokens; then Phase 3–4
