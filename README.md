# LEDE-build-action

本仓库用于基于 Lean LEDE `master` 源码编译 x86_64 OpenWrt 固件。构建、配置整理、GitHub 发布和 VPS 上传均由 GitHub Actions 完成。

## 分支说明

| 分支 | LuCI 来源 | 说明 |
| --- | --- | --- |
| `main` | `openwrt-23.05` | 显式切换到 LuCI 23.05 分支 |
| `24.10` | `openwrt-24.10` | 显式切换到 LuCI 24.10 分支 |
| `25.12` | LEDE 默认 LuCI 源 | 保留 LEDE 当前默认源，未显式锁定 LuCI 分支 |

三个分支均从 LEDE `master` 拉取源码，因此上游更新可能影响后续编译结果。

## 固件配置

- 目标平台：`x86_64`
- 配置文件：`configs/x86_64.config`
- 自定义脚本：`diy-script.sh`
- 默认 LAN 地址：`192.168.5.1`
- 默认 Shell：`zsh`
- TTYD：root 自动登录
- 默认主题：Argon
- 固件版本格式：`LEDE <OpenWrt版本> by TonyLee / LuCI <分支> git-<日期>`

当前配置包含以下主要组件：

- 网络与代理：AdGuardHome、OpenClash、PassWall、PassWall2、SmartDNS、MWAN3、OpenVPN、ZeroTier、Cloudflared
- 系统与存储：Docker、DiskMan、Samba4、Transmission、TTYD、Zsh
- 状态与工具：Netdata、网络测速、在线用户、哪吒代理、OpenClaw、高级设置、定时重拨、释放内存、关机

实际生成的软件包以当次编译日志和 `configs/x86_64.config` 为准。

## 工作流

所有工作流均为手动触发，不会定时自动编译。

### X86_64-OpenWrt-VPS-Github.yml

用于完整构建和双目标发布：

- 编译 x86_64 固件
- 将完整 `bin` 目录按版本上传到 VPS
- 单独整理 GitHub Release 文件，避免把完整构建目录上传到 Release
- 清理旧 Release
- 发送 Telegram 构建通知

### clean-config.yml

用于重新整理配置：

- 拉取当前 LEDE 源码
- 按所在分支选择或保留 LuCI 源
- 执行 `diy-script.sh`
- 运行 `make defconfig` 和 `scripts/diffconfig.sh`
- 将整理后的配置提交回当前分支

## 仓库密钥

运行 `X86_64-OpenWrt-VPS-Github.yml` 前，需要在仓库 Actions Secrets 中配置：

| 密钥 | 用途 |
| --- | --- |
| `GH_TOKEN` | 创建和清理 GitHub Release |
| `SSH_PRIVATE_KEY` | 登录 VPS 的 SSH 私钥 |
| `VPS_HOST` | VPS 主机名或 IP 地址 |
| `VPS_USER` | VPS SSH 用户名 |
| `VPS_TARGET_DIR` | VPS 上的绝对目标目录，不能是 `/`，也不能包含 `..` |
| `VPS_KNOWN_HOSTS` | 已核验的 VPS SSH 主机公钥记录 |
| `TELEGRAM_CHAT_ID` | Telegram 接收方 ID |
| `TELEGRAM_BOT_TOKEN` | Telegram Bot Token |

`VPS_KNOWN_HOSTS` 可使用以下命令取得，但写入密钥前应独立核对服务器指纹：

```bash
ssh-keyscan -H your-vps-host
```


## 使用方法

1. 根据需要选择 `main`、`24.10` 或 `25.12` 分支。
2. 在 `configs/x86_64.config` 中调整固件配置。
3. 在 `diy-script.sh` 中维护自定义软件包和默认设置。
4. 按所选工作流配置仓库密钥。
5. 在 GitHub Actions 中手动运行对应工作流。
6. 编译完成后，从 GitHub Release 或 VPS 获取成果。

## 主要文件

| 路径 | 用途 |
| --- | --- |
| `configs/x86_64.config` | x86_64 固件配置 |
| `diy-script.sh` | 自定义软件包、默认 LAN 地址和系统设置 |
| `scripts/init-settings.sh` | 首次启动后的默认配置 |
| `scripts/preset-terminal-tools.sh` | 终端工具预置 |
| `.github/workflows/X86_64-OpenWrt-VPS-Github.yml` | VPS 与 GitHub Release 发布 |
| `.github/workflows/clean-config.yml` | 配置整理与回写 |

## 注意事项

- 本仓库仅维护 x86_64 配置，不包含其他设备的构建配置。
- 自定义软件包来自多个上游仓库，上游变更或失效可能导致编译失败。
- VPS 工作流会替换目标版本目录，`VPS_TARGET_DIR` 必须使用专门的固件发布目录。
