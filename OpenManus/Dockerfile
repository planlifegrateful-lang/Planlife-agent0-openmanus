# OpenManus placeholder Dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir flask
EXPOSE 8002
CMD ["python", "-m", "http.server", "8002"]
