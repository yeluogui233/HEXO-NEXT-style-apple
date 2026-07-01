# HEXO-NEXT-style-apple

一个基于 Hexo + NexT 深度定制的个人博客模板，视觉方向偏 Apple / Butterfly：圆角卡片、顶部横向菜单、文章预览长卡片、专属页面、全站搜索、密码文章前端验证、桌宠和本地博客管理器。

这是纯净开源版，不包含原站文章、书单、影视、日记、相册、报告、个人域名、部署仓库、Steam ID、API Key、Nintendo Token 或任何私人数据。

## 功能概览

- Hexo 7 + NexT 定制主题
- 首页文章预览卡片，支持封面图、摘要、分类、标签和阅读全文
- 关于、书单、影视、日记、画廊、烘焙、游戏、实验室、日程表、资源页等专属页面
- 归档、标签、分类页面
- 全站搜索索引，页面和文章都能搜索
- 可选密码文章前端验证
- 可拖动桌宠
- 本地博客管理器 Web 端与 Windows 启动器源码
- 游戏页预留 Steam / Switch / Xbox / PlayStation 数据结构

## 快速开始

```bash
npm install
npm run server
```

生成静态文件：

```bash
npm run build
```

清理缓存：

```bash
npm run clean
```

## 目录结构

```text
source/                 页面、文章和静态资源
source/_posts/          Markdown 文章
source/_data/           书单、影视、分类、游戏等结构化数据
themes/next/            定制后的 NexT 主题
admin/                  博客管理器 Web 端
launcher/               Windows 启动器源码
BlogAdmin/              管理器图标资源
```

## 写文章

文章放在：

```text
source/_posts/
```

常用 front matter 示例：

```yaml
---
title: 示例文章
date: 2026-01-01 10:00:00
updated: 2026-01-01 10:00:00
thumbnail: /images/example.jpg
description: 这里是文章摘要。
tags:
  - Hexo
categories:
  - 博客
---
```

首页文章卡片读取的封面字段是：

```yaml
thumbnail: /images/example.jpg
```

如果文章需要密码验证，可以添加：

```yaml
password: 1234
```

不需要密码就不要写 `password` 字段。博客管理器里的密码输入框留空时，也不会写入这个字段。

注意：密码文章是前端展示层面的轻量保护，适合普通访问限制，不适合存放高敏感内容。

## 游戏数据

纯净版预留了游戏数据文件：

```text
source/_data/game-platforms.json
```

基础结构：

```json
{
  "steam": [],
  "switch": [],
  "xbox": [],
  "playstation": []
}
```

通用字段示例：

```json
{
  "name": "Game Name",
  "hours": 12.5,
  "minutes": 750,
  "cover": "/images/games/example.jpg",
  "last_played": "2026-01-01"
}
```

### Steam 自动导入

仓库保留了 Steam 数据入口和 `_config.yml` 中的 `steam` 配置位。常见做法是：

