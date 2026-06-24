#!/bin/bash

# 修改默认 LAN IP
sed -i '/^CONFIG_IMAGEOPT=/d; /^# CONFIG_IMAGEOPT is not set/d; /^CONFIG_PREINITOPT=/d; /^# CONFIG_PREINITOPT is not set/d; /^CONFIG_TARGET_DEFAULT_LAN_IP_FROM_PREINIT=/d; /^CONFIG_TARGET_PREINIT_IP=/d; /^CONFIG_TARGET_PREINIT_BROADCAST=/d' .config
cat >> .config <<'EOF'
CONFIG_IMAGEOPT=y
CONFIG_PREINITOPT=y
CONFIG_TARGET_DEFAULT_LAN_IP_FROM_PREINIT=y
CONFIG_TARGET_PREINIT_IP="192.168.5.1"
CONFIG_TARGET_PREINIT_BROADCAST="192.168.5.255"
EOF
# 修改默认密码为空
# sed -i 's/$1$V4UetPzk$CYXluq4wUazHjmCDBCqXF.//g' package/lean/default-settings/files/zzz-default-settings

# 禁用版本信息修改
# sed -i "/DISTRIB_REVISION/s/^/#/" package/lean/default-settings/files/zzz-default-settings
# sed -i 's/^VERSION:=$(PKG_RELEASE)-$(REVISION)/VERSION:=$(PKG_RELEASE)/' /package/base-files/Makefile
# sed -i "/DISTRIB_DESCRIPTION/s/^/#/" package/lean/default-settings/files/zzz-default-settings
# sed -i 's/^luciversion\s*=.*/luciversion = ""/' /feeds/luci/modules/luci-lua-runtime/luasrc/version.lua

# 更改默认 Shell 为 zsh
sed -i 's/\/bin\/ash/\/usr\/bin\/zsh/g' package/base-files/files/etc/passwd

# TTYD 免登录
sed -i 's|/bin/login|/bin/login -f root|g' feeds/packages/utils/ttyd/files/ttyd.config

# 移除要替换的包
# rm -rf feeds/packages/net/smartdns
rm -rf feeds/packages/net/{chinadns-ng,dns2socks,dns2tcp,geoview,gn,hysteria,ipt2socks,microsocks,miniupnpc,naiveproxy,shadowsocks-libev,shadowsocks-rust,shadowsocksr-libev,simple-obfs,sing-box,ssocks,tcping,transmission-web-control,transmission,trojan-plus,tuic-client,v2ray-core,v2ray-geodata,v2ray-plugin,xray-core,xray-plugin}  #LEDE
rm -rf feeds/packages/libs/{libdeflate,libdht,libutp,libb64,libnatpmp,libpsl}
rm -rf feeds/luci/themes/luci-theme-argon
rm -rf feeds/luci/applications/luci-app-argon-config
# rm -rf feeds/luci/applications/luci-app-smartdns
rm -rf feeds/luci/applications/luci-app-passwall  #23.05
rm -rf feeds/luci/applications/luci-app-passwall2  #23.05
rm -rf feeds/luci/applications/luci-app-openclash  #23.05
rm -rf feeds/luci/applications/luci-app-netdata
rm -rf feeds/luci/applications/luci-app-transmission
rm -rf package/feeds/packages/{transmission-web-control,transmission,libdeflate,libdht,libutp,libb64,libnatpmp,libpsl,miniupnpc,libminiupnpc}
rm -rf package/feeds/luci/luci-app-transmission

# Git稀疏克隆，只克隆指定目录到本地
function git_sparse_clone() {
  branch="$1" repourl="$2" && shift 2
  git clone --depth=1 -b $branch --single-branch --filter=blob:none --sparse $repourl
  repodir=$(echo $repourl | awk -F '/' '{print $(NF)}')
  cd $repodir && git sparse-checkout set $@
  mv -f $@ ../package
  cd .. && rm -rf $repodir
}

# 添加额外插件
# AdGuardHome：仅装 kenzok8 LuCI，核心由界面在线下载(不编译，加快构建)
git_sparse_clone main https://github.com/kenzok8/small-package luci-app-adguardhome
git clone --depth=1 https://github.com/tonylee2022/luci-app-openclaw package/luci-app-openclaw
git clone --depth=1 https://github.com/sirpdboy/luci-app-poweroffdevice package/luci-app-poweroffdevice
git clone --depth=1 https://github.com/sirpdboy/netspeedtest package/netspeedtest-luci
git clone --depth=1 https://github.com/sirpdboy/luci-app-advanced package/luci-app-advanced
git clone --depth=1 https://github.com/Jason6111/luci-app-netdata package/luci-app-netdata
git clone --depth=1 https://github.com/tonylee2022/luci-app-nezha-agent package/luci-app-nezha-agent ##V1版本
git_sparse_clone openwrt-24.10 https://github.com/openwrt/luci applications/luci-app-transmission
git_sparse_clone openwrt-24.10 https://github.com/openwrt/packages net/transmission net/transmission-web-control net/miniupnpc libs/libdeflate libs/libdht libs/libutp libs/libb64 libs/libnatpmp libs/libpsl

