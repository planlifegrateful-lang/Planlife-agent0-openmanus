from flask import Flask, request, jsonify
import os
import requests

app = Flask(__name__)
VIDEO_BUILDER_URL = os.environ.get('VIDEO_BUILDER_URL', 'http://localhost:8001/build')

@app.route('/webhook', methods=['POST'])
def webhook():
    payload = request.json or {}
    # Forward to video builder
    try:
        resp = requests.post(VIDEO_BUILDER_URL, json=payload, timeout=30)
        return (resp.text, resp.status_code, {'Content-Type': 'application/json'})
    except requests.RequestException as e:
        return jsonify({'status': 'error', 'reason': str(e)}), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
