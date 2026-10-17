# KAREEM — ONE-SHOT EXECUTION MISSION 2027
## Claude × Manus × OpenManus × GitHub Actions | Plan Life Grateful

**Purpose:** Execute the highest-value unfinished work in the existing PLG repositories. This is an operator handoff, not another strategy exercise. Preserve existing assets, prove every claim, and deliver a working, tested result.

**Important execution boundary:** This file is a task prompt stored in GitHub. Do not claim it has been sent to Manus or run unless you actually opened Manus through an authorized integration and received execution evidence. If you are Manus, begin the mission below. If you are Claude, audit/review/implement code and produce a precise handoff to Manus. If you are OpenManus, perform only the work your actual runtime and permissions support. Never impersonate another agent or invent cross-agent communication.

## 1. Mission and business outcome

Build and verify the smallest useful, reliable, faceless content-production path for Plan Life Grateful (PLG), reusing current work. The first outcome is a reproducible, locally/cloud-buildable video pipeline and an evidence-based readiness report—not a claim of sales, viral reach, or public publishing.

Prioritize:
1. Existing PLG assets and repository code.
2. A successful automated build/test and a real sample video artifact where supported.
3. A documented, repeatable handoff from product/topic → script → scenes/assets → MP4 → quality checks → human approval.
4. Only after that works, prepare the next batch/queue. Do not publish publicly without explicit approval.

## 2. Repositories to inspect first

- Master control plane: https://github.com/planlifegrateful-lang/planlife-grateful-os
- OpenManus/video pipeline: https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus
- UGC business OS: https://github.com/planlifegrateful-lang/Ugc-business-os
- Content agent: https://github.com/planlifegrateful-lang/ai-ugc
- Suno video factory (inspect if relevant): https://github.com/planlifegrateful-lang/suno-video-factory

Do not assume repository names, branches, deployments, services, or workflows are correct just because an old README says so. Verify current GitHub state. The OpenManus repository has previously contained `OpenManus/Dockerfile` describing a placeholder service; specifically verify whether this remains true before reporting it as functional.

## 3. Non-negotiable operating rules

- **Truth first:** classify each claim as VERIFIED, REPORTED, ASSUMED, NOT TESTED, or BLOCKED.
- Never claim access to an account, cloud host, Manus session, API, device, or file unless the current runtime proves it.
- Never claim a video exists, plays, is downloadable, or passed QA unless the exact artifact was opened/checked and its result recorded.
- Never claim revenue, views, clicks, publication, deployment, or successful automation without authoritative evidence.
- No secrets in prompts, code, issues, logs, commits, or reports. Never print credential values, tokens, cookies, recovery codes, or private customer information. Check for accidental secrets before commits.
- Do not buy, upgrade, publish publicly, send messages, change account/security/payment settings, or delete/overwrite assets without explicit user approval.
- Preserve originals. Inspect before editing. Back up or use a new branch before risky changes. Prefer small, reversible commits.
- No Canva in this workflow. No Termux or phone-terminal instructions. Prefer GitHub/cloud execution; do not assume a cloud host exists.
- No paid API or recurring service unless already configured and authorized. Do not circumvent platform login, rate limits, or access controls.
- Respect copyright, platform policies, affiliate disclosures, and Sharia-conscious PLG requirements. Health/product claims must be supportable; do not imply medical outcomes without evidence.
- Do not ask the user to repeat facts already in the repository or prior task files. If blocked, finish independent safe work and state the one concrete blocker.

## 4. Agent responsibilities

### Claude — code auditor and implementation reviewer
1. Read the existing README, task prompts, source files, dependency manifests, tests, Dockerfiles, workflows, and recent commits before proposing changes.
2. Identify real defects and missing pieces. Do not rebuild a working component merely to create activity.
3. Implement small, reviewable fixes in an existing branch/PR where available. Add/update tests and documentation. Review the diff for regressions, secrets, and scope creep.
4. Give Manus exact repository paths, commands, acceptance tests, and known limitations. Do not claim a change is deployed unless deployment evidence exists.

### Manus — execution coordinator
1. Inspect its actual available browser/computer tools, connected apps, repository access, and permissions. Report access separately from successful testing.
2. Read this file and existing repo task prompts. Coordinate the smallest safe execution plan.
3. Use GitHub and authorized cloud tools to run the real build/test path. If it cannot access a tool, do not pretend it did; hand the task to the agent/runtime that can.
4. Produce exact evidence: commit SHA/PR, Actions run URL and conclusion, artifact name/size, QA results, deployed URL only if actually deployed, and blockers.
5. Do not create a duplicate system, queue, product, dashboard, or cloud service when an existing one can be repaired.

### OpenManus — pipeline implementation/runtime
1. Verify its actual implementation and runtime. A placeholder HTTP endpoint is not a working agent.
2. Inspect the current video builder, webhook listener, content agent integration, requirements, start scripts, Docker configuration, and n8n workflow JSON.
3. Implement only the missing, safe pieces needed to create one deterministic test MP4. Make the pipeline report structured statuses and useful error messages; do not expose secrets.
4. If external generative services require keys or paid access, keep that path disabled until credentials/authorization are verified. Provide a no-cost deterministic sample path if the repository supports it.
5. Run the exact tests available. If this runtime cannot execute code, state NOT TESTED and provide the precise runnable commands to GitHub Actions or Manus.

