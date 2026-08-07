# Distribution (Phase 3)

Zero-API generation is done. Publishing to TikTok / Reels / Shorts **requires platform tokens** (you previously asked for no API keys for generation — distribution is optional and separate).

## Option A — Manual (zero tokens)
1. Run the pipeline → MP4 lands in `video-output` Docker volume
2. Copy file out:
   ```bash
   docker run --rm -v planlife-agent0-openmanus_video-output:/data -v $(pwd)/out:/out alpine cp -r /data/. /out/
   ```
3. Upload manually in each app

## Option B — n8n + platform credentials
When you are ready for auto-post:
1. Create tokens in TikTok / Meta / YouTube / X developer consoles
2. In n8n cloud add credentials
3. After the **Build Video** node, add platform nodes (HTTP Request to each API, or community nodes)
4. Attach the MP4 (you'll need a public URL or n8n binary handling — often upload to S3/R2 first)

## Option C — Stub webhook for later
Add a final HTTP Request node that POSTs metadata to your own endpoint:
```json
{
  "title": "...",
  "script": "...",
  "filename": "...",
  "caption": "...",
  "platform": "tiktok"
}
```
You can fill real upload logic later without changing the generation chain.

## Recommended path
1. Verify E2E locally with `scripts/e2e-local.sh`
2. Expose local services with Cloudflare Tunnel or ngrok
3. Import `n8n/full-pipeline-cloud.json` into limitlessmindset.app.n8n.cloud
4. Point env vars at tunnel URLs
5. Add distribution only when you have tokens
