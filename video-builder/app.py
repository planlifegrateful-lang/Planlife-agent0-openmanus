from flask import Flask, request, jsonify
import os
import time
import logging
import subprocess
import textwrap
import shutil
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

# Native-friendly defaults (Docker still works via env)
OUTPUT_DIR = os.environ.get("OUTPUT_DIR", os.path.join(os.getcwd(), "output"))
WORK_DIR = os.environ.get("WORK_DIR", "/tmp/planlife-work")

# Vertical 9:16 for shorts
WIDTH, HEIGHT = 1080, 1920
BG_COLORS = [
    (15, 23, 42),    # slate
    (30, 27, 75),    # indigo
    (20, 40, 30),    # forest
    (40, 20, 30),    # wine
]

def safe_name(title: str) -> str:
    return "".join(c if c.isalnum() or c in (" ", "-", "_") else "_" for c in title).strip() or "video"

def get_font(size: int):
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception:
                continue
    return ImageFont.load_default()

def make_slide(text: str, bg: tuple, out_path: str, title_mode: bool = False):
    img = Image.new("RGB", (WIDTH, HEIGHT), bg)
    draw = ImageDraw.Draw(img)
    font_size = 72 if title_mode else 56
    font = get_font(font_size)

    max_chars = 28 if title_mode else 32
    lines = []
    for paragraph in text.split("\n"):
        lines.extend(textwrap.wrap(paragraph, width=max_chars) or [""])

    line_height = font_size + 18
    total_h = len(lines) * line_height
    y = (HEIGHT - total_h) // 2

    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        w = bbox[2] - bbox[0]
        x = (WIDTH - w) // 2
        draw.text((x + 3, y + 3), line, font=font, fill=(0, 0, 0))
        draw.text((x, y), line, font=font, fill=(240, 240, 245))
        y += line_height

    img.save(out_path, "PNG")

def split_script(script: str, max_chunks: int = 5):
    parts = [p.strip() for p in script.replace("!", ".").replace("?", ".").split(".") if p.strip()]
    if not parts:
        parts = [script.strip() or "Create. Ship. Repeat."]
    if len(parts) > max_chunks:
        head = parts[: max_chunks - 1]
        tail = " ".join(parts[max_chunks - 1 :])
        parts = head + [tail]
    return parts

def run_cmd(cmd: list, timeout: int = 120):
    logger.info("CMD: %s", " ".join(cmd))
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    if result.returncode != 0:
        logger.error("stderr: %s", result.stderr)
        raise RuntimeError(f"Command failed: {cmd[0]} → {result.stderr[:400]}")
    return result

def build_video(title: str, script: str) -> dict:
    ts = int(time.time())
    name = safe_name(title).replace(" ", "_")
    work = Path(WORK_DIR) / f"job_{ts}"
    work.mkdir(parents=True, exist_ok=True)
    out_dir = Path(OUTPUT_DIR)
    out_dir.mkdir(parents=True, exist_ok=True)

    final_mp4 = out_dir / f"{name}_{ts}.mp4"

    try:
        wav_path = work / "voice.wav"
        speak_text = f"{title}. {script}"
        tts_bin = "espeak-ng" if shutil.which("espeak-ng") else "espeak"
        run_cmd([
            tts_bin,
            "-s", "145",
            "-a", "140",
            "-w", str(wav_path),
            speak_text,
        ])

        chunks = split_script(script)
        slide_paths = []
        bg = BG_COLORS[ts % len(BG_COLORS)]

        title_slide = work / "slide_00.png"
        make_slide(title, bg, str(title_slide), title_mode=True)
        slide_paths.append(title_slide)

        for i, chunk in enumerate(chunks):
            p = work / f"slide_{i+1:02d}.png"
            make_slide(chunk, bg, str(p))
            slide_paths.append(p)

        probe = run_cmd([
            "ffprobe", "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            str(wav_path),
        ])
        duration = float(probe.stdout.strip() or "5")
        per_slide = max(1.5, duration / len(slide_paths))

        list_file = work / "slides.txt"
        with open(list_file, "w") as f:
            for p in slide_paths:
                f.write(f"file '{p}'\n")
                f.write(f"duration {per_slide:.2f}\n")
            f.write(f"file '{slide_paths[-1]}'\n")

        silent_video = work / "silent.mp4"
        run_cmd([
            "ffmpeg", "-y",
            "-f", "concat", "-safe", "0",
            "-i", str(list_file),
            "-vf", f"scale={WIDTH}:{HEIGHT},format=yuv420p",
            "-r", "30",
            "-c:v", "libx264", "-preset", "veryfast", "-crf", "23",
            str(silent_video),
        ])

        run_cmd([
            "ffmpeg", "-y",
            "-i", str(silent_video),
            "-i", str(wav_path),
            "-c:v", "copy",
            "-c:a", "aac", "-b:a", "128k",
            "-shortest",
            str(final_mp4),
        ])

        size = final_mp4.stat().st_size if final_mp4.exists() else 0
        logger.info("Built real video: %s (%s bytes)", final_mp4.name, size)

        return {
            "status": "ok",
            "filename": final_mp4.name,
            "path": str(final_mp4),
            "title": title,
            "duration_sec": round(duration, 1),
            "slides": len(slide_paths),
            "size_bytes": size,
            "mode": "local-zero-api",
            "note": "Real MP4 with offline TTS + slides. No API keys used.",
        }
    finally:
        shutil.rmtree(work, ignore_errors=True)

@app.route("/health", methods=["GET"])
def health():
    return jsonify({
        "status": "ok",
        "service": "video-builder",
        "mode": "local-zero-api",
        "tts": "espeak-ng",
        "video": "ffmpeg + pillow",
        "output_dir": OUTPUT_DIR,
    })

@app.route("/build", methods=["POST"])
def build():
    data = request.get_json(silent=True) or {}
    title = data.get("title") or data.get("topic") or "Untitled"
    script = data.get("script") or data.get("prompt") or data.get("text") or "Create something great today."

    try:
        result = build_video(title, script)
        return jsonify(result)
    except Exception as e:
        logger.exception("Build failed")
        return jsonify({"status": "error", "reason": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8001))
    app.run(host="0.0.0.0", port=port)
