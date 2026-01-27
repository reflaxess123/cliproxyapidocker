#!/bin/bash

TUNNEL_URL_FILE="/app/tunnel_url.txt"

# Запускаем sing-box VPN
echo "Starting sing-box VPN..."
sing-box run -c /etc/sing-box/config.json &
sleep 3

# Запускаем cli-proxy-api в фоне
echo "Starting cli-proxy-api..."
cli-proxy-api &
sleep 2

# Запускаем простой HTTP сервер для отдачи URL туннеля
echo "Starting tunnel URL server on port 8318..."
python3 /app/tunnel_server.py &

# Запускаем cloudflared и парсим URL
echo "Starting cloudflared tunnel..."
cloudflared tunnel --protocol http2 --url http://localhost:8317 2>&1 | while read line; do
    echo "$line"
    # Ищем URL туннеля
    if echo "$line" | grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com' > /dev/null; then
        URL=$(echo "$line" | grep -oE 'https://[a-z0-9-]+\.trycloudflare\.com')
        echo "$URL" > "$TUNNEL_URL_FILE"
        echo "Tunnel URL saved: $URL"
    fi
done
