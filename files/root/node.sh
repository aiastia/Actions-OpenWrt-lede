#!/bin/sh
### BEGIN INIT INFO
# Provides:          node
# Required-Start:    $network
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Start cloudflared and status-client
### END INIT INFO

# node.sh - OpenWrt 启动脚本

# 等待网络启动
sleep 10s

# 加载环境变量
if [ -f /etc/profile.d/env.sh ]; then
    . /etc/profile.d/env.sh
fi

# 启动 cloudflared
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    nohup /root/cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARED_TOKEN" >/tmp/cloudflared.log 2>&1 &
else
    echo "[node.sh] CLOUDFLARED_TOKEN 未设置，cloudflared 未启动" >> /tmp/node.log
fi

# 启动 status-client
if [ -n "$STATUS_DSN" ]; then
    nohup /root/status-client -dsn "$STATUS_DSN" >/tmp/status-client.log 2>&1 &
else
    echo "[node.sh] STATUS_DSN 未设置，status-client 未启动" >> /tmp/node.log
fi
