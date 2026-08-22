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
logging.basicConfig(level=logging.INFO, format="%(asctime)s [%(levelname)s] %(message)s")
logger = logging.getLogger(__name__)

# ── Config ──────────────────────────────────────────────────────────────────
OUTPUT_DIR = os.environ.get("OUTPUT_DIR", os.path.join(os.getcwd(), "output"))
WORK_DIR = os.environ.get("WORK_DIR", "/tmp/planlife-work")
TTS_ENGINE = os.environ.get("TTS_ENGINE", "auto").lower()  # auto | chatterbox | espeak | elevenlabs
VOICE_REF_PATH = os.environ.get("VOICE_REF_PATH", "")
ELEVENLABS_API_KEY = os.environ.get("ELEVENLABS_API_KEY", "")
ELEVENLABS_VOICE_ID = os.environ.get("ELEVENLABS_VOICE_ID", "21m00Tcm4TlvDq8ikWAM")

WIDTH, HEIGHT = 1080, 1920
BG_COLORS = [
    (15, 23, 42),   # deep navy
    (20, 40, 30),   # dark green
    (30, 27, 75),   # deep purple
    (40, 20, 30),   # dark maroon
    (12, 35, 28),   # forest
]

# ── TTS Engines ─────────────────────────────────────────────────────────────
_chatterbox_model = None

def get_chatterbox():
    global _chatterbox_model
    if _chatterbox_model is not None:
        return _chatterbox_model
    try:
        import torch
        from chatterbox.tts import ChatterboxTTS
        device = "cuda" if torch.cuda.is_available() else "cpu"
        logger.info(f"Loading Chatterbox TTS on {device}...")
        _chatterbox_model = ChatterboxTTS.from_pretrained(device=device)
        logger.info("Chatterbox ready")
        return _chatterbox_model
    except Exception as e:
        logger.warning(f"Chatterbox not available: {e}")
        return None

def tts_espeak(text: str, wav_path: Path):
    tts_bin = "espeak-ng" if shutil.which("espeak-ng") else "espeak"
    if not shutil.which(tts_bin):
        raise RuntimeError("espeak-ng / espeak not found")
    run_cmd([tts_bin, "-s", "145", "-a", "140", "-w", str(wav_path), text])

def tts_chatterbox(text: str, wav_path: Path):
    model = get_chatterbox()
    if model is None:
        raise RuntimeError("Chatterbox model failed to load")
    import torchaudio as ta
    kwargs = {}
    if VOICE_REF_PATH and Path(VOICE_REF_PATH).exists():
        kwargs["audio_prompt_path"] = VOICE_REF_PATH
        logger.info(f"Cloning voice from {VOICE_REF_PATH}")
    wav = model.generate(text, **kwargs)
    ta.save(str(wav_path), wav, model.sr)

def tts_elevenlabs(text: str, wav_path: Path):
    if not ELEVENLABS_API_KEY:
        raise RuntimeError("ELEVENLABS_API_KEY not set")
    import requests
    url = f"https://api.elevenlabs.io/v1/text-to-speech/{ELEVENLABS_VOICE_ID}"
    headers = {
        "Accept": "audio/mpeg",
        "Content-Type": "application/json",
        "xi-api-key": ELEVENLABS_API_KEY,
    }
    payload = {
        "text": text,
        "model_id": "eleven_multilingual_v2",
        "voice_settings": {"stability": 0.5, "similarity_boost": 0.75},
    }
    r = requests.post(url, json=payload, headers=headers, timeout=60)
    r.raise_for_status()
    mp3_path = wav_path.with_suffix(".mp3")
    mp3_path.write_bytes(r.content)
    run_cmd(["ffmpeg", "-y", "-i", str(mp3_path), str(wav_path)])
    mp3_path.unlink(missing_ok=True)

def synthesize_voice(text: str, wav_path: Path) -> str:
    engine = TTS_ENGINE
    if engine == "auto":
        if get_chatterbox() is not None:
            engine = "chatterbox"
        else:
            engine = "espeak"

    logger.info(f"TTS engine: {engine}")
    if engine == "chatterbox":
        tts_chatterbox(text, wav_path)
    elif engine == "elevenlabs":
        tts_elevenlabs(text, wav_path)
    else:
        tts_espeak(text, wav_path)

    # Safety: ensure audio file exists and has size
    if not wav_path.exists() or wav_path.stat().st_size < 100:
        raise RuntimeError(f"TTS produced empty/invalid audio: {wav_path}")
    return engine

