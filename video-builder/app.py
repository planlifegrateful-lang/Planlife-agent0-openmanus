from flask import Flask, request, jsonify
import os
import time

app = Flask(__name__)
OUTPUT_DIR = os.environ.get('OUTPUT_DIR', '/data/output')

@app.route('/build', methods=['POST'])
def build_video():
    data = request.json or {}
    title = data.get('title', 'untitled')
    # Placeholder: emulate building a video
    timestamp = int(time.time())
    filename = f"{title.replace(' ', '_')}_{timestamp}.mp4"
    outpath = os.path.join(OUTPUT_DIR, filename)
    # Create output dir and a small placeholder file to represent a video
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    with open(outpath, 'wb') as f:
        f.write(b"OPENMANUS-VIDEO-PLACEHOLDER\n")

    return jsonify({"status": "ok", "filename": filename, "path": outpath})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8001)
