# Temu + PlanLifeGrateful-Lang Full UGC Auto-Pilot System

Ready for your video-builder pipeline.
Feed any of these title + script pairs into /build or the webhook.

## Dual Revenue Rules
- Every video ends with Temu link/code + PlanLifeGrateful-Lang CTA
- Bio order: 1. PlanLifeGrateful-Lang  2. Temu finds + codes
- Pinned comment always dual

## Video 1 – Deal Finder (Highest Converting)
**Title:** Temu Deal Finder $47 to $9
**Script:** Stop scrolling if you are still paying full price. This exact thing is forty seven dollars everywhere else. I got it on Temu for eight ninety nine. Came in eight days. Feels solid. Already ordered two more colors. Link and my code is in bio. And if you want the daily system that keeps your life from falling apart — PlanLifeGrateful-Lang is right there too.

## Video 2 – Honest Test
**Title:** Honest Temu Review Day 1 vs Day 7
**Script:** I ordered the viral Temu product so you do not waste money. Day one. Day seven results. Final verdict: actually good. Link and code in bio. And if your days still feel chaotic even when the finds are cheap — PlanLifeGrateful-Lang is the system I use.

## Video 3 – Soft Bridge
**Title:** Temu Saves Money PlanLifeGrateful Saves Energy
**Script:** Temu is great for saving money on stuff. But if your actual days still feel messy, the finds do not fix that. That is why I built PlanLifeGrateful-Lang. Both are in bio. Temu links and the full plan.

## Video 4 – Haul
**Title:** Forty Five Dollar Temu Haul
**Script:** Forty five dollar Temu haul that replaced a bunch of overpriced stuff. Full list and codes in bio. And the system that keeps me from buying random crap every week? PlanLifeGrateful-Lang — also in bio.

## Video 5 – Direct Plan Push
**Title:** PlanLifeGrateful-Lang Under Ten Minutes
**Script:** I got tired of starting over every Monday. So I built PlanLifeGrateful-Lang — under ten minutes a day. Link is in bio. Temu finds are there too if you want the money-saving side.

## Video 6 – Islamic Gratitude Bridge (from grateful-life-plan)
**Title:** With Hardship Comes Ease + Temu Finds
**Script:** With hardship comes ease. I used this verse for seven days and everything shifted. Alhamdulillah for the difficulty — ease is already written. Temu finds and the full PlanLifeGrateful-Lang system are both in bio.

## Video 7 – Language Upgrade
**Title:** Stop Saying Im Stressed Start Saying This
**Script:** Stop saying I am stressed. Start saying Alhamdulillah for this test — ease is coming. That language rewires the heart. The full PlanLifeGrateful-Lang system with daily grateful language is in bio. Temu codes are there too.

## Pinned Comment Template (use on every post)
Temu search: [PRODUCT]
Code: [YOURCODE]
Link: [YOUR LINK]

PlanLifeGrateful-Lang → also in bio

## How to Generate the Videos
curl -X POST http://127.0.0.1:8001/build \
  -H "Content-Type: application/json" \
  -d '{"title":"Temu Deal Finder $47 to $9","script":"Stop scrolling if you are still paying full price..."}'

Or feed through your Otto dashboard / n8n / webhook.

Videos land in ./output/
