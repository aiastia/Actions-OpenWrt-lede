#!/bin/sh
sleep 10s
nohup /root/status-client -dsn "$STATUS_DSN" >/dev/null 2>&1 &
