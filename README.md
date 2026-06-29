# HEXO-NEXT-style-apple

这是一个基于 Hexo + NexT 深度定制的博客模板，整体偏向 Apple / Butterfly 风格，包含圆角卡片、顶部菜单、专属页面、搜索、密码文章前端验证、桌宠、博客管理器等功能。

这是纯净开源版，不包含原站文章、书摘、日记、相册数据、报告、个人域名、部署仓库、Steam ID、API Key 或评论仓库 ID。

## 功能

- Hexo 7 博客源码与 NexT 主题定制
- 首页文章预览卡片与封面图
- 关于、书单、影视、日记、画廊、烘焙、游戏、实验室、日程表、资源页等专属页面
- 归档、标签、分类页面
- 全站搜索索引
- 可选密码文章前端验证
- 可拖动桌宠
- 本地博客管理器 Web 端与 Windows 启动器源码

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

## 博客管理器

```bash
cd admin
npm install
node server.js
```

打开管理器后选择博客根目录，即可编辑文章、书籍、影视、画廊、分类、日记等数据。文章的 `密码（留空则不加密）` 字段为空时不会写入 `password`。

## 文档

完整使用说明见 [USAGE.md](USAGE.md)。

## 目录说明

```text
source/                 Hexo 页面、文章和静态资源
source/_posts/          文章 Markdown
source/_data/           书单、影视、分类等结构化数据
themes/next/            定制后的 NexT 主题
admin/                  博客管理器 Web 端
launcher/               Windows 管理器启动器源码
BlogAdmin/              管理器图标资源
```

## 自己上传到 GitHub

1. 在 GitHub 新建一个空仓库，例如 `HEXO-NEXT-style-apple`。
2. 打开本地终端，进入这个项目目录。
3. 绑定远端仓库：

```bash
git remote set-url origin https://github.com/你的用户名/仓库名.git
```

4. 如果远端仓库已经自带初始提交，先拉一次再推：

```bash
git pull origin main --rebase
```

5. 推送到 GitHub：

```bash
git push -u origin main
```

如果以后继续更新：

```bash
git add .
git commit -m "update"
git push
```

## 发布前检查

- `_config.yml` 里的站点名、作者、链接、部署仓库改成你自己的
- `themes/next/_config.yml` 里的菜单、评论、统计配置改成你自己的
- `source/_posts/` 只保留你愿意公开的内容
- 不要提交 `node_modules/`、`public/`、`.git/`、`.deploy_git/`、`db.json`

## 许可证

请根据自己的开源计划添加 `LICENSE` 文件，例如 MIT、Apache-2.0 或其他许可证。
