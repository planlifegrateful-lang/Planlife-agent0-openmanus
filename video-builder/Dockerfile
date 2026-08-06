FROM python:3.11-slim

WORKDIR /app

# System deps for real video generation (zero API)
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    espeak-ng \
    && rm -rf /var/lib/apt/lists/*

COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

COPY app.py /app/

RUN useradd -m -u 1000 appuser && \
    mkdir -p /data/output /tmp/work && \
    chown -R appuser:appuser /app /data /tmp/work

USER appuser

EXPOSE 8001

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
  CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8001/health')" || exit 1

CMD ["python", "app.py"]
