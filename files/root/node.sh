#!/bin/sh
# sleep 是为了保证系统网络服务先启动

cat  /etc/profile.d/env.sh


sleep 30s

# 启动 cloudflared
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    nohup /root/cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARED_TOKEN" >/dev/null 2>&1 &
else
    echo "CLOUDFLARED_TOKEN 未设置，cloudflared 未启动"
fi

# 启动 status-client
if [ -n "$STATUS_DSN" ]; then
    nohup /root/status-client -dsn "$STATUS_DSN" >/dev/null 2>&1 &
else
    echo "STATUS_DSN 未设置，status-client 未启动"
fi