# ── Helpers ─────────────────────────────────────────────────────────────────
def safe_name(title: str) -> str:
    return "".join(c if c.isalnum() or c in (" ", "-", "_") else "_" for c in title).strip() or "video"

def get_font(size: int):
    candidates = [
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Bold.ttf",
        "/usr/share/fonts/truetype/liberation/LiberationSans-Regular.ttf",
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/usr/share/fonts/truetype/freefont/FreeSansBold.ttf",
    ]
    for path in candidates:
        if os.path.exists(path):
            try:
                return ImageFont.truetype(path, size)
            except Exception as e:
                logger.warning(f"Font load failed {path}: {e}")
                continue
    logger.warning("Falling back to default font — text may be small")
    return ImageFont.load_default()

def make_slide(text: str, bg: tuple, out_path: str, title_mode: bool = False):
    """Guaranteed visible text on solid background. Never black."""
    img = Image.new("RGB", (WIDTH, HEIGHT), bg)
    draw = ImageDraw.Draw(img)

    # Larger, safer sizes
    font_size = 68 if title_mode else 52
    font = get_font(font_size)
    max_chars = 26 if title_mode else 30

    lines = []
    for paragraph in text.split("\n"):
        wrapped = textwrap.wrap(paragraph, width=max_chars) or [""]
        lines.extend(wrapped)

    if not lines:
        lines = ["Taqwa Balance"]

    line_height = font_size + 20
    total_h = len(lines) * line_height
    y = max(80, (HEIGHT - total_h) // 2)

    for line in lines:
        bbox = draw.textbbox((0, 0), line, font=font)
        w = bbox[2] - bbox[0]
        x = (WIDTH - w) // 2
        # Strong shadow for contrast
        draw.text((x + 4, y + 4), line, font=font, fill=(0, 0, 0))
        draw.text((x, y), line, font=font, fill=(245, 245, 250))
        y += line_height

    # Safety bar at bottom so we never ship pure black
    draw.rectangle([0, HEIGHT - 12, WIDTH, HEIGHT], fill=(201, 162, 39))

    img.save(out_path, "PNG", optimize=False)
    if not Path(out_path).exists() or Path(out_path).stat().st_size < 1000:
        raise RuntimeError(f"Slide write failed or too small: {out_path}")

def split_script(script: str, max_chunks: int = 6):
    parts = [p.strip() for p in script.replace("!", ".").replace("?", ".").split(".") if p.strip()]
    if not parts:
        parts = [script.strip() or "Clarity. Energy. True Balance."]
    if len(parts) > max_chunks:
        head = parts[: max_chunks - 1]
        tail = " ".join(parts[max_chunks - 1 :])
        parts = head + [tail]
    return parts

def run_cmd(cmd: list, timeout: int = 180):
    logger.info("CMD: %s", " ".join(str(c) for c in cmd))
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=timeout)
    if result.returncode != 0:
        logger.error("stderr: %s", result.stderr)
        raise RuntimeError(f"Command failed: {cmd[0]} → {result.stderr[:500]}")
    return result

