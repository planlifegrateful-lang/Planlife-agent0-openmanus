# Termux-Only Manus Task Prompt

Optimized for running the full pipeline on Android via Termux.

---

```text
You are an expert Android + Termux automation agent. Get the Planlife zero-API video generation pipeline fully working on Termux (no Docker, no root).

Repos:
- https://github.com/planlifegrateful-lang/ai-ugc (content-agent on 8100)
- https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus (webhook-listener 8000 + video-builder 8001)

Requirements:
- Use only Termux packages (pkg) + pip
- Install: python, nodejs-lts, ffmpeg, espeak, git, clang, libjpeg-turbo, tmux
- Create virtualenvs for each Python service
- Produce a single copy-paste script that:
  1. Installs all dependencies
  2. Clones both repos (if needed)
  3. Sets up venvs and installs flask + pillow
  4. Starts content-agent, video-builder, and webhook-listener in tmux panes
  5. Optionally installs and starts n8n
- Include health checks and how to trigger a test video (topic → MP4)
- Handle common Termux issues (storage, background kill, PATH for ffmpeg/espeak)

Be aggressive. Deliver a complete, ready-to-run Termux script and clear instructions. Zero external paid APIs.
```
