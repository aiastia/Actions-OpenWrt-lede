#!/bin/sh

# 定义 GitHub 项目和文件名
REPO="cloudflare/cloudflared"

# 根据架构选择文件名
ARCH=$(uname -m)
if [ "$ARCH" = "mips" ]; then
    FILE_NAME="cloudflared-linux-mips"
elif [ "$ARCH" = "arm" ]; then
    FILE_NAME="cloudflared-linux-arm"
else
    FILE_NAME="cloudflared-linux-amd64"
fi

# 获取最新版本的下载 URL
LATEST_URL=$(curl -s "https://api.github.com/repos/$REPO/releases/latest" | \
             grep "browser_download_url" | grep "$FILE_NAME\"" | \
             cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo "Failed to fetch the latest URL."
    exit 1
fi

# 提取最新版本号
NEW_VERSION=$(echo "$LATEST_URL" | sed -n 's/.*\/\([0-9]\+\.[0-9]\+\.[0-9]\+\)\/.*/\1/p')

# 输出结果
echo "LATEST_URL: $LATEST_URL"
echo "NEW_VERSION: $NEW_VERSION"

# 检查本地版本
if [ -f "./cloudflared" ]; then
    CURRENT_VERSION=$(./cloudflared -v 2>/dev/null | sed -n 's/.* \([0-9]\+\.[0-9]\+\.[0-9]\+\).*/\1/p')
    
    if [ -z "$CURRENT_VERSION" ]; then
        echo "Failed to determine the current version."
        exit 1
    fi

    # 将版本号分解为数字部分
    CURRENT_MAJOR=$(echo "$CURRENT_VERSION" | cut -d. -f1)
    CURRENT_MINOR=$(echo "$CURRENT_VERSION" | cut -d. -f2)
    CURRENT_PATCH=$(echo "$CURRENT_VERSION" | cut -d. -f3)
    
    NEW_MAJOR=$(echo "$NEW_VERSION" | cut -d. -f1)
    NEW_MINOR=$(echo "$NEW_VERSION" | cut -d. -f2)
    NEW_PATCH=$(echo "$NEW_VERSION" | cut -d. -f3)

    # 比较版本号
    if [ "$NEW_MAJOR" -gt "$CURRENT_MAJOR" ] || \
       [ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" -a "$NEW_MINOR" -gt "$CURRENT_MINOR" ] || \
       [ "$NEW_MAJOR" -eq "$CURRENT_MAJOR" -a "$NEW_MINOR" -eq "$CURRENT_MINOR" -a "$NEW_PATCH" -gt "$CURRENT_PATCH" ]; then
        echo "Updating: Current version ($CURRENT_VERSION) is older than $NEW_VERSION"
        wget "$LATEST_URL" -O cloudflared
        chmod +x cloudflared
    else
        echo "No update needed: Current version ($CURRENT_VERSION) is up to date."
    fi
else
    echo "File does not exist, downloading $NEW_VERSION..."
    wget "$LATEST_URL" -O cloudflared
    chmod +x cloudflared
fi
