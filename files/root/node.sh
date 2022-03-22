#!/bin/sh
sleep 120s

nohup /root/status-client -dsn wss://openwrt:123123@node >/dev/null 2>&1 &
