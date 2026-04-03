FROM debian:13.4

# Встановлення системних залежностей
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-pip ripgrep ffmpeg gcc python3-dev libffi-dev curl && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/hermes
WORKDIR /opt/hermes

# Встановлення Python та Node залежностей
RUN pip install --no-cache-dir -e ".[all]" "python-telegram-bot[webhooks]" --break-system-packages && \
    npm install --prefer-offline --no-audit && \
    npx playwright install --with-deps chromium --only-shell && \
    cd /opt/hermes/scripts/whatsapp-bridge && \
    npm install --prefer-offline --no-audit && \
    npm cache clean --force

# Робимо скрипт запуску виконуваним
RUN chmod +x /opt/hermes/start.sh

# На Render ми НЕ використовуємо VOLUME для конфігів, якщо не маємо платного диска
# Тому просто запускаємо наш скрипт
CMD ["/opt/hermes/start.sh"]
