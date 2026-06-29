# 使用说明

这份模板适合搭建个人博客、阅读记录站、影视记录站、摄影画廊或轻量作品集。它保留了完整功能结构，但内容均为空白示例，适合直接改成自己的站点。

## 环境准备

需要安装：

- Node.js 18 或更高版本
- Git
- 一个 GitHub 仓库或其他静态站托管仓库

安装依赖：

```bash
npm install
```

本地预览：

```bash
npm run server
```

生成静态站点：

```bash
npm run build
```

生成结果会输出到 `public/`，该目录不建议提交到源码仓库。

## 基础配置

主要配置在 `_config.yml`：

- `title`：站点名称
- `subtitle`：副标题
- `description`：站点描述
- `author`：作者名
- `url`：线上站点地址
- `language`：站点语言
- `theme`：当前使用 `next`
- `search`：搜索索引配置
- `deploy`：部署仓库配置

主题配置在 `themes/next/_config.yml`，可继续调整菜单、侧栏、评论、动画、布局等。

## 写文章

文章放在：

```text
source/_posts/
```

示例 front matter：

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

这里写正文。
```

### 封面图字段

首页文章卡片读取的封面字段是：

```yaml
thumbnail: /images/example.jpg
```

建议所有文章封面使用相近比例的横图。模板会固定显示比例，多余部分裁剪，不会拉伸图片。

### 密码文章

如果文章需要前端密码验证，在 front matter 加：

```yaml
password: 1234
```

如果不需要密码，不写 `password` 字段即可。使用博客管理器时，密码输入框留空就不会写入该字段。

注意：这是前端展示层面的轻量保护，适合普通访问限制，不适合保存高敏感内容。

## 专属页面介绍

### 首页

路径：`/`

首页展示文章预览卡片，包括封面、标题、摘要、日期、分类、标签和阅读全文入口。带密码的文章会显示加密提示，不直接暴露摘要。

### 关于

路径：`/about/`

文件：`source/about/index.md`

用于放个人介绍、站点说明、联系方式或博客建设记录。纯净版内是占位文本。

### 书单

路径：`/books/`

页面文件：`source/books/index.md`

数据文件：`source/_data/books.yml`

用于展示阅读记录、评分、出版社、阅读时间、短评、书评链接、书摘链接等。数据为空时不会展示私人内容。

示例数据：

```yaml
- title: 示例书籍
  author: 作者名
  stars: 5
  reading_time: 2026-01
  category: 文学
  publisher: 出版社
  cover: /images/book-cover.jpg
  summary: 简短评价。
  review: /books/review/example/
  notes: /books/notes/example/
```

### 影视

路径：`/movies/`

页面文件：`source/movies/index.md`

数据文件：`source/_data/movies.yml`

用于展示电影、剧集或动画记录，包括评分、导演、演员、年份、海报、观看时间和详情链接。

示例数据：

```yaml
- title: 示例影片
  rating: 8.8
  director: 导演名
  actors: 演员名
  year: 2026
  duration: 120 分钟
  country: 国家或地区
  category: 剧情
  poster: /images/movie-poster.jpg
  watching_time: 2026-01
  summary: 简短评价。
```

### 日记

路径：`/diary/`

文件：`source/diary/index.md`

用于展示日常记录、心情、天气、图片等。你可以通过管理器维护，也可以自行扩展数据格式。

### 画廊

路径：`/gallery/`

页面文件：`source/gallery/index.md`

用于展示相册列表和单个相册页。建议横图优先，模板会按横图展示，避免被拉成竖图。

### 烘焙

路径：`/bake/`

文件：`source/bake/index.md`

用于展示烘焙记录、配方、成品图或过程笔记。纯净版只保留页面入口。

### 游戏

路径：`/steamgames/`

文件：`source/steamgames/index.md`

用于展示游戏记录。`_config.yml` 中 `steam.enable` 默认为 `false`，需要使用 Steam 数据时再填入自己的 `steamId` 和 `apiKey`。

### 实验室

路径：`/lab/`

文件：`source/lab/index.md`

用于放实验性页面、互动小工具、年度页面、小游戏或前端练习。纯净版已移除原站个人报告内容，只保留入口。

### 日程表

路径：`/schedule/`

文件：`source/schedule/index.md`

用于展示计划、课程表、待办或时间轴内容。

### 资源

路径：`/resources/`

文件：`source/resources/index.md`

用于整理公开资源、下载链接、学习链接或项目链接。

### 归档

路径：`/archives/`

由 Hexo 自动生成，按时间展示文章。

### 标签

路径：`/tags/`

文件：`source/tags/index.md`

由 Hexo 根据文章 front matter 中的 `tags` 自动生成。适合从关键词维度浏览文章。

### 分类

路径：`/categories/`

文件：`source/categories/index.md`

由 Hexo 根据文章 front matter 中的 `categories` 自动生成。模板也支持通过 `source/_data/categories.yml` 补充分类封面、说明、图标等展示信息。

### 公益 404

路径：`/404/`

文件：`source/404/index.md`

用于自定义 404 页面。可以替换为普通 404、公益 404 或自己的错误页设计。

### 搜索

搜索索引由 `hexo-generator-search` 生成，配置在 `_config.yml`：

```yaml
search:
  path: search.xml
  field: all
  content: true
```

`field: all` 会索引文章和页面，适合全站搜索。

## 博客管理器

管理器源码在：

```text
admin/
```

启动：

```bash
cd admin
npm install
node server.js
```

支持维护：

- 文章
- 书籍/书摘
- 画廊
- 分类
- 日记
- 影视

文章编辑页包含 `密码（留空则不加密）` 字段。留空时不会写入 front matter，填写后会写入 `password`。

Windows 启动器源码在 `launcher/`，可按需用 Visual Studio 或 `dotnet` 工具链编译。

## 桌宠

桌宠资源在：

```text
source/images/pets/
source/js/makima-pet.js
source/css/makima-pet.css
```

如果不需要桌宠，可以删除对应资源，并从主题注入位置移除相关 JS/CSS 引用。

## 部署到 GitHub Pages

在 `_config.yml` 中配置：

```yaml
deploy:
  type: git
  repository: https://github.com/your-name/your-name.github.io.git
  branch: main
```

生成并部署：

```bash
npm run build
npm run deploy
```

如果是项目页仓库，`url` 和部署分支请按 GitHub Pages 设置调整。

## 开源前建议

发布前建议确认：

- `_config.yml` 没有私人域名、API Key、部署仓库 token
- `source/_posts/` 只包含你愿意公开的文章
- `source/_data/` 不包含私人阅读、影视、分类数据
- `source/gallery/` 不包含私人照片说明或原图
- `public/`、`node_modules/`、`.deploy_git/` 不提交
- 评论系统仓库 ID 已换成自己的，或保持关闭

## 常见问题

### 修改后页面没变化

先清理再生成：

```bash
npm run clean
npm run build
```

### 搜索没有结果

确认已经执行过 `npm run build`，并且生成了 `public/search.xml`。

### 图片不显示

确认图片路径放在 `source/images/` 下，并使用 `/images/xxx.jpg` 这样的站点绝对路径。

### 密码文章无法进入

确认文章 front matter 中的 `password` 是普通字符串或数字，例如：

```yaml
password: 1234
```

不要把密码写进正文，也不要在密码字段里添加多余空格。