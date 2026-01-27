# CLI Proxy API Docker

Docker container running cli-proxy-api with sing-box VPN and cloudflared tunnel.

## Features

- **cli-proxy-api**: Proxy server for LLM APIs (Gemini, GLM, OpenAI Codex)
- **sing-box**: VLESS+Reality VPN for bypassing regional restrictions
- **cloudflared**: Cloudflare tunnel for public HTTPS access

## Setup

1. Copy example configs:
```bash
cp config.yaml.example config.yaml
cp singbox-config.json.example singbox-config.json
```

2. Edit `config.yaml` with your API keys

3. Edit `singbox-config.json` with your VPN credentials

4. Create auth directory:
```bash
mkdir auth
```

5. Start the container:
```bash
docker compose up -d
```

## Usage

Get tunnel URL:
```bash
curl http://localhost:8318
```

Test API:
```bash
curl -X POST "$(curl -s http://localhost:8318)/v1/messages" \
  -H "Content-Type: application/json" \
  -H "x-api-key: anything" \
  -H "anthropic-version: 2023-06-01" \
  -d '{"model":"gemini-3-flash-preview","max_tokens":100,"messages":[{"role":"user","content":"hi"}]}'
```

## Ports

- `8317`: cli-proxy-api
- `8318`: Tunnel URL endpoint
