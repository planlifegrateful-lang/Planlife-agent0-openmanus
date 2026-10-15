import importlib.util
import shutil
import subprocess
import tempfile
import unittest
from pathlib import Path

SCRIPT = Path(__file__).resolve().parents[1] / "assemble.py"
SPEC = importlib.util.spec_from_file_location("bing_assemble", SCRIPT)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class DurationTests(unittest.TestCase):
    def test_duration_is_distributed(self):
        parts = MODULE.segment_durations(120, 7)
        self.assertEqual(len(parts), 7)
        self.assertAlmostEqual(sum(parts), 120)
        self.assertTrue(all(p > 0 for p in parts))

    def test_invalid_duration_rejected(self):
        with self.assertRaises(ValueError):
            MODULE.segment_durations(0, 2)

    def test_natural_sort(self):
        names = sorted(
            [Path("clip10.mp4"), Path("clip2.mp4"), Path("clip1.mp4")],
            key=MODULE.natural_key,
        )
        self.assertEqual([p.name for p in names],
                         ["clip1.mp4", "clip2.mp4", "clip10.mp4"])


@unittest.skipUnless(shutil.which("ffmpeg") and shutil.which("ffprobe"),
                     "FFmpeg/FFprobe not installed")
class IntegrationTests(unittest.TestCase):
    def test_builds_vertical_video_with_expected_duration(self):
        with tempfile.TemporaryDirectory() as tmp:
            root = Path(tmp)
            source = root / "input"
            source.mkdir()
            for i, color in enumerate(("red", "blue", "green"), start=1):
                subprocess.run([
                    "ffmpeg", "-hide_banner", "-loglevel", "error", "-y",
                    "-f", "lavfi", "-i", f"color=c={color}:s=320x240:r=15",
                    "-t", "1", "-an", "-c:v", "libx264", "-pix_fmt", "yuv420p",
                    str(source / f"clip{i:02d}.mp4"),
                ], check=True, capture_output=True)
            output = root / "out" / "result.mp4"
            result = MODULE.assemble(source, output, duration=6)
            self.assertEqual(result["status"], "ok")
            self.assertEqual(result["resolution"], "1080x1920")
            self.assertEqual(result["clip_count"], 3)
            self.assertAlmostEqual(result["duration_seconds"], 6, delta=0.25)
            probe = subprocess.run([
                "ffprobe", "-v", "error", "-select_streams", "v:0",
                "-show_entries", "stream=width,height", "-of", "csv=s=x:p=0",
                str(output),
            ], check=True, text=True, capture_output=True)
            self.assertEqual(probe.stdout.strip(), "1080x1920")


if __name__ == "__main__":
    unittest.main()
