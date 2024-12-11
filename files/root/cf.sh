#!/bin/sh
# ps | grep cloudflared
# kill 12345

sleep 120s
nohup /root/cloudflared tunnel --no-autoupdate run --token token >/dev/null 2>&1 &