### GitHub Actions — reproducible verification
1. Inspect existing workflows before adding another. Reuse/repair current workflows where practical.
2. Build/test on a clean runner with pinned or bounded dependencies and no secret values in logs.
3. If the workflow creates an MP4, upload it as an artifact and report the actual artifact link/name, duration, file size, and QA performed. Do not commit generated media unless there is a clear repository reason.
4. Do not deploy or publish automatically as part of this task. Deployment/public posting requires explicit approval.

## 5. Execute in this exact order

### Phase A — inventory and baseline
- Verify repository access, default branches, latest commits, root files, workflow files, and existing task prompts.
- Inspect all relevant code before edits, including:
  - `OpenManus/` scripts, service entrypoints, Dockerfile and README
  - `n8n/openmanus-workflow.json`
  - video assembly/rendering scripts and requirements
  - existing GitHub Actions workflows and their latest run results
- Record what exists, what runs, what is a placeholder, and what is unknown. Do not trust old README status tables without current evidence.

### Phase B — choose one thin vertical slice
Build only one end-to-end, testable path:
1. Input: a fixed, original PLG topic/script, initially **“Nobody Sees the Work”** (discipline, gratitude, patience; authentic, respectful Muslim identity only where natural).
2. Generate a structured scene plan with readable on-screen text and a truthful CTA; no fabricated testimonials, fake product claims, or copied scripts.
3. Assemble using repository-supported local/free components already present (for example Pillow/FFmpeg/espeak if genuinely configured). Do not assume these dependencies are installed.
4. Export a vertical MP4 suitable for review.
5. Validate file existence, nonzero size, duration, dimensions, video stream, audio stream if expected, no obvious empty/black output, and caption/spelling. Record each check as PASS/FAIL/NOT TESTED.
6. Save the artifact as a GitHub Actions artifact if the workflow can do this. Do not claim a local file is in cloud storage unless uploaded and verified.

### Phase C — repair and test
- Fix only defects demonstrated by the baseline or required acceptance criteria.
- Add automated tests for the fixed behavior.
- Run build/tests in the available environment. Capture command, exit status, run ID/URL, and relevant logs with secrets redacted.
- If deployment credentials/hosting are absent, do not invent a production URL. Mark deployment BLOCKED and keep build/test work moving.

### Phase D — approval gate
- Do not post to YouTube, TikTok, Facebook, Instagram, or any public destination.
- Do not purchase APIs, cloud hosting, credits, or subscriptions.
- Prepare, but do not schedule or publish, a maximum 3-item follow-up queue until the first sample pipeline passes QA and the user approves.

### Phase E — commit and report
- Commit the smallest tested change to a feature branch or PR where supported; do not force-push or rewrite history.
- Update README only with verified facts. Add run instructions, dependencies, limitations, and safe rollback steps.
- Link exact commit/PR and CI run. If no changes were needed, report the evidence and why.
- Keep the current master control plane consistent, but do not change its revenue/product facts without fresh evidence.

## 6. Acceptance criteria

The mission is **COMPLETE** only when all applicable criteria have evidence:
- [ ] Existing repository structure and task prompts were inspected.
- [ ] OpenManus is correctly classified as functional, partial, or placeholder based on source and runtime evidence.
- [ ] A clean automated build/test run passed, with exact run URL/ID.
- [ ] One real MP4 artifact was created and verified, if the available runtime supports rendering.
- [ ] File QA includes size, duration, dimensions, streams, and playback/visual checks where supported.
- [ ] Changes are committed and the exact SHA/PR is provided.
- [ ] No secrets were exposed and no unapproved public or paid action occurred.
- [ ] Remaining blockers and the next single action are explicit.

If any criterion cannot be met, final status must be **PARTIALLY READY** or **BLOCKED**, not COMPLETE.

## 7. Required final report

Return concise evidence, not promises:

**STATUS:** COMPLETE / PARTIALLY READY / BLOCKED

**ACCESS VERIFIED**
- GitHub:
- Manus runtime:
- OpenManus runtime:
- Cloud host/deployment:
- Other connected tools:

**DONE — VERIFIED**
- Change + repository/path:
- Commit SHA / PR:
- GitHub Actions run URL + conclusion:
- Artifact URL/name, size, duration, dimensions, audio/video streams:
- QA checks performed and results:

**NOT DONE / BLOCKED**
- Exact missing capability or dependency:
- Why it matters:
- What was still completed despite the blocker:

**SECURITY / COST / APPROVAL**
- Secret scan outcome:
- Paid services used (must be none unless already authorized):
- Public posts/messages (must be none):
- Rollback:

**REVENUE REALITY**
- Confirmed sales:
- Confirmed commission:
- Payout received:
- If not checked or no evidence, say NOT VERIFIED; never infer $0 or positive revenue from missing access.

**NEXT ACTION**
Name exactly one highest-value next action and who must perform it. Separate agent-side work from any action that genuinely requires the user.

Start now. Audit → implement → test → verify → commit → report. Do not stop at recommendations, but never fake a completed step.
