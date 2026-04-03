#!/bin/bash

# 1. Створюємо папку конфігу в домашній директорії root
mkdir -p /root/.hermes

# 2. Створюємо config.yaml прямо перед запуском
# Використовуємо змінні оточення, які ти вказав у Render
cat <<EOF > /root/.hermes/config.yaml
model:
  default: "${MODEL_NAME:-qwen/qwen-2.5-72b-instruct}"
  provider: "openrouter"
  base_url: "https://openrouter.ai/api/v1"

gateway:
  model: "${MODEL_NAME:-qwen/qwen-2.5-72b-instruct}"
EOF

# 3. Виводимо конфіг у лог для перевірки (щоб ти бачив, що він є)
echo "--- Generated Config ---"
cat /root/.hermes/config.yaml
echo "------------------------"

# 4. Запускаємо шлюз
exec hermes gateway run
