#!/usr/bin/env bash
set -euo pipefail

echo "=== AI Assistant Setup ==="
echo ""

# Check Docker
if ! command -v docker &> /dev/null; then
    echo "Error: Docker is not installed. Install Docker first."
    exit 1
fi

if ! docker compose version &> /dev/null; then
    echo "Error: Docker Compose V2 is not available."
    exit 1
fi

# Copy template
if [ ! -f .env ]; then
    cp .env.example .env
    echo "Created .env from template"
else
    echo ".env already exists, updating values..."
fi

# Telegram
read -rp "Telegram Bot Token: " tg_token
sed -i '' "s|^TELEGRAM_BOT_TOKEN=.*|TELEGRAM_BOT_TOKEN=${tg_token}|" .env

read -rp "Your Telegram Chat ID (for authorization): " chat_id
sed -i '' "s|^TELEGRAM_ALLOWED_CHAT_IDS=.*|TELEGRAM_ALLOWED_CHAT_IDS=${chat_id}|" .env

# LLM Provider
echo ""
echo "LLM Provider:"
echo "  1) OpenRouter (recommended - 100+ models)"
echo "  2) Anthropic (Claude direct)"
echo "  3) OpenAI (GPT direct)"
echo "  4) Ollama (local model)"
read -rp "Choice [1-4]: " llm_choice

PROFILES=""

case $llm_choice in
    1)
        sed -i '' "s|^LLM_PROVIDER=.*|LLM_PROVIDER=openrouter|" .env
        read -rp "OpenRouter API Key: " key
        sed -i '' "s|^OPENROUTER_API_KEY=.*|OPENROUTER_API_KEY=${key}|" .env
        ;;
    2)
        sed -i '' "s|^LLM_PROVIDER=.*|LLM_PROVIDER=anthropic|" .env
        read -rp "Anthropic API Key: " key
        sed -i '' "s|^ANTHROPIC_API_KEY=.*|ANTHROPIC_API_KEY=${key}|" .env
        ;;
    3)
        sed -i '' "s|^LLM_PROVIDER=.*|LLM_PROVIDER=openai|" .env
        read -rp "OpenAI API Key: " key
        sed -i '' "s|^OPENAI_API_KEY=.*|OPENAI_API_KEY=${key}|" .env
        ;;
    4)
        sed -i '' "s|^LLM_PROVIDER=.*|LLM_PROVIDER=ollama|" .env
        PROFILES="--profile ollama"
        ;;
esac

# Bot name
read -rp "Bot name [MyAssistant]: " bot_name
bot_name=${bot_name:-MyAssistant}
sed -i '' "s|^BOT_NAME=.*|BOT_NAME=${bot_name}|" .env

# Optional profiles
echo ""
echo "Optional services (y/n):"

read -rp "  n8n (automations)? [n]: " yn
[[ "${yn:-n}" == "y" ]] && PROFILES="$PROFILES --profile n8n"

read -rp "  Web UI? [n]: " yn
[[ "${yn:-n}" == "y" ]] && PROFILES="$PROFILES --profile webui"

# Generate postgres password
PGPASS=$(openssl rand -base64 16 | tr -d '/+=' | head -c 16)
sed -i '' "s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${PGPASS}|" .env

# Launch
echo ""
echo "Starting services..."
docker compose -f docker-compose.prod.yml $PROFILES up -d --build

echo ""
echo "=== Done! ==="
echo "Bot '${bot_name}' is running."
echo "Send a message to your Telegram bot to start."
