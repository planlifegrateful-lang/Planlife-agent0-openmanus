#!/usr/bin/env python3
"""Assemble downloaded Bing Video Creator clips into one vertical MP4 using local FFmpeg.

No API, account token, cloud service, or paid model is used. Bing clip generation and
downloads remain manual; this tool only edits files the user already has.
"""
from __future__ import annotations

import argparse
import json
import re
import shutil
import subprocess
import sys
from pathlib import Path

VIDEO_EXTENSIONS = {".mp4", ".mov", ".m4v", ".webm", ".mkv"}
WIDTH = 1080
HEIGHT = 1920
FPS = 30


def natural_key(path: Path):
    """Sort clip_2 before clip_10, while keeping names predictable."""
    return [int(part) if part.isdigit() else part.lower()
            for part in re.split(r"(\d+)", path.name)]


def discover_clips(input_dir: Path) -> list[Path]:
    if not input_dir.exists() or not input_dir.is_dir():
        raise ValueError(f"Input folder does not exist: {input_dir}")
    clips = sorted(
        (p for p in input_dir.iterdir()
         if p.is_file() and p.suffix.lower() in VIDEO_EXTENSIONS),
        key=natural_key,
    )
    if not clips:
        raise ValueError(
            f"No video clips found in {input_dir}. "
            "Put downloaded Bing clips there (.mp4, .mov, .m4v, .webm, or .mkv)."
        )
    return clips


def build_playlist(clips: list[Path], source_durations: list[float],
                   total_seconds: float) -> list[tuple[Path, float]]:
    """Repeat the ordered clip sequence as needed, preserving natural clip lengths."""
    if total_seconds <= 0:
        raise ValueError("Duration must be greater than zero.")
    if not clips or len(clips) != len(source_durations):
        raise ValueError("At least one clip and its duration are required.")
    if any(seconds <= 0 for seconds in source_durations):
        raise ValueError("Every input clip must have a measurable duration greater than zero.")
    playlist = []
    remaining = total_seconds
    while remaining > 0.000001:
        for clip, source_seconds in zip(clips, source_durations):
            if remaining <= 0.000001:
                break
            segment = min(source_seconds, remaining)
            playlist.append((clip, segment))
            remaining -= segment
    return playlist


def run_checked(command: list[str]) -> subprocess.CompletedProcess:
    return subprocess.run(command, check=True, text=True, capture_output=True)


def probe_duration(path: Path) -> float:
    result = run_checked([
        "ffprobe", "-v", "error", "-show_entries", "format=duration",
        "-of", "json", str(path),
    ])
    data = json.loads(result.stdout)
    return float(data["format"]["duration"])


def assemble(input_dir: Path, output: Path, duration: float = 120,
             music: Path | None = None, fps: int = FPS) -> dict:
    """Create a 9:16 video with equal-time clip segments and optional background music."""
    if shutil.which("ffmpeg") is None or shutil.which("ffprobe") is None:
        raise RuntimeError("FFmpeg and FFprobe are required. Install FFmpeg and try again.")
    clips = discover_clips(input_dir)
    source_durations = [probe_duration(clip) for clip in clips]
    playlist = build_playlist(clips, source_durations, duration)
    if music is not None and (not music.is_file()):
        raise ValueError(f"Music file not found: {music}")
    if music is not None and music.resolve() == output.resolve():
        raise ValueError("Output file cannot also be the music input.")
    if any(clip.resolve() == output.resolve() for clip in clips):
        raise ValueError("Output file must be outside the input clip folder.")

    output.parent.mkdir(parents=True, exist_ok=True)
    command = ["ffmpeg", "-hide_banner", "-loglevel", "error", "-y"]
    for clip, _seconds in playlist:
        command.extend(["-i", str(clip)])
    if music is not None:
        command.extend(["-stream_loop", "-1", "-i", str(music)])

    filters = []
    video_labels = []
    for i, (clip, seconds) in enumerate(playlist):
        label = f"v{i}"
        filters.append(
            f"[{i}:v:0]scale={WIDTH}:{HEIGHT}:force_original_aspect_ratio=increase,"
            f"crop={WIDTH}:{HEIGHT},fps={fps},setsar=1,"
            f"trim=duration={seconds:.6f},setpts=PTS-STARTPTS[{label}]"
        )
        video_labels.append(f"[{label}]")
    filters.append(
        "".join(video_labels) + f"concat=n={len(clips)}:v=1:a=0[vout]"
    )

    if music is not None:
        music_index = len(playlist)
        fade_start = max(0, duration - min(2.0, duration / 4))
        fade_len = min(2.0, duration / 4)
        filters.append(
            f"[{music_index}:a:0]atrim=duration={duration:.6f},"
            f"asetpts=PTS-STARTPTS,volume=0.18,"
            f"afade=t=out:st={fade_start:.6f}:d={fade_len:.6f}[aout]"
        )

    command.extend([
        "-filter_complex", ";".join(filters),
        "-map", "[vout]",
    ])
    if music is not None:
        command.extend(["-map", "[aout]", "-c:a", "aac", "-b:a", "160k"])
    else:
        command.append("-an")
    command.extend([
        "-t", f"{duration:.6f}", "-c:v", "libx264", "-preset", "veryfast",
        "-crf", "23", "-pix_fmt", "yuv420p", "-r", str(fps),
        "-movflags", "+faststart", str(output),
    ])

    run_checked(command)
    if not output.exists() or output.stat().st_size < 1000:
        raise RuntimeError("FFmpeg finished but the output MP4 is missing or unexpectedly small.")
    actual_duration = probe_duration(output)
    if abs(actual_duration - duration) > max(0.25, 2 / fps):
        raise RuntimeError(
            f"Output duration check failed: expected {duration:.2f}s, "
            f"got {actual_duration:.2f}s."
        )
    return {
        "status": "ok",
        "output": str(output.resolve()),
        "clip_count": len(clips),
        "scene_count": len(playlist),
        "duration_seconds": round(actual_duration, 3),
        "resolution": f"{WIDTH}x{HEIGHT}",
        "fps": fps,
        "music_added": music is not None,
        "audio_note": "Background music added at 18% volume." if music else
                      "Export is silent. Add licensed music or narration in your editor.",
    }


def main() -> int:
    parser = argparse.ArgumentParser(
        description="Assemble downloaded Bing AI clips into a 2-minute vertical MP4 locally."
    )
    parser.add_argument("--input-dir", type=Path, default=Path("bing-workflow/input"),
                        help="Folder containing downloaded video clips.")
    parser.add_argument("--output", type=Path,
                        default=Path("output/bing-master-2min.mp4"),
                        help="Output MP4 path.")
    parser.add_argument("--duration", type=float, default=120,
                        help="Target duration in seconds (default: 120).")
    parser.add_argument("--music", type=Path, default=None,
                        help="Optional licensed music file; mixed at 18%% volume.")
    parser.add_argument("--fps", type=int, choices=(24, 25, 30, 50, 60), default=30)
    args = parser.parse_args()
    try:
        result = assemble(args.input_dir, args.output, args.duration, args.music, args.fps)
        print(json.dumps(result, indent=2))
        return 0
    except (ValueError, RuntimeError, subprocess.CalledProcessError) as exc:
        detail = getattr(exc, "stderr", None)
        print(f"ERROR: {exc}", file=sys.stderr)
        if detail:
            print(detail[-3000:], file=sys.stderr)
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
