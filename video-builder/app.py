from flask import Flask, request, jsonify
import os
import time
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

OUTPUT_DIR = os.environ.get('OUTPUT_DIR', '/data/output')

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "service": "video-builder"})

@app.route('/build', methods=['POST'])
def build_video():
    data = request.get_json(silent=True) or {}
    title = data.get('title', 'untitled')
    # Sanitize title for filename
    safe_title = "".join(c if c.isalnum() or c in (' ', '-', '_') else '_' for c in title).strip() or 'untitled'
    timestamp = int(time.time())
    filename = f"{safe_title.replace(' ', '_')}_{timestamp}.mp4"
    outpath = os.path.join(OUTPUT_DIR, filename)

    try:
        os.makedirs(OUTPUT_DIR, exist_ok=True)
        # Placeholder: write a minimal valid-ish MP4-like header + marker
        # Real implementation would call OpenManus / ffmpeg pipeline here
        with open(outpath, 'wb') as f:
            f.write(b"\x00\x00\x00\x18ftypmp42\x00\x00\x00\x00mp42isom")
            f.write(b"\nOPENMANUS-VIDEO-PLACEHOLDER\n")
            f.write(f"title={title}\ntimestamp={timestamp}\n".encode())

        logger.info(f"Built placeholder video: {filename}")
        return jsonify({
            "status": "ok",
            "filename": filename,
            "path": outpath,
            "title": title,
            "note": "Placeholder output. Replace with real video pipeline."
        })
    except Exception as e:
        logger.exception("Build failed")
        return jsonify({"status": "error", "reason": str(e)}), 500

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8001))
    app.run(host='0.0.0.0', port=port)
