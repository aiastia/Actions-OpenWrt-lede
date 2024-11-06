#!/bin/sh
sleep 120s
nohup /root/cloudflared tunnel --no-autoupdate run --token token >/dev/null 2>&1 &
