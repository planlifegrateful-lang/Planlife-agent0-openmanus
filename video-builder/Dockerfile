FROM python:3.11-slim
WORKDIR /app

COPY app.py /app/
RUN pip install --no-cache-dir flask requests

EXPOSE 8001
CMD ["python", "app.py"]
