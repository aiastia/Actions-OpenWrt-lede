#!/bin/sh
### BEGIN INIT INFO
# Provides:          node
# Required-Start:    $network
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Start status-client first, then update/start cloudflared
### END INIT INFO

# 等待网络启动
sleep 10s

# 加载环境变量
if [ -f /etc/profile.d/env.sh ]; then
    . /etc/profile.d/env.sh
fi

# -------------------------------
# Step 0: 授权可执行文件
# -------------------------------

chmod +x /root/status-client


# -------------------------------
# Step 1: 启动 status-client
# -------------------------------
if [ -n "$STATUS_DSN" ]; then
    nohup /root/status-client -dsn "$STATUS_DSN" >/tmp/status-client.log 2>&1 &
else
    echo "[node.sh] STATUS_DSN 未设置，status-client 未启动" >> /tmp/node.log
fi

# -------------------------------
# Step 2: 更新 cloudflared
# -------------------------------
REPO="cloudflare/cloudflared"

ARCH=$(uname -m)
if [ "$ARCH" = "mips" ]; then
    FILE_NAME="cloudflared-linux-mips"
elif [ "$ARCH" = "arm" ]; then
    FILE_NAME="cloudflared-linux-arm"
else
    FILE_NAME="cloudflared-linux-amd64"
fi

LATEST_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | \
             grep "browser_download_url" | grep "$FILE_NAME\"" | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo "[update] Failed to fetch the latest URL." >> /tmp/node.log
else
    NEW_VERSION=$(echo "$LATEST_URL" | sed -n 's/.*\/\([0-9]\+\.[0-9]\+\.[0-9]\+\)\/.*/\1/p')
    UPDATE_NEEDED=1

    if [ -f "/root/cloudflared" ]; then
        CURRENT_VERSION=$(/root/cloudflared -v 2>/dev/null | sed -n 's/.* \([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
        if [ -n "$CURRENT_VERSION" ]; then
            IFS=. read -r C_MAJOR C_MINOR C_PATCH <<< "$CURRENT_VERSION"
            IFS=. read -r N_MAJOR N_MINOR N_PATCH <<< "$NEW_VERSION"
            if [ "$N_MAJOR" -lt "$C_MAJOR" ] || \
               { [ "$N_MAJOR" -eq "$C_MAJOR" ] && [ "$N_MINOR" -lt "$C_MINOR" ]; } || \
               { [ "$N_MAJOR" -eq "$C_MAJOR" ] && [ "$N_MINOR" -eq "$C_MINOR" ] && [ "$N_PATCH" -le "$C_PATCH" ]; }; then
                UPDATE_NEEDED=0
            fi
        fi
    fi

    if [ "$UPDATE_NEEDED" -eq 1 ]; then
        echo "[update] Downloading cloudflared $NEW_VERSION..." >> /tmp/node.log
        wget -q "$LATEST_URL" -O /root/cloudflared && chmod +x /root/cloudflared
    else
        echo "[update] cloudflared is up to date ($CURRENT_VERSION)" >> /tmp/node.log
    fi
fi

# -------------------------------
# Step 3: 启动 cloudflared
# -------------------------------
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    nohup /root/cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARED_TOKEN" >/tmp/cloudflared.log 2>&1 &
else
    echo "[node.sh] CLOUDFLARED_TOKEN 未设置，cloudflared 未启动" >> /tmp/node.log
fi
