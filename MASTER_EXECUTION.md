# MASTER EXECUTION — Planlife / Limitless

Date: 2026-08-20

## Objective
Finish the existing work before starting new products. GitHub is the source of truth. The operating target is a cloud-first, repeatable content-to-revenue system with no dependency on a phone or local laptop.

## Verified repository map

| Repository | Current role | Action |
|---|---|---|
| `Planlife-agent0-openmanus` | Video generation pipeline + Manus task prompts | Canonical pipeline documentation/orchestration |
| `otto-server-wow` | Controller/dashboard for content → video | Canonical controller; verify cloud path |
| `Ugc-business--os` | React/Vite UGC ad-script engine | Canonical UGC script product; finish/verify/deploy |
| `ai-ugc` | Content agent | Verify interface and cloud deployment |
| `Ugc-business-os` | Empty integration shell | Do not build independently until architecture requires it |
| `n8n-oracle-cloud-selfhost` | n8n self-host experiment | Evaluate only if needed; prefer existing cloud n8n |
| `gumroad` / `gumroad-cli` | Digital-product infrastructure | Monetization integration after core funnel works |

## Execution sequence

### 1. Repository control
- Audit relevant repositories, default branches, recent commits, open PRs/issues, workflows, manifests, deployment files, and README claims.
- Identify duplicates and mark canonical implementations.
- Never delete working code merely to reduce repository count.

### 2. UGC product
- Verify required Vite/React source files.
- Run TypeScript/build checks in a cloud-capable environment.
- Remove or document production blockers.
- Review browser-side API-key handling and document the security tradeoff.
- Verify Vercel configuration and production deployment.

### 3. Video pipeline
- Verify the Planlife webhook, video-builder, and output path.
- Verify Otto health checks, dashboard, trigger, and auto mode.
- Replace localhost-only assumptions with cloud service URLs where applicable.
- Verify n8n workflow integration.

### 4. End-to-end test
Trigger → content/script → video → artifact/output → controller status → monitoring.

Record actual URLs and actual test results. Never mark a service live without verification.

### 5. Revenue system
Build one narrow funnel around the completed UGC/content capability:
- offer
- landing page
- checkout
- fulfillment
- lead/content acquisition
- analytics
- follow-up

Do not launch multiple monetization experiments simultaneously.

### 6. Strategic expansion
Only after the first revenue funnel is technically operational, resume the larger Muslim platform, Montgomery Muslim directory, digital products, and AI-music experiments.

## Agent operating rules

1. Inspect before editing.
2. Preserve working functionality.
3. Do not commit secrets, API keys, credentials, or `.env` files.
4. Use feature branches for code changes and draft PRs unless an explicit direct-main change is required.
5. Build/test every code change.
6. If deployment credentials are unavailable, report the exact blocker and prepare everything else rather than claiming success.
7. Prefer current official platform capabilities and verify time-sensitive claims before changing architecture.
8. When a task is complete, update the relevant README and this execution record with evidence.

## Current strategic priority

**Finish → verify → deploy → monetize.**

New app ideas are backlog items until the existing production path is operational.
