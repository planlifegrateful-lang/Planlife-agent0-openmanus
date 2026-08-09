# Short Manus Task Prompt

Use this shorter version when you want faster execution.

---

```text
Get the Planlife zero-API video pipeline working WITHOUT Docker.

Repos:
- ai-ugc (port 8100): https://github.com/planlifegrateful-lang/ai-ugc
- Planlife-agent0-openmanus (ports 8000 + 8001): https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus

Tasks:
1. Analyze both repos (Dockerfiles, app.py, requirements).
2. Deliver exact native Python commands (venv + pip) to run content-agent, video-builder, and webhook-listener on localhost.
3. Provide a complete Termux (Android) one-shot install + start script.
4. Create start-native.sh that launches all services.
5. Show how to point the existing n8n workflows at the native services.
6. Include health-check curl commands and any required code patches.

Constraints: zero paid APIs, offline-capable after setup, aggressive and complete. Output ready-to-copy scripts.
```