# 科学上网插件
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall-packages package/openwrt-passwall
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall package/luci-app-passwall
git clone --depth=1 https://github.com/vernesong/OpenClash package/openclash-luci ##测试
git clone --depth=1 https://github.com/Openwrt-Passwall/openwrt-passwall2 package/luci-app-passwall2


# Themes
# git clone --depth=1 -b 18.06 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon
git clone --depth=1 https://github.com/jerrykuku/luci-theme-argon package/luci-theme-argon               #23.05
git clone --depth=1 https://github.com/jerrykuku/luci-app-argon-config package/luci-app-argon-config

# 更改 Argon 主题背景

# SmartDNS
# git clone --depth=1 https://github.com/pymumu/luci-app-smartdns package/luci-app-smartdns
# git clone --depth=1 https://github.com/pymumu/openwrt-smartdns package/smartdns

# Alist
# git clone --depth=1 https://github.com/sbwml/luci-app-alist package/luci-app-alist

# iStore
# git_sparse_clone main https://github.com/linkease/istore-ui app-store-ui
# git_sparse_clone main https://github.com/linkease/istore luci

# 在线用户 LEDE
git_sparse_clone main https://github.com/haiibo/packages luci-app-onliner
sed -i '$i uci set nlbwmon.@nlbwmon[0].refresh_interval=2s' package/lean/default-settings/files/zzz-default-settings
sed -i '$i uci commit nlbwmon' package/lean/default-settings/files/zzz-default-settings
chmod 755 package/luci-app-onliner/root/usr/share/onliner/setnlbw.sh

# x86 型号只显示 CPU 型号 LEDE
sed -i 's/${g}.*/${a}${b}${c}${d}${e}${f}${hydrid}/g' package/lean/autocore/files/x86/autocore

# 修改本地时间格式 LEDE
sed -i 's/os.date()/os.date("%a %Y-%m-%d %H:%M:%S")/g' package/lean/autocore/files/*/index.htm

# 保留 LEDE 名称，使用 OpenWrt 原始版本号并追加自定义标识
openwrt_version=$(awk '/^VERSION_NUMBER:=\$\(if/{gsub(/.*,/ , ""); gsub(/\).*/, ""); print; exit}' include/version.mk)
[ -n "$openwrt_version" ] || { echo "Unable to detect OpenWrt version" >&2; exit 1; }
default_settings="package/lean/default-settings/files/zzz-default-settings"
orig_version=$(awk -F "'" '/DISTRIB_REVISION=/{print $2; exit}' "$default_settings")
sed -i "s/${orig_version}/${openwrt_version} by TonyLee/g" "$default_settings"

# LuCI 版本保留 Git 日期，去掉最后的提交哈希
sed -i "s#revision = '\$(LUCI_VERSION)'#revision = '\$(shell echo \$(LUCI_VERSION) | rev | cut -d- -f2- | rev)'#" feeds/luci/modules/luci-base/src/Makefile
sed -i 's/luciversion = "${2:-Git}"/luciversion = "${2%-*}"/' feeds/luci/modules/luci-lua-runtime/src/mkversion.sh

# 修改 Makefile
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/luci.mk/$(TOPDIR)\/feeds\/luci\/luci.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/..\/..\/lang\/golang\/golang-package.mk/$(TOPDIR)\/feeds\/packages\/lang\/golang\/golang-package.mk/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHREPO/PKG_SOURCE_URL:=https:\/\/github.com/g' {}
find package/*/ -maxdepth 2 -path "*/Makefile" | xargs -i sed -i 's/PKG_SOURCE_URL:=@GHCODELOAD/PKG_SOURCE_URL:=https:\/\/codeload.github.com/g' {}

# 取消主题默认设置
# find package/luci-theme-*/* -type f -name '*luci-theme-*' -print -exec sed -i '/set luci.main.mediaurlbase/d' {} \;

./scripts/feeds update -a
./scripts/feeds install -a
