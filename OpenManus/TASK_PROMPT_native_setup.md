# Manus / OpenManus Task Prompt

**Goal:** Get the Planlife zero-API video generation pipeline fully working WITHOUT Docker.

Copy the prompt below and paste it into Manus AI or feed it to your local OpenManus agent.

---

## Task Prompt (copy everything below this line)

```text
You are an expert DevOps + AI automation agent. Your mission is to get the Planlife zero-API video generation pipeline fully working WITHOUT relying on Docker (Docker downloads are currently broken).

Context:
- Repositories:
  - https://github.com/planlifegrateful-lang/ai-ugc (content generation service on port 8100)
  - https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus (video pipeline: webhook-listener on 8000 + video-builder on 8001)
- Goal: Generate real MP4 videos from a topic (e.g. "morning routine") using local tools only (Pillow + espeak-ng + ffmpeg). No external AI APIs.
- Preferred environments (in order):
  1. Native Python on Linux/macOS/Windows
  2. Termux on Android
  3. Podman as Docker drop-in
  4. n8n (via npm or existing Cloud instance)

Your tasks (execute in order, be aggressive and complete):

1. Analyze both repositories thoroughly (read Dockerfiles, app.py, requirements.txt, README, n8n workflows).
2. Create a complete native (non-Docker) startup solution:
   - Exact commands to install system dependencies (ffmpeg, espeak-ng, fonts)
   - Python virtualenv + pip install steps for content-agent, video-builder, and webhook-listener
   - How to correctly set VIDEO_BUILDER_URL so the services talk to each other
   - Health-check commands
3. Provide a ready-to-run Termux version (full copy-paste script) that works on Android.
4. Create or update a simple start script (start-native.sh or start-termux.sh) that launches all three services + optionally n8n.
5. Show how to connect the existing n8n workflow (full-pipeline-cloud.json or openmanus-workflow.json) to the native services.
6. Test the full chain end-to-end if possible: topic → content generation → video MP4.
7. Output everything clearly:
   - Step-by-step commands
   - Ready-to-copy scripts
   - Any necessary code patches (e.g. hardcode localhost URLs)
   - Troubleshooting for common Termux / native issues

Constraints:
- Zero external paid APIs
- Prefer solutions that work offline after initial setup
- Make it as simple and reliable as possible
- If something is impossible, say so and give the best alternative

Start by confirming you understand the goal, then execute the full plan. Deliver working commands and scripts.
```

---

## How to use

### Manus AI (cloud)
1. Go to your Manus task creation interface
2. Paste the entire prompt above
3. Run the task

### Local OpenManus
```bash
# From the OpenManus directory or project root
python main.py
# Then paste the prompt when prompted
```

Or save the prompt content into a file and feed it to the agent.
