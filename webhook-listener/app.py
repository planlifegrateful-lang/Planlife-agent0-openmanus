from flask import Flask, request, jsonify
import os
import requests
import logging

app = Flask(__name__)
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

VIDEO_BUILDER_URL = os.environ.get('VIDEO_BUILDER_URL', 'http://video-builder:8001/build')

@app.route('/health', methods=['GET'])
def health():
    return jsonify({"status": "ok", "service": "webhook-listener", "forward_to": VIDEO_BUILDER_URL})

@app.route('/webhook', methods=['POST'])
def webhook():
    payload = request.get_json(silent=True) or {}
    logger.info(f"Received webhook payload keys: {list(payload.keys())}")

    try:
        resp = requests.post(VIDEO_BUILDER_URL, json=payload, timeout=60)
        logger.info(f"Forwarded to video-builder, status={resp.status_code}")
        return (resp.text, resp.status_code, {'Content-Type': 'application/json'})
    except requests.RequestException as e:
        logger.error(f"Forward failed: {e}")
        return jsonify({'status': 'error', 'reason': str(e)}), 502

if __name__ == '__main__':
    port = int(os.environ.get('PORT', 8000))
    app.run(host='0.0.0.0', port=port)
