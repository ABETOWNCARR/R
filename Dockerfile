# ── Stage 1: Build Flutter Web ───────────────────────────────────────────────
FROM ubuntu:22.04 AS flutter-build

ENV DEBIAN_FRONTEND=noninteractive
ENV FLUTTER_VERSION=3.22.0
ENV FLUTTER_HOME=/flutter
ENV PATH="${FLUTTER_HOME}/bin:${PATH}"

RUN apt-get update && apt-get install -y \
    curl git unzip xz-utils zip libglu1-mesa \
    && rm -rf /var/lib/apt/lists/*

RUN git clone https://github.com/flutter/flutter.git \
    --branch ${FLUTTER_VERSION} --depth 1 ${FLUTTER_HOME}

RUN flutter precache --web
RUN flutter config --enable-web

WORKDIR /app
COPY . .

RUN flutter pub get
RUN flutter build web --release --no-tree-shake-icons

# ── Stage 2: Python FastAPI Backend ──────────────────────────────────────────
FROM python:3.11-slim AS backend-build

WORKDIR /backend
COPY backend/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY backend/main.py .

# ── Stage 3: Final image — nginx serves Flutter, FastAPI runs alongside ───────
FROM python:3.11-slim

RUN apt-get update && apt-get install -y nginx gettext-base \
    && rm -rf /var/lib/apt/lists/*

COPY backend/requirements.txt /backend/requirements.txt
RUN pip install --no-cache-dir -r /backend/requirements.txt

COPY --from=backend-build /backend/main.py /backend/main.py
COPY --from=flutter-build /app/build/web /usr/share/nginx/html

# nginx config — uses $PORT from Railway, falls back to 80
RUN cat > /etc/nginx/sites-available/default << 'NGINX'
server {
    listen ${PORT:-80};
    server_name _;

    root /usr/share/nginx/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }

    location /api/ {
        rewrite ^/api/(.*) /$1 break;
        proxy_pass http://127.0.0.1:8000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
    }
}
NGINX

# Startup script — substitutes $PORT, starts FastAPI + nginx
RUN cat > /start.sh << 'SCRIPT'
#!/bin/bash
# Substitute Railway's $PORT into nginx config (default 80 if not set)
sed -i "s/listen \${PORT:-80};/listen ${PORT:-80};/" /etc/nginx/sites-available/default

# Start FastAPI backend in background on port 8000
cd /backend
uvicorn main:app --host 127.0.0.1 --port 8000 &

# Start nginx in foreground
nginx -g "daemon off;"
SCRIPT

RUN chmod +x /start.sh

EXPOSE 80

CMD ["/start.sh"]
