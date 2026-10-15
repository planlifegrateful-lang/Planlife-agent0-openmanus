# Bing Video Creator → 2-Minute Local Video Workflow

This folder adds a **local clip assembler** to Planlife's existing zero-API video pipeline. It does not replace the current video builder or duplicate the content agent.

## What it does

1. You generate clips in Bing Video Creator using your Microsoft account.
2. You download the clips yourself and place them in `bing-workflow/input/`.
3. A local Python script uses FFmpeg to combine them into one vertical 1080×1920 MP4.
4. Clips are sorted by filename (`clip01.mp4`, `clip02.mp4`, …) and kept at their natural durations. If the total clip runtime is under two minutes, the ordered clip sequence repeats until the target length is reached; the final clip is trimmed to fit exactly.
5. Optionally, add a music file you have permission to use. Music is mixed at 18% volume and faded out at the end.

**Important limitations:** This does not call Bing, automate Bing sign-in/downloads, or bypass any generation limits. It cannot make Bing itself unlimited. Bing's available features and limits are controlled by Microsoft. The output is silent unless you pass `--music`; add narration/captions in your preferred editor afterward.

## Quick start

Requirements: Python 3.10+ and FFmpeg/FFprobe installed and available on PATH. The assembler uses only Python's standard library; no Python packages or API keys are needed.

### 1. Prepare your clips

Create the folder `bing-workflow/input` and copy your downloaded clips into it. Use a numbered order:

```text
bing-workflow/input/
  clip01.mp4
  clip02.mp4
  clip03.mp4
  clip04.mp4
```

Use filenames in the order you want them to appear. The tool accepts MP4, MOV, M4V, WEBM, and MKV.

### 2. Assemble a 2-minute master

From the repository root:

```bash
python3 bing-workflow/assemble.py
```

The file will be saved to `output/bing-master-2min.mp4`. The tool checks that the MP4 exists and that its duration is approximately 120 seconds.

### 3. Add licensed background music (optional)

```bash
python3 bing-workflow/assemble.py --music "path/to/licensed-music.mp3"
```

### 4. Change the length for testing or other platforms

```bash
python3 bing-workflow/assemble.py --duration 60 --output output/bing-60s.mp4
python3 bing-workflow/assemble.py --duration 120 --fps 30 --output output/bing-master-2min.mp4
```

## Recommended 2-minute story plan

Generate enough distinct clips to support this pacing. The assembler distributes time evenly; this scene plan is a creative guide, not automatic scene recognition.

| Time | Purpose | Example visual |
|---|---|---|
| 0–5 s | Hook | A striking visual that creates a question |
| 5–20 s | Relatable problem | The everyday struggle or product use case |
| 20–45 s | Curiosity | Detail shots, new angles, escalating question |
| 45–75 s | Turning point | Reveal, demonstration, or change in perspective |
| 75–100 s | Useful payoff | Three clear tips or the key product details |
| 100–112 s | Memorable close | The main lesson or product in use |
| 112–120 s | CTA | Invite a relevant next action without pressure |

For product videos, only state benefits supported by the label or reliable evidence. Disclose affiliate relationships where required. Do not invent results, testimonials, discounts, or health claims.

## Troubleshooting

- **No clips found:** check that files are inside `bing-workflow/input/` and use a supported extension.
- **FFmpeg not found:** install FFmpeg and ensure both `ffmpeg` and `ffprobe` are on PATH.
- **Wrong order:** rename clips with zero-padded numbers (`clip01`, `clip02`, …).
- **Export is silent:** expected unless you pass `--music`; add licensed narration/music in your editor.
- **Black bars/cropping:** the tool fills 9:16 by cropping to 1080×1920; important content near the edges may be cropped.
- **Bing unavailable or limits changed:** this tool only assembles files you already downloaded. It does not alter Bing availability or restrictions.

## Validation

The GitHub Actions workflow creates temporary synthetic clips, assembles a short test video, and checks the output duration. It does not access Bing or publish anything.
