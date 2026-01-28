#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part1.sh
# Description: OpenWrt DIY script part 1 (Before Update feeds)
#

# Uncomment a feed source
#sed -i 's/^#\(.*helloworld\)/\1/' feeds.conf.default

# Add a feed source
#echo 'src-git helloworld https://github.com/fw876/helloworld' >>feeds.conf.default

# 二选一：PassWall 1 或 PassWall 2
# echo 'src-git passwall2 https://github.com/xiaorouji/openwrt-passwall2' >>feeds.conf.default        # PassWall 2
#echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall' >>feeds.conf.default  # PassWall 1

echo 'src-git passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages.git;main' >>feeds.conf.default  # PassWall 1
echo 'src-git passwall_luci https://github.com/xiaorouji/openwrt-passwall.git;main' >>feeds.conf.default  # PassWall 1

# PassWall 依赖包
echo 'src-git openwrt_passwall_packages https://github.com/xiaorouji/openwrt-passwall-packages' >>feeds.conf.default

# 常用插件源
#echo 'src-git kenzo https://github.com/kenzok8/openwrt-packages' >>feeds.conf.default
sed -i '$a src-git smpackage https://github.com/kenzok8/small-package' feeds.conf.default
#echo 'src-git small https://github.com/kenzok8/small' >>feeds.conf.default

# 其他工具
## echo 'src-git eqosplus https://github.com/sirpdboy/luci-app-eqosplus' >>feeds.conf.default
echo 'src-git alist_luci https://github.com/sbwml/openwrt-alist' >>feeds.conf.default
echo 'src-git istore https://github.com/linkease/istore main' >>feeds.conf.default  # 修正分支语法

cat feeds.conf.default
