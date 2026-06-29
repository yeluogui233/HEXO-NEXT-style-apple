# HEXO-NEXT-style-apple
=======
# HEXO NexT Style Apple
>>>>>>> e86b415 (Fix TOC jump after unlock)

这是一个基于 Hexo + NexT 深度定制的博客模板，整体偏向 Apple / Butterfly 风格，包含圆角卡片、顶部菜单、专属页面、搜索、密码文章前端验证、桌宠、博客管理器等功能。

这是纯净开源版，不包含原站文章、书摘、日记、相册数据、报告、个人域名、部署仓库、Steam ID、API Key 或评论仓库 ID。

## 功能

- Hexo 7 博客源码与 NexT 主题定制
- 首页文章预览卡片与封面图
- 关于、书单、影视、日记、画廊、烘焙、游戏、实验室、日程表、资源页
- 归档、标签、分类页面
- 全站搜索索引
- 可选密码文章前端验证
- 可拖动桌宠
- 本地博客管理器 Web 端与 Windows 启动器源码

## 目录

- `source/`：页面、文章和静态资源
- `source/_posts/`：文章 Markdown
- `source/_data/`：书单、影视、分类等结构化数据
- `themes/next/`：定制后的 NexT 主题
- `admin/`：博客管理器 Web 端
- `launcher/`：Windows 启动器源码
- `BlogAdmin/`：管理器图标资源

## 本地运行

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

管理器可以编辑文章、书籍、影视、画廊、分类、日记等数据。文章编辑页包含 `密码（留空则不加密）` 字段，留空就不会写入密码。
