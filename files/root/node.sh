#!/bin/sh
### BEGIN INIT INFO
# Provides:          node
# Required-Start:    $network
# Required-Stop:
# Default-Start:     2 3 4 5
# Default-Stop:
# Short-Description: Start status-client first, then update/start cloudflared
### END INIT INFO

# -------------------------------
# Step 0: 等待网络启动（循环检测）
# -------------------------------
echo "[node.sh] Waiting for network..." >> /tmp/node.log
until ping -c1 8.8.8.8 >/dev/null 2>&1; do
    sleep 2
done
sleep 3s

# 加载环境变量
if [ -f /etc/profile.d/env.sh ]; then
    . /etc/profile.d/env.sh
fi

# -------------------------------
# Step 1: 授权并结束旧进程
# -------------------------------
chmod +x /root/status-client

# 安全结束 status-client
for pid in $(pidof /root/status-client 2>/dev/null); do
    kill -9 "$pid"
done

# 安全结束 cloudflared
for pid in $(pidof /root/cloudflared 2>/dev/null); do
    kill -9 "$pid"
done

sleep 2s

# -------------------------------
# Step 2: 启动 status-client
# -------------------------------
if [ -n "$STATUS_DSN" ]; then
    nohup /root/status-client -dsn "$STATUS_DSN" >/tmp/status-client.log 2>&1 &
    echo "[node.sh] status-client started" >> /tmp/node.log
else
    echo "[node.sh] STATUS_DSN 未设置，status-client 未启动" >> /tmp/node.log
fi

# -------------------------------
# Step 3: 更新 cloudflared
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
            # ---- 版本拆分 ----
            split_version() {
                __v=$1
                _MAJOR="${__v%%.*}"
                __tmp="${__v#*.}"
                _MINOR="${__tmp%%.*}"
                _PATCH="${__tmp#*.}"
            }
            split_version "$CURRENT_VERSION"
            C_MAJOR=$_MAJOR C_MINOR=$_MINOR C_PATCH=$_PATCH
            split_version "$NEW_VERSION"
            N_MAJOR=$_MAJOR N_MINOR=$_MINOR N_PATCH=$_PATCH

            # 判断是否需要更新
            if [ "$N_MAJOR" -lt "$C_MAJOR" ] || \
               { [ "$N_MAJOR" -eq "$C_MAJOR" ] && [ "$N_MINOR" -lt "$C_MINOR" ]; } || \
               { [ "$N_MAJOR" -eq "$C_MAJOR" ] && [ "$N_MINOR" -eq "$C_MINOR" ] && [ "$N_PATCH" -lt "$C_PATCH" ]; }; then
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
# Step 4: 启动 cloudflared
# -------------------------------
if [ -n "$CLOUDFLARED_TOKEN" ]; then
    nohup /root/cloudflared tunnel --no-autoupdate run --token "$CLOUDFLARED_TOKEN" >/tmp/cloudflared.log 2>&1 &
    echo "[node.sh] cloudflared started" >> /tmp/node.log
else
    echo "[node.sh] CLOUDFLARED_TOKEN 未设置，cloudflared 未启动" >> /tmp/node.log
fi
