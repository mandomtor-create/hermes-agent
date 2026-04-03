#!/bin/bash

# 1. Створюємо папку для конфігу
mkdir -p /root/.hermes

# 2. Генеруємо config.yaml
# Ми додаємо MCP GitHub для коду та Filesystem для створення файлів (PowerPoint)
cat <<EOF > /root/.hermes/config.yaml
model:
  default: "${MODEL_NAME:-openai/gpt-oss-120b}"
  provider: "openrouter"
  base_url: "https://openrouter.ai/api/v1"

gateway:
  model: "${MODEL_NAME:-openai/gpt-oss-120b}"

mcp_servers:
  # MCP для роботи з GitHub (список репо, створення PR тощо)
  github:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-github"]
    env:
      GITHUB_PERSONAL_ACCESS_TOKEN: "${GITHUB_TOKEN}"

  # MCP для створення та запису файлів (потрібно для збереження .pptx)
  filesystem:
    command: "npx"
    args: ["-y", "@modelcontextprotocol/server-filesystem", "/opt/data"]
EOF

# Авторизація GitHub CLI (якщо токен є)
if [ -n "$GITHUB_TOKEN" ]; then
    echo "$GITHUB_TOKEN" | gh auth login --with-token 2>/dev/null || true
fi

# Вивід конфігу для логів Render (без токена)
echo "--- Generated Config ---"
grep -v "TOKEN" /root/.hermes/config.yaml
echo "------------------------"

# 3. Запускаємо шлюз
exec hermes gateway run
