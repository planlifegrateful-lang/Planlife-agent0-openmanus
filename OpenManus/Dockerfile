# OpenManus placeholder service
FROM python:3.11-slim

WORKDIR /app

RUN pip install --no-cache-dir flask

# Minimal health + info endpoint so the service is useful in the stack
RUN cat > /app/app.py << 'EOF'
from flask import Flask, jsonify
import os
app = Flask(__name__)

@app.route('/')
def index():
    return jsonify({
        "service": "OpenManus",
        "status": "placeholder",
        "message": "Replace this image with real OpenManus agent implementation"
    })

@app.route('/health')
def health():
    return jsonify({"status": "ok", "service": "openmanus"})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=int(os.environ.get('PORT', 8002)))
EOF

RUN useradd -m -u 1000 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 8002

HEALTHCHECK --interval=30s --timeout=5s --start-period=5s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8002/health')" || exit 1

CMD ["python", "app.py"]
