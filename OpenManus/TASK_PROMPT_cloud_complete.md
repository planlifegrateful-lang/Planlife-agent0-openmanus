# Manus Task — Cloud Complete (10/10)

**No phone. No HP laptop. Everything on GitHub + cloud.**

Copy the prompt below into Manus / OpenManus.

---

```text
You are a senior cloud automation agent. Mission: make the entire Planlife / Limitless UGC stack finished, verified, and running in the cloud with ZERO dependency on phone or local HP laptop.

SOURCE OF TRUTH (GitHub only):
- https://github.com/planlifegrateful-lang/Ugc-business--os   ← UGC Ad Script Engine (React + Anthropic streaming)
- https://github.com/planlifegrateful-lang/ai-ugc              ← zero-API content agent
- https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus  ← video pipeline + this task file
- https://github.com/planlifegrateful-lang/Ugc-business-os     ← shell / integration

HARD RULES:
- Do not ask the user to open a laptop, phone, USB, or Termux.
- All work happens via GitHub API, Vercel (or equivalent cloud host), and cloud agents.
- If something is incomplete on GitHub, fix it by committing the missing files.
- Deliver working cloud URLs + a verification checklist.

EXECUTE IN ORDER:

1) AUDIT
   - List every file in Ugc-business--os (recursive).
   - Confirm these exist and are non-empty:
     package.json, index.html, vite.config.ts, tsconfig.json, vercel.json,
     src/main.tsx, src/App.tsx, src/types.ts, src/index.css, src/App.css,
     src/lib/parser.ts, src/lib/prompt.ts, src/lib/storage.ts,
     src/components/Header.tsx + .css,
     src/components/Controls.tsx + .css,
     src/components/OutputPanel.tsx + .css,
     src/components/HistoryPanel.tsx + .css
   - If any are missing: reconstruct from the engine design (dark-luxury Limitless UI, Anthropic stream, HOOK/PROBLEM/BRIDGE/PROOF/CTA/DIRECTOR NOTE/ESTIMATED RUNTIME, Sharia toggle, 1–3 variants, localStorage history) and push commits to main.

2) CLOUD DEPLOY — UGC Ad Script Engine
   - Deploy Ugc-business--os to Vercel (or already-linked project ugc-ad-script-engine).
   - Framework: Vite. Build: npm run build. Output: dist. SPA rewrite to index.html.
   - Target: production.
   - Return the stable production URL.

3) CLOUD STATUS — other services
   - Document how ai-ugc + Planlife-agent0-openmanus run in cloud (Railway / Render / Fly / existing n8n Cloud at limitlessmindset.app.n8n.cloud).
   - If they are Docker-only, provide a one-shot cloud deploy path (no local machine).
   - Point n8n Cloud workflows at the cloud service URLs, not localhost.

4) VERIFY (must pass)
   - Production URL loads the dark-luxury UGC Ad Script Engine UI.
   - Header shows OMEGA SWARM v10 · Limitless.
   - API key field present; Generate Scripts button present.
   - No missing modules / blank white screen.
   - README on Ugc-business--os states the live cloud URL.

5) FINAL REPORT (required format)
   - GitHub status: COMPLETE / gaps fixed
   - Cloud URL: https://...
   - Other services: status + URLs
   - Dependency on phone/HP: NONE
   - Score: 10/10 only if UI is live and all source files are on GitHub main

Start now. Audit → fix gaps → deploy → verify → report. Do not stop until the engine is live in the cloud and the repos are complete.
```

---

## How to use

1. Open Manus (cloud)
2. Paste the entire prompt inside the code fence
3. Run — no phone, no HP required
