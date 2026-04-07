#!/bin/bash
#
# Copyright (c) 2019-2020 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate
#rm -rf package/lean/luci-theme-argon
#git clone -b 18.06 https://github.com/jerrykuku/luci-theme-argon.git  package/lean/luci-theme-argon

#git clone --depth=1 https://github.com/rufengsuixing/luci-app-adguardhome.git package/luci-app-adguardhome
#git clone -b lede https://github.com/pymumu/luci-app-smartdns.git  package/lean/luci-app-smartdns
#git clone  --depth=1 https://github.com/sirpdboy/luci-app-advanced.git package/luci-app-advanced
#git clone https://github.com/jerrykuku/luci-app-jd-dailybonus.git package/luci-app-jd-dailybonus

#chmod -R 755 files
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' ./feeds/luci/collections/luci/Makefile

#golang19
#rm -rf feeds/packages/lang/golang
# svn export https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
#git clone --depth=1 https://github.com/sbwml/packages_lang_golang feeds/packages/lang/golang
#rm -rf feeds/packages/lang/golang
#git clone https://github.com/sbwml/packages_lang_golang -b 23.x feeds/packages/lang/golang
#rm -rf feeds/smpackage/{base-files,dnsmasq,firewall*,fullconenat,libnftnl,nftables,ppp,opkg,ucl,upx,vsftpd*,miniupnpd-iptables,wireless-regdb}
rm -rf feeds/kenzo/luci-theme-alpha

# 删除 coolsnowwolf/luci feed 中的旧版 passwall（25.8.x），这才是版本不对的真正原因
rm -rf feeds/luci/applications/luci-app-passwall
rm -rf feeds/luci/applications/luci-app-passwall2

# 同时删除 kenzok8/small 中的 passwall，避免冲突

./scripts/feeds install -p passwall_luci luci-app-passwall
./scripts/feeds install -p passwall_luci luci-app-passwall2
