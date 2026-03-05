# My AI Assistant

Self-hosted AI-ассистент на базе [OpenClaw](https://github.com/openclaw/openclaw). Docker-деплой в одну команду.

## Возможности

- Telegram как основной канал общения
- Поддержка множества LLM через OpenRouter (Claude, GPT, Llama, Mistral и др.)
- Прямые API для Anthropic, OpenAI
- Локальные модели через Ollama
- Долгосрочная память (PostgreSQL)
- Кэширование и очереди (Redis)
- Модульные сервисы (n8n, email, Discord, WhatsApp и др.)
- Русский язык по умолчанию
- Авторизация по Telegram Chat ID

## Быстрый старт

### Автоматический (рекомендуется)

```bash
git clone <repo-url>
cd my-assistant
./setup.sh
```

Скрипт спросит Telegram Bot Token, LLM-ключ и запустит всё автоматически.

### Ручной

```bash
git clone <repo-url>
cd my-assistant
cp .env.example .env
# Заполнить .env (минимум: TELEGRAM_BOT_TOKEN + OPENROUTER_API_KEY)
docker compose -f docker-compose.prod.yml up -d --build
```

## Доп. сервисы (Docker profiles)

```bash
# С локальной LLM (Ollama)
docker compose -f docker-compose.prod.yml --profile ollama up -d

# С n8n автоматизациями
docker compose -f docker-compose.prod.yml --profile n8n up -d

# Несколько профилей сразу
docker compose -f docker-compose.prod.yml --profile ollama --profile n8n up -d
```

| Profile | Сервис | Описание |
|---------|--------|----------|
| `ollama` | Ollama | Локальная LLM |
| `n8n` | n8n | Автоматизации и вебхуки |
| `webui` | Web UI | Веб-интерфейс |
| `email` | Email bridge | IMAP/SMTP |
| `discord` | Discord | Discord-канал |

## Конфигурация

Все настройки в `.env` (см. `.env.example`).

### LLM-провайдеры

| Провайдер | Переменные |
|-----------|-----------|
| OpenRouter | `OPENROUTER_API_KEY`, `OPENROUTER_MODEL` |
| Anthropic | `ANTHROPIC_API_KEY` |
| OpenAI | `OPENAI_API_KEY` |
| Ollama | `OLLAMA_MODEL` (+ profile ollama) |

### Кастомизация бота

- Имя: `BOT_NAME` в `.env`
- Системный промпт: `workspace/AGENTS.md`, `workspace/SOUL.md`
- Профиль пользователя: `workspace/USER.md` (по шаблону `USER.md.example`)

## Обновление

```bash
git pull
docker compose -f docker-compose.prod.yml up -d --build
```

## Обновление из upstream (OpenClaw)

```bash
git fetch upstream
git merge upstream/main
# Разрешить конфликты если есть
docker compose -f docker-compose.prod.yml up -d --build
```

## Архитектура

```
Docker Compose
├── openclaw     — gateway + agent runtime
├── postgres     — БД (история, пользователи, память)
├── redis        — кэш + очереди
├── [ollama]     — локальная LLM
├── [n8n]        — автоматизации
└── [...]        — другие сервисы через profiles
```

## На базе

[OpenClaw](https://github.com/openclaw/openclaw) — self-hosted AI assistant platform.
