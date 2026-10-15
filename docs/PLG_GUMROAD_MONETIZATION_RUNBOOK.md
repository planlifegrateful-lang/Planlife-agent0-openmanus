# PLG Monetization Workflow — Muse + Gumroad + n8n/OpenManus

Status: runbook prepared from repository inspection on 2026-10-15. This document does NOT mean the user's Muse, Gumroad seller account, n8n instance, or OpenManus services have been authenticated or connected.

## Reuse existing assets first

- Existing n8n starter: `n8n/full-pipeline-cloud.json` in this repository. It already has a daily schedule and manual webhook, but uses placeholder tunnel URLs and generates a rotating generic topic. It does not connect to Gumroad, validate campaign approvals, or publish to social platforms.
- Existing local video builder: `Planlife-agent0-openmanus` repository README describes a local MP4 pipeline on port 8000 and an Otto dashboard on port 8200. These services must be running and reachable before n8n can call them.
- Existing script/video automation: `shorts-autopilot` includes a prompt pack and publisher code, but its README says Buffer/ShortSync live publishing has not been run; it needs tokens/channel IDs and Buffer requires a public direct HTTPS media URL.
- Existing Gumroad tooling: `gumroad-cli` repository documents a seller CLI with device authorization and product/sales read commands. This is code/tooling, not proof that the user's Gumroad account is connected.
- Prior notes identify the offer “Grateful Habit OS” at $19, but its previous checkout pointed to Whop, not verified Gumroad. Re-check the current Gumroad catalog and product URLs before using this offer.

## Goal and operating rule

Build the smallest useful loop: verify one existing offer → make approved short-form content → render video → human approval → publish manually or as a draft through a verified connector → measure clicks/orders → decide next action. No autonomous live posting, product edits, refunds, purchases, or customer messages without explicit approval.

## Prompt 1 — Meta Muse: research and prepare content

You are my Plan Life Grateful business operations assistant. Work only through the apps and permissions actually available in this Muse session. Do not claim to see a store, page, or metric unless you opened it and verified it.

Goal: help me sell one real PLG offer and/or create compliant affiliate content, with no upfront spend unless I approve it.

1. Inspect my connected apps and identify which of Gumroad, Instagram, Facebook, and my content files are actually accessible. Report accessible vs unavailable.
2. If Gumroad is accessible, inspect current published products and their exact URLs/prices. Do not change anything. If it is not accessible, give me the shortest steps to open the seller dashboard and copy the product URL; do not request or expose passwords or tokens in chat.
3. Select one offer using evidence: customer problem, product deliverables, price, proof of demand available, and fit with my audience. Mark facts vs assumptions.
4. Create three distinct faceless vertical-video concepts (15–25 seconds) with hook, shot list, exact on-screen text, caption, CTA, SEO title, and disclosure where needed.
5. Avoid unsupported health claims, fake testimonials, invented discounts, false urgency, and religious claims without reliable source references.
6. Save the concepts in a structured content queue only if an authorized writable app exists. Otherwise return copy-ready content.
7. Ask me to approve the selected concept before posting, changing a listing, sending messages, or spending money.
8. Finish with: completed actions, evidence/URLs, blocked items, and one next action.

## Prompt 2 — Gumroad offer audit (run only with authorized seller access)

Audit the current Gumroad products in read-only mode. Return product name, published/draft status, price, product URL, product type, description clarity, buyer outcome, checkout friction, and missing assets. Identify duplicates and do not create or edit products. If access is unavailable, give manual steps to collect the same fields. Do not assume the Whop offer is also on Gumroad. Recommend one existing offer to improve before proposing a new product.

## Prompt 3 — n8n/OpenManus workflow engineer

Inspect the existing workflow `n8n/full-pipeline-cloud.json` before editing. Preserve it and avoid duplicate workflows.

Build a staged workflow with these nodes/steps:
1. Manual Trigger and Schedule Trigger.
2. Read one approved queue item. For the first test, accept a manually supplied JSON item; do not invent a connected database.
3. Validate required fields: campaign_id, offer_url, product_claims_source, platform, script, caption, disclosure, approval_status, and asset_status.
4. Stop if approval_status is not `approved`, required data is missing, or a claim is unverified.
5. Deduplicate by campaign_id and platform. Record the outcome.
6. Call the OpenManus video endpoint only after verifying the base URL and health endpoint. Keep credentials in n8n credentials/environment, never in JSON or logs.
7. Validate the response and rendered MP4 (exists, non-empty, valid duration and 1080x1920 when applicable). Fail loudly if the service returns a stub or error.
8. Save a result record: campaign_id, status, asset path/URL, timestamp, error, and any actual publish URL.
9. Default to `prepared_for_review` or `draft`. Do not enable live posting in the initial workflow.
10. Add an Error Trigger workflow that reports the failed execution and node without exposing secrets.
11. Add a daily report based only on observed workflow records and verified sales metrics. Keep unknown metrics as unknown, not zero.
12. Provide importable workflow JSON, exact environment variables, test payload, expected result, failure test, and rollback instructions. Never report a step as connected until a real test passes.

## Minimal test payload

```json
{
  "campaign_id": "plg-test-001",
  "offer_name": "TEST OFFER — replace after verifying Gumroad catalog",
  "offer_url": "https://example.invalid/replace-with-verified-product-url",
  "product_claims_source": "manual_review_required",
  "platform": "manual_review",
  "script": "TEST ONLY — do not publish",
  "caption": "TEST ONLY",
  "disclosure": "Add the correct disclosure for the offer",
  "approval_status": "pending",
  "asset_status": "not_created"
}
```

This payload is intentionally invalid for publishing. It should be stopped by approval/URL validation. Replace the placeholder only after checking the actual product page.

## Concrete setup checklist

1. Open the repository: https://github.com/planlifegrateful-lang/Planlife-agent0-openmanus
2. In GitHub, open `n8n/full-pipeline-cloud.json` and review its existing placeholder URLs before importing. Do not run it as-is.
3. Open the existing n8n workspace only if you can sign in. Import the JSON as a new workflow or duplicate into a test workflow; retain the original. Replace placeholder endpoints only with verified reachable service URLs.
4. In OpenManus, use the documented local startup path for your environment. Confirm the health route and test video endpoint before connecting n8n. Localhost URLs are not reachable from n8n Cloud; use a secure, authenticated HTTPS endpoint if the services are remote. Never expose an unauthenticated local service to the public internet.
5. Open Gumroad seller dashboard manually if no authorized seller connector is available. Confirm the real product URL, published status, price, delivery file, payout status, and checkout. Do not paste seller tokens into chat.
6. In Muse, check connected apps and permissions. Ask it to research/draft, not to assume access to Gumroad or to publish.
7. Run a test with the invalid payload above. Expected result: workflow stops safely, logs a validation failure, and publishes nothing.
8. Run a second test with a verified URL and a reviewed script but approval_status=pending. Expected result: it still stops before rendering/publishing.
9. Only after these tests pass, approve one real item and create a video draft. Manually inspect the video and publish through a supported, authorized route.
10. Compare views, qualified clicks, verified orders, fees, and net revenue after a defined test window. Scale only the content/offer with evidence.

## Definition of done

- Existing offer and its checkout URL verified.
- Muse access and connected apps truthfully inventoried.
- n8n workflow imported and test executions pass.
- OpenManus health and MP4 generation tested.
- Duplicate prevention and failure alerts tested.
- One approved video rendered and reviewed.
- Publishing status/URL logged only when confirmed.
- Revenue reported from actual order data, with costs separated.