1. 在 [Steam Web API Key](https://steamcommunity.com/dev/apikey) 申请 API Key。
2. 找到自己的 SteamID64，例如 `7656119xxxxxxxxxx`。
3. 在 `_config.yml` 中配置：

```yaml
steam:
  enable: true
  steamId: '你的 SteamID64'
  apiKey: ''
```

建议不要把 API Key 写进公开仓库，更推荐用环境变量保存：

PowerShell：

```powershell
$env:STEAM_API_KEY="你的 Steam Web API Key"
npm run build
```

Git Bash / macOS / Linux：

```bash
STEAM_API_KEY="你的 Steam Web API Key" npm run build
```

如果你想让 `hexo g` 自动把 Steam 数据同步进 `source/_data/game-platforms.json`，推荐在 `scripts/` 里接一个 `before_generate` 钩子：

1. 读取 `_config.yml` 里的 `steam.steamId` 和环境变量 `STEAM_API_KEY`。
2. 请求 Steam Web API 的 `IPlayerService/GetOwnedGames`。
3. 将返回数据写入 `game-platforms.json` 的 `steam` 数组。
4. 排序建议用“最近两周游玩优先，然后按总时长排序”。
5. 对手动封面增加 `fixed_cover: true`，后续同步时保留自定义 `cover`。

Steam 游戏项建议字段：

```json
{
  "appid": 123456,
  "name": "Game Name",
  "hours": 12.5,
  "minutes": 750,
  "two_week_minutes": 120,
  "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/123456/header.jpg",
  "fixed_cover": false,
  "store_url": "https://store.steampowered.com/app/123456/"
}
```

### Switch 自动导入

Switch 不适合把账号密码写进仓库。推荐用 Nintendo 授权回调拿到本地 Token，然后只保存在 `.private/` 目录：

```text
.private/
```

`.private/` 已加入 `.gitignore`，不要提交到 GitHub。

Switch 这条链路的思路是：

1. 通过 Nintendo 授权链接登录。
2. 在 “Linking an External Account / 选择此人” 页面复制 `npf5c38e31cd085304b://auth#session_token_code=...` 回调链接。
3. 用回调里的 `session_token_code` 换取本地 session token。
4. 调用可访问的 Nintendo 游玩记录接口获取游戏名和时长。
5. 将结果写入 `source/_data/game-platforms.json` 的 `switch` 数组。

Switch 没有稳定公开的封面来源，所以建议把 Switch 封面全部作为自定义字段处理：

- 初次导入时没有封面就留空。
- 你手动填写 `cover` 后，后续自动更新不要覆盖它。
- 推荐把封面放到 `source/images/games/`，再写成 `/images/games/xxx.jpg`。

Switch 游戏项建议字段：

```json
{
  "name": "Game Name",
  "hours": 12.5,
  "minutes": 750,
  "cover": "/images/games/switch-game.jpg",
  "last_played": "2026-01-01",
  "status": "Switch 导入"
}
```

如果授权链接提示过期，需要重新发起授权并立刻复制新的 `npf5c38e31cd085304b://auth...` 链接。这个链接有效期很短。

## 博客管理器

```bash
cd admin
npm install
node server.js
```

管理器可以编辑文章、书籍、影视、画廊、分类、日记等数据。文章编辑页包含“密码（留空则不加密）”字段，留空就不会写入 `password`。

## GitHub 上传方式

如果远程仓库还没有绑定：

```bash
git remote add origin https://github.com/你的用户名/你的仓库名.git
```

如果已经有 `origin`，改地址用：

```bash
git remote set-url origin https://github.com/你的用户名/你的仓库名.git
```

提交并推送：

```bash
git add .
git commit -m "update blog template"
git push -u origin main
```

如果远程仓库已有初始化提交，先拉取再推送：

```bash
git pull origin main --rebase
git push -u origin main
```

如果提示有未提交修改，先提交：

```bash
git add .
git commit -m "update blog template"
git pull origin main --rebase
git push
```

## 开源前检查

发布到 GitHub 前建议确认：

- `_config.yml` 没有私人域名、API Key、部署 Token。
- `themes/next/_config.yml` 的评论、统计、菜单配置已经改成自己的。
- `source/_posts/` 只包含愿意公开的文章。
- `source/_data/` 不包含私人书单、影视、日记、相册或真实游戏账号数据。
- `.private/`、`node_modules/`、`public/`、`.deploy_git/`、`db.json` 不提交。
- Steam API Key 尽量使用环境变量，不写进仓库。
- Nintendo / Switch 授权 Token 只保存在本机 `.private/`。

## 更多说明

更完整的页面字段、专属页面介绍和常见问题见 [USAGE.md](USAGE.md)。

## 许可证

请根据自己的开源计划添加 `LICENSE` 文件，例如 MIT、Apache-2.0 或其他许可证。