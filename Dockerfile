FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

WORKDIR /app

# System dependencies required by OpenCV + ffmpeg
RUN apt-get update && apt-get install -y --no-install-recommends \
    ffmpeg \
    libgl1 \
    libglib2.0-0 \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Upgrade pip tooling
RUN pip install --no-cache-dir --upgrade pip setuptools wheel

# Install Python dependencies
RUN pip install --no-cache-dir \
    numpy==1.26.4 \
    opencv-python-headless==4.9.0.80 \
    fastapi==0.104.1 \
    "uvicorn[standard]"==0.24.0 \
    gunicorn==21.2.0 \
    ffmpeg-python==0.2.0 \
    pillow==10.1.0

COPY app.py .

EXPOSE 8000

HEALTHCHECK --interval=30s --timeout=10s --start-period=30s --retries=3 \
    CMD curl -f http://localhost:8000/health || exit 1


CMD ["gunicorn", \
     "-k", "uvicorn.workers.UvicornWorker", \
     "--workers", "4", \
     "--threads", "2", \
     "--timeout", "60", \
     "--bind", "0.0.0.0:8000", \
     "app:app"]

