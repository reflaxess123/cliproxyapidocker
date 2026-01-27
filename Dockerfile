FROM alpine:latest

# Установка зависимостей
RUN apk add --no-cache ca-certificates curl bash python3 dos2unix

# Установка cloudflared
RUN curl -L https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Установка sing-box
RUN curl -fsSL "https://github.com/SagerNet/sing-box/releases/download/v1.10.7/sing-box-1.10.7-linux-amd64.tar.gz" -o /tmp/sing-box.tar.gz && \
    tar -xzf /tmp/sing-box.tar.gz -C /tmp && \
    mv /tmp/sing-box-1.10.7-linux-amd64/sing-box /usr/local/bin/sing-box && \
    chmod +x /usr/local/bin/sing-box && \
    rm -rf /tmp/*

# Скачиваем cli-proxy-api из GitHub releases
RUN curl -fsSL "https://github.com/router-for-me/CLIProxyAPI/releases/download/v6.7.26/CLIProxyAPI_6.7.26_linux_amd64.tar.gz" -o /tmp/cli-proxy-api.tar.gz && \
    tar -xzf /tmp/cli-proxy-api.tar.gz -C /tmp && \
    mv /tmp/cli-proxy-api /usr/local/bin/cli-proxy-api && \
    chmod +x /usr/local/bin/cli-proxy-api && \
    rm -rf /tmp/*

# Создаём директории
RUN mkdir -p /root/.cli-proxy-api /app

WORKDIR /app

# Копируем скрипты
COPY entrypoint.sh /app/entrypoint.sh
COPY tunnel_server.py /app/tunnel_server.py
RUN dos2unix /app/entrypoint.sh /app/tunnel_server.py && chmod +x /app/entrypoint.sh

# Порты: 8317 - api, 8318 - tunnel url endpoint
EXPOSE 8317 8318

ENTRYPOINT ["/app/entrypoint.sh"]
