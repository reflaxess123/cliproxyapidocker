# API Usage Guide

## Получение Tunnel URL

```bash
curl http://localhost:8318
```

Вернёт URL вида: `https://xxx.trycloudflare.com`

## Доступные модели

```bash
curl http://localhost:8318/v1/models
```

### Список моделей:
- **Gemini**: `gemini-3-flash-preview`, `gemini-3-pro-preview`, `gemini-2.5-flash`, `gemini-2.5-pro`
- **GLM (Zhipu)**: `glm-4.5-air`, `glm-4.7`
- **GPT-5 (OpenAI Codex)**: `gpt-5`, `gpt-5.1`, `gpt-5.2`, `gpt-5-codex`, `gpt-5.1-codex`, `gpt-5.2-codex`, `gpt-5-codex-mini`, `gpt-5.1-codex-mini`, `gpt-5.1-codex-max`

## Базовый запрос

```bash
TUNNEL_URL=$(curl -s http://localhost:8318)

curl -X POST "$TUNNEL_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: anything" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "gemini-3-flash-preview",
    "max_tokens": 1000,
    "messages": [
      {"role": "user", "content": "Hello!"}
    ]
  }'
```

## Reasoning / Thinking

### GPT-5 модели

Используют параметр `reasoning.effort`:

**Значения**: `none`, `low`, `medium`, `high`, `xhigh`

```bash
curl -X POST "$TUNNEL_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: anything" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "gpt-5.2-codex",
    "max_tokens": 500,
    "reasoning": {"effort": "high"},
    "messages": [
      {"role": "user", "content": "Solve 15! / 12!"}
    ]
  }'
```

**Ответ включает thinking блок:**
```json
{
  "content": [
    {"type": "thinking", "thinking": "..."},
    {"type": "text", "text": "..."}
  ]
}
```

### Gemini модели

Используют суффиксы в названии модели:
- `-nothinking` - выключить thinking
- `-maxthinking` - максимальный thinking

```bash
curl -X POST "$TUNNEL_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: anything" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "gemini-3-flash-preview-maxthinking",
    "max_tokens": 5000,
    "messages": [
      {"role": "user", "content": "Как работает квантовая физика?"}
    ]
  }'
```

## Использование в Python

### Установка SDK

```bash
pip install anthropic requests
```

### Пример с Anthropic SDK

```python
import anthropic
import requests

# Получить tunnel URL
tunnel_url = requests.get("http://localhost:8318").text.strip()

client = anthropic.Anthropic(
    api_key="anything",
    base_url=tunnel_url
)

# Простой запрос
response = client.messages.create(
    model="gemini-3-flash-preview",
    max_tokens=1000,
    messages=[
        {"role": "user", "content": "Hello!"}
    ]
)

print(response.content[0].text)
```

### Пример с reasoning (GPT-5)

```python
response = client.messages.create(
    model="gpt-5.2-codex",
    max_tokens=500,
    extra_body={"reasoning": {"effort": "high"}},
    messages=[
        {"role": "user", "content": "Explain quantum entanglement"}
    ]
)

# Проверить thinking блок
for block in response.content:
    if block.type == "thinking":
        print(f"Thinking: {block.thinking}")
    elif block.type == "text":
        print(f"Answer: {block.text}")
```

### Пример с requests

```python
import requests

tunnel_url = requests.get("http://localhost:8318").text.strip()

response = requests.post(
    f"{tunnel_url}/v1/messages",
    headers={
        "Content-Type": "application/json",
        "x-api-key": "anything",
        "anthropic-version": "2023-06-01"
    },
    json={
        "model": "glm-4.7",
        "max_tokens": 1000,
        "messages": [{"role": "user", "content": "Привет!"}]
    }
)

data = response.json()
text = data["content"][0]["text"]
print(text)
```

## Использование в JavaScript

```javascript
const tunnel_url = await fetch('http://localhost:8318').then(r => r.text());

const response = await fetch(`${tunnel_url}/v1/messages`, {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'x-api-key': 'anything',
    'anthropic-version': '2023-06-01'
  },
  body: JSON.stringify({
    model: 'gemini-3-flash-preview',
    max_tokens: 1000,
    messages: [
      { role: 'user', content: 'Hello!' }
    ]
  })
});

const data = await response.json();
console.log(data.content[0].text);
```

## PowerShell функции

В `Microsoft.PowerShell_profile.ps1` уже настроены функции:

```powershell
# Gemini 3
claude-gemini

# GLM 4.7
claude-glm

# GPT-5.2 Codex
claude-codex
```

Используй напрямую:
```powershell
claude-gemini
# Или с аргументами
claude-gemini --model sonnet
```

## Streaming

API поддерживает streaming. Добавь заголовок:

```bash
-H "Accept: text/event-stream"
```

Пример:
```bash
curl -X POST "$TUNNEL_URL/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: anything" \
  -H "anthropic-version: 2023-06-01" \
  -H "Accept: text/event-stream" \
  -d '{
    "model": "gemini-3-flash-preview",
    "max_tokens": 1000,
    "stream": true,
    "messages": [{"role": "user", "content": "Count to 10"}]
  }'
```

## Рекомендации по моделям

### Для кода
- `gpt-5.2-codex` - лучшая для сложного кода
- `gpt-5.1-codex-max` - максимальная производительность
- `gemini-3-flash-preview` - быстрая и дешёвая

### Для текста
- `gemini-3-pro-preview` - большой контекст (1M tokens)
- `glm-4.7` - на русском языке
- `gpt-5.2` - универсальная

### Для reasoning
- `gpt-5.2-codex` с `effort: high` - математика, логика
- `gemini-3-flash-preview-maxthinking` - длинные рассуждения

## Таймауты

По умолчанию: 3000000ms (50 минут)

Изменить через переменную окружения:
```bash
export API_TIMEOUT_MS=600000  # 10 минут
```

## Troubleshooting

### Tunnel недоступен
```bash
# Проверить контейнер
docker ps

# Перезапустить
cd D:\CProjs\dl\cli-proxy-docker
docker compose restart
```

### Ошибка "unknown provider for model"
Проверь список доступных моделей:
```bash
curl -s $(curl -s http://localhost:8318)/v1/models | jq '.data[].id'
```

### Streaming не работает
Убедись что cloudflare домены исключены из VPN в `singbox-config.json`:
```json
"domain_suffix": [".trycloudflare.com", ".cloudflare.com"]
```
