#!/usr/bin/env bash
# Expand comma-separated TELEGRAM_ALLOWED_CHAT_IDS into openclaw.json allowFrom array.
# Called by docker-entrypoint before starting the gateway.
set -euo pipefail

CONFIG_DIR="${OPENCLAW_CONFIG_DIR:-/home/node/.openclaw/config}"
CONFIG_FILE="${CONFIG_DIR}/openclaw.json"

if [ ! -f "$CONFIG_FILE" ]; then
  echo "[expand-allowlist] No openclaw.json found, skipping."
  exit 0
fi

IDS="${TELEGRAM_ALLOWED_CHAT_IDS:-}"
if [ -z "$IDS" ]; then
  echo "[expand-allowlist] TELEGRAM_ALLOWED_CHAT_IDS is empty, skipping."
  exit 0
fi

# Build JSON array from comma-separated IDs
# e.g. "123,456,789" -> ["123","456","789"]
JSON_ARRAY=$(echo "$IDS" | tr ',' '\n' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | grep -v '^$' | awk '{printf "\"%s\",", $0}' | sed 's/,$//' | sed 's/^/[/;s/$/]/')

echo "[expand-allowlist] Setting allowFrom to: $JSON_ARRAY"

# Replace the allowFrom line in openclaw.json
# Handle both single-line array formats
if command -v node &> /dev/null; then
  node -e "
    const fs = require('fs');
    const raw = fs.readFileSync('$CONFIG_FILE', 'utf-8');
    const ids = '${IDS}'.split(',').map(s => s.trim()).filter(Boolean);
    // Replace allowFrom array value (handles JSON5 with env var placeholders)
    const updated = raw.replace(
      /allowFrom:\s*\[.*?\]/s,
      'allowFrom: ' + JSON.stringify(ids)
    );
    fs.writeFileSync('$CONFIG_FILE', updated, 'utf-8');
  "
else
  # Fallback: sed-based replacement
  sed -i "s|allowFrom:.*|allowFrom: ${JSON_ARRAY},|" "$CONFIG_FILE"
fi

echo "[expand-allowlist] Done."