# ── Core ────────────────────────────────────────────────────────────────────
def build_video(title: str, script: str) -> dict:
    ts = int(time.time())
    name = safe_name(title).replace(" ", "_")[:60]
    work = Path(WORK_DIR) / f"job_{ts}"
    work.mkdir(parents=True, exist_ok=True)
    out_dir = Path(OUTPUT_DIR)
    out_dir.mkdir(parents=True, exist_ok=True)
    final_mp4 = out_dir / f"{name}_{ts}.mp4"

    try:
        wav_path = work / "voice.wav"
        speak_text = f"{title}. {script}"[:800]  # safety length

        engine_used = synthesize_voice(speak_text, wav_path)

        # Probe duration with hard fallback
        probe = run_cmd([
            "ffprobe", "-v", "error",
            "-show_entries", "format=duration",
            "-of", "default=noprint_wrappers=1:nokey=1",
            str(wav_path),
        ])
        try:
            duration = float(probe.stdout.strip() or "0")
        except ValueError:
            duration = 0.0

        if duration < 1.5:
            logger.warning(f"Audio duration too short ({duration}s) — forcing minimum")
            duration = 8.0  # force usable length

        chunks = split_script(script)
        slide_paths = []
        bg = BG_COLORS[ts % len(BG_COLORS)]

        # Title slide
        title_slide = work / "slide_00.png"
        make_slide(title, bg, str(title_slide), title_mode=True)
        slide_paths.append(title_slide)

        for i, chunk in enumerate(chunks):
            p = work / f"slide_{i+1:02d}.png"
            make_slide(chunk, bg, str(p))
            slide_paths.append(p)

        per_slide = max(1.8, duration / max(len(slide_paths), 1))

        # Build concat list correctly
        list_file = work / "slides.txt"
        with open(list_file, "w") as f:
            for p in slide_paths:
                f.write(f"file '{p.resolve()}'\n")
                f.write(f"duration {per_slide:.3f}\n")
            # Last frame must be repeated for concat demuxer
            f.write(f"file '{slide_paths[-1].resolve()}'\n")

        silent_video = work / "silent.mp4"
        # Hardened ffmpeg: force yuv420p, scale, keyframes, no black frames
        run_cmd([
            "ffmpeg", "-y",
            "-f", "concat", "-safe", "0",
            "-i", str(list_file),
            "-vf", f"scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=decrease,pad={WIDTH}:{HEIGHT}:(ow-iw)/2:(oh-ih)/2,format=yuv420p",
            "-r", "30",
            "-c:v", "libx264",
            "-preset", "veryfast",
            "-crf", "20",
            "-pix_fmt", "yuv420p",
            "-movflags", "+faststart",
            str(silent_video),
        ])

        # Mux audio — use -shortest but protect against zero
        run_cmd([
            "ffmpeg", "-y",
            "-i", str(silent_video),
            "-i", str(wav_path),
            "-c:v", "copy",
            "-c:a", "aac", "-b:a", "128k",
            "-shortest",
            "-movflags", "+faststart",
            str(final_mp4),
        ])

        size = final_mp4.stat().st_size if final_mp4.exists() else 0
        if size < 5000:
            raise RuntimeError(f"Output video too small ({size} bytes) — likely black/empty")

        logger.info("Built REAL video: %s (%s bytes) engine=%s duration=%.1fs", final_mp4.name, size, engine_used, duration)

        return {
            "status": "ok",
            "filename": final_mp4.name,
            "path": str(final_mp4),
            "title": title,
            "duration_sec": round(duration, 1),
            "slides": len(slide_paths),
            "size_bytes": size,
            "tts_engine": engine_used,
            "mode": "ai-voice-cloning" if engine_used != "espeak" else "local-zero-api",
            "note": f"Hardened MP4 with {engine_used} TTS + guaranteed visible slides.",
        }
    finally:
        shutil.rmtree(work, ignore_errors=True)

@app.route("/health", methods=["GET"])
def health():
    engines = ["espeak"]
    if get_chatterbox() is not None:
        engines.insert(0, "chatterbox")
    if ELEVENLABS_API_KEY:
        engines.append("elevenlabs")
    return jsonify({
        "status": "ok",
        "service": "video-builder",
        "tts_engine": TTS_ENGINE,
        "available_engines": engines,
        "voice_ref": bool(VOICE_REF_PATH and Path(VOICE_REF_PATH).exists()),
        "output_dir": OUTPUT_DIR,
        "fix": "black-videos-hard-fix-v1",
    })

@app.route("/build", methods=["POST"])
def build():
    data = request.get_json(silent=True) or {}
    title = data.get("title") or data.get("topic") or "Taqwa Balance"
    script = data.get("script") or data.get("prompt") or data.get("text") or "Clarity. Energy. True Balance. Clean ingredients. Real results."

    try:
        result = build_video(title, script)
        return jsonify(result)
    except Exception as e:
        logger.exception("Build failed")
        return jsonify({"status": "error", "reason": str(e)}), 500

if __name__ == "__main__":
    port = int(os.environ.get("PORT", 8001))
    app.run(host="0.0.0.0", port=port)
