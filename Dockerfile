FROM debian:13.4

# Install system dependencies in one layer, clear APT cache
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        build-essential nodejs npm python3 python3-pip ripgrep ffmpeg gcc python3-dev libffi-dev && \
    rm -rf /var/lib/apt/lists/*

COPY . /opt/hermes
WORKDIR /opt/hermes

# Install Python and Node dependencies in one layer, no cache
# Використовуємо --break-system-packages для Debian 13+, щоб дозволити pip ставити пакети в систему
RUN pip install --no-cache-dir -e ".[all]" --break-system-packages && \
    npm install --prefer-offline --no-audit && \
    npx playwright install --with-deps chromium --only-shell && \
    cd /opt/hermes/scripts/whatsapp-bridge && \
    npm install --prefer-offline --no-audit && \
    npm cache clean --force

WORKDIR /opt/hermes

# Створюємо папку для даних та надаємо права (важливо для збереження пам'яті агента)
RUN mkdir -p /opt/data && chmod 777 /opt/data

ENV HERMES_HOME=/opt/data
VOLUME [ "/opt/data" ]

# МІНЯЄМО ТУТ:
# Замість ENTRYPOINT (який запускає термінальний чат), запускаємо gateway.
# Це дозволить агенту працювати як сервер для Telegram на Render.
CMD ["hermes", "gateway"]
