const http = require('http');
const fs = require('fs');
const path = require('path');
const { spawn } = require('child_process');
const yaml = require('js-yaml');

const PORT = Number(process.env.BLOG_ADMIN_PORT || 4788);
const DEFAULT_ROOT = path.resolve(process.env.BLOG_ROOT || findDefaultRoot());
const JSON_SCHEMA = yaml.JSON_SCHEMA;
const publicDir = path.join(__dirname, 'public');

function findDefaultRoot() {
  const candidates = ['F:\\Blog', 'E:\\Blog', path.resolve(__dirname, '..'), process.cwd()];
  return candidates.find(root => fs.existsSync(path.join(root, '_config.yml')) && fs.existsSync(path.join(root, 'source'))) || process.cwd();
}

function send(res, status, body, type = 'application/json') {
  const payload = type === 'application/json' ? JSON.stringify(body) : body;
  res.writeHead(status, { 'Content-Type': `${type}; charset=utf-8`, 'Cache-Control': 'no-store' });
  res.end(payload);
}

function bad(res, status, message) {
  send(res, status, { error: message });
}

function readBody(req) {
  return new Promise((resolve, reject) => {
    let body = '';
    req.on('data', chunk => {
      body += chunk;
      if (body.length > 24 * 1024 * 1024) {
        reject(new Error('请求内容太大'));
        req.destroy();
      }
    });
    req.on('end', () => {
      try {
        resolve(body ? JSON.parse(body) : {});
      } catch (error) {
        reject(new Error(`JSON 格式不正确：${error.message}`));
      }
    });
    req.on('error', reject);
  });
}

function rootFromQuery(url) {
  return path.resolve(url.searchParams.get('root') || DEFAULT_ROOT);
}

function rootFromRequest(req) {
  const parsed = new URL(req.url, `http://${req.headers.host}`);
  return rootFromQuery(parsed);
}

function assertBlogRoot(root) {
  for (const file of [path.join(root, '_config.yml'), path.join(root, 'source')]) {
    if (!fs.existsSync(file)) throw new Error(`这里不像 Hexo 博客根目录：${root}`);
  }
}

function ensureInside(root, target) {
  const resolvedRoot = path.resolve(root);
  const resolvedTarget = path.resolve(target);
  if (resolvedTarget !== resolvedRoot && !resolvedTarget.startsWith(`${resolvedRoot}${path.sep}`)) {
    throw new Error(`拒绝访问博客目录外的文件：${resolvedTarget}`);
  }
  return resolvedTarget;
}

function filePath(root, kind) {
  return {
    diary: path.join(root, 'source', 'diary', 'index.md'),
    books: path.join(root, 'source', '_data', 'books.yml'),
    movies: path.join(root, 'source', '_data', 'movies.yml'),
    categories: path.join(root, 'source', '_data', 'categories.yml'),
    gallery: path.join(root, 'source', 'gallery', 'index.md'),
    posts: path.join(root, 'source', '_posts')
  }[kind];
}

function loadYamlFile(file, fallback) {
  if (!fs.existsSync(file)) return fallback;
  return yaml.load(fs.readFileSync(file, 'utf8'), { schema: JSON_SCHEMA }) || fallback;
}

function parseFrontMatter(file, fallbackData = {}) {
  const source = fs.existsSync(file) ? fs.readFileSync(file, 'utf8') : `---\n${dumpYaml(fallbackData)}---\n`;
  const match = source.match(/^---\r?\n([\s\S]*?)\r?\n---\s*([\s\S]*)$/);
  if (!match) throw new Error(`${file} 没有标准 front matter`);
  return {
    data: yaml.load(match[1], { schema: JSON_SCHEMA }) || {},
    content: (match[2] || '').replace(/^\r?\n/, '')
  };
}

function dumpYaml(data) {
  return yaml.dump(data, { schema: JSON_SCHEMA, lineWidth: -1, noRefs: true, sortKeys: false, quotingType: '"', forceQuotes: false });
}

function backup(file) {
  if (!fs.existsSync(file)) return;
  const stamp = new Date().toISOString().replace(/[:.]/g, '-');
  const resolved = path.resolve(file);
  const root = path.parse(resolved).root;
  const rootName = root.replace(/[\\/:]/g, '') || 'root';
  const relative = path.relative(root, resolved);
  const backupFile = path.join(__dirname, 'backups', rootName, `${relative}.${stamp}.bak`);
  fs.mkdirSync(path.dirname(backupFile), { recursive: true });
  fs.copyFileSync(resolved, backupFile);
}

function writeAtomic(file, content) {
  fs.mkdirSync(path.dirname(file), { recursive: true });
  backup(file);
  const temp = `${file}.${process.pid}.tmp`;
  fs.writeFileSync(temp, content, 'utf8');
  fs.renameSync(temp, file);
}

function removeFileWithBackup(file) {
  if (!fs.existsSync(file)) return;
  backup(file);
  fs.unlinkSync(file);
}

function slugify(text, fallback = 'new-post') {
  const slug = String(text || '').trim().replace(/[\\/:*?"<>|#%{}^~[\]`;@=&]+/g, '-').replace(/\s+/g, '-').replace(/-+/g, '-').replace(/^-|-$/g, '');
  return slug || fallback;
}

function normalizeArray(value) {
  if (Array.isArray(value)) return value.map(item => String(item || '').trim()).filter(Boolean);
  return String(value || '').split(/[,\n，]/).map(item => item.trim()).filter(Boolean);
}

function normalizeDiary(diary = {}) {
  return {
    date: String(diary.date || '').trim(),
    weekday: String(diary.weekday || '').trim(),
    weather: String(diary.weather || '').trim(),
    mood: String(diary.mood || '').trim(),
    tags: normalizeArray(diary.tags),
    images: Array.isArray(diary.images) ? diary.images.map(item => String(item || '').trim()).filter(Boolean) : String(diary.images || '').split('\n').map(item => item.trim()).filter(Boolean),
    content: String(diary.content || '').replace(/\r\n/g, '\n')
  };
}

function normalizeEntry(entry, fields) {
  const normalized = {};
  for (const field of fields) {
    const value = entry[field];
    if (field === 'stars' || field === 'rating') {
      const text = String(value ?? '').trim();
      const number = Number(text);
      normalized[field] = text && !Number.isNaN(number) ? number : text;
    } else {
      normalized[field] = String(value ?? '').replace(/\r\n/g, '\n').trim();
    }
  }
  return normalized;
}

function notesFileFromLink(root, link) {
  const text = String(link || '').trim();
  if (!text) return '';
  let pathname = text;
  try {
    pathname = new URL(text, 'http://local').pathname;
  } catch {}
  pathname = decodeURIComponent(pathname).replace(/^\/+/, '').replace(/\/+$/, '');
  if (!pathname.endsWith('/index.md')) pathname = path.join(pathname, 'index.md');
  return ensureInside(root, path.join(root, pathname.startsWith('source') ? pathname : path.join('source', pathname)));
}

function stripMarkdownMarker(line) {
  return line.replace(/^\s*[-*+]\s+/, '').trim();
}

function extractListItems(markdown) {
  return String(markdown || '')
    .split(/\r?\n/)
    .filter(line => /^\s*[-*+]\s+/.test(line))
    .map(stripMarkdownMarker)
    .filter(Boolean);
}

function attachBookNotes(root, books) {
  return books.map(book => {
    const next = { ...book };
    try {
      const file = notesFileFromLink(root, book.notes);
      if (file && fs.existsSync(file)) {
        const parsed = parseFrontMatter(file);
        next._notesFile = file;
        next._notesTitle = parsed.data.title || '';
        next._notesContent = parsed.content.trim();
        next._notesItems = extractListItems(parsed.content);
      } else {
        next._notesFile = file || '';
        next._notesContent = '';
        next._notesItems = [];
      }
    } catch (error) {
      next._notesError = error.message;
      next._notesContent = '';
      next._notesItems = [];
    }
    return next;
  });
}

function saveBookNotes(root, book) {
  const content = String(book._notesContent ?? '').replace(/\r\n/g, '\n').trimEnd();
  const link = String(book.notes || '').trim();
  if (!link || (!content && !book._notesFile)) return;

  const file = notesFileFromLink(root, link);
  let data = {
    title: `${book.title || '未命名'}书摘`,
    layout: 'notes',
    date: new Date().toISOString().slice(0, 19).replace('T', ' ')
  };

  if (fs.existsSync(file)) data = parseFrontMatter(file).data;
  writeAtomic(file, `---\n${dumpYaml(data)}---\n${content ? `\n${content}\n` : '\n'}`);
}

function normalizePost(post = {}) {
  const data = {};
  const title = String(post.title || '').trim() || '未命名文章';
  data.title = title;
  if (post.date) data.date = String(post.date).trim();
  if (post.updated) data.updated = String(post.updated).trim();
  if (post.thumbnail) data.thumbnail = String(post.thumbnail).trim();
  if (post.description) data.description = String(post.description).trim();
  if (post.password) data.password = String(post.password).trim();
  data.tags = normalizeArray(post.tags);
  data.categories = normalizeArray(post.categories);
  for (const [key, value] of Object.entries(post.extra || {})) {
    if (!['title', 'date', 'updated', 'thumbnail', 'description', 'password', 'tags', 'categories'].includes(key)) data[key] = value;
  }
  return { id: post.id || '', filename: slugify(post.filename || title, 'new-post'), data, content: String(post.content || '').replace(/\r\n/g, '\n') };
}

function dateValue(value) {
  const text = String(value || '');
  const match = text.match(/(\d{4})[-/](\d{1,2})[-/](\d{1,2})(?:[ T](\d{1,2}):(\d{1,2})(?::(\d{1,2}))?)?/);
  if (!match) return 0;
  const [, year, month, day, hour = '0', minute = '0', second = '0'] = match;
  return new Date(Number(year), Number(month) - 1, Number(day), Number(hour), Number(minute), Number(second)).getTime() || 0;
}

function parseLooseDate(value) {
  const text = String(value || '').trim();
  const match = text.match(/(\d{4})[-/年](\d{1,2})(?:[-/月](\d{1,2}))?/);
  if (!match) return null;
  const [, year, month, day = '1'] = match;
  const date = new Date(Number(year), Number(month) - 1, Number(day));
  if (date.getFullYear() !== Number(year) || date.getMonth() !== Number(month) - 1 || date.getDate() !== Number(day)) return null;
  return date;
}

function normalizeReportPeriod(value) {
  const text = String(value || '').trim();
  const yearOnly = text.match(/^(\d{4})$/);
  if (yearOnly) return { type: 'year', year: Number(yearOnly[1]), key: yearOnly[1] };
  const month = text.match(/^(\d{4})[-/](\d{1,2})$/);
  if (!month) throw new Error('报告周期格式应为 YYYY 或 YYYY-MM');
  const year = Number(month[1]);
  const monthNumber = Number(month[2]);
  if (monthNumber < 1 || monthNumber > 12) throw new Error('月份必须在 1 到 12 之间');
  return { type: 'month', year, month: monthNumber, key: `${year}-${String(monthNumber).padStart(2, '0')}` };
}

function dateInPeriod(date, period) {
  if (!date) return false;
  if (date.getFullYear() !== period.year) return false;
  return period.type === 'year' || date.getMonth() + 1 === period.month;
}

function reportTitle(period) {
  return period.type === 'year' ? `${period.year}年度报告` : `${period.year}年${period.month}月月度报告`;
}

function reportUrl(period) {
  return `/reports/${period.key}/`;
}

function escapeHtmlReport(value) {
  return String(value ?? '').replace(/[&<>"']/g, char => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' }[char]));
}

function stripText(value, max = 120) {
  const text = String(value || '')
    .replace(/```[\s\S]*?```/g, ' ')
    .replace(/!\[[^\]]*]\([^)]*\)/g, ' ')
    .replace(/\[[^\]]*]\([^)]*\)/g, match => match.replace(/^\[|\]\([^)]*\)$/g, ''))
    .replace(/[#>*_`~|:-]+/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
  return text.length > max ? `${text.slice(0, max)}...` : text;
}

function countValues(values) {
  const map = new Map();
  for (const value of values.map(item => String(item || '').trim()).filter(Boolean)) map.set(value, (map.get(value) || 0) + 1);
  return [...map.entries()].sort((a, b) => b[1] - a[1] || a[0].localeCompare(b[0], 'zh-Hans-CN'));
}

function bookStars(book) {
  const number = Number(book?.stars);
  return Number.isFinite(number) ? number : null;
}

function bookCategories(book) {
  return String(book?.category || '').split(/\s+/).map(item => item.trim()).filter(Boolean);
}

function monthKeyFromDate(date) {
  return `${date.getFullYear()}-${String(date.getMonth() + 1).padStart(2, '0')}`;
}

function collectReportData(root, period) {
  const data = loadAll(root);
  const diaries = (data.diary.diaries || [])
    .map(item => ({ ...item, _date: parseLooseDate(item.date) }))
    .filter(item => dateInPeriod(item._date, period))
    .sort((a, b) => a._date - b._date);
  const books = (data.books || [])
    .map(item => ({ ...item, _date: parseLooseDate(item.reading_time) }))
    .filter(item => dateInPeriod(item._date, period))
    .sort((a, b) => a._date - b._date);
  const yearItems = [
    ...(data.diary.diaries || []).map(item => parseLooseDate(item.date)),
    ...(data.books || []).map(item => parseLooseDate(item.reading_time))
  ].filter(date => date && date.getFullYear() === period.year);
  const months = [...new Set(yearItems.map(monthKeyFromDate))].sort();
  if (period.type === 'month' && !months.includes(period.key)) months.push(period.key);
  months.sort();
  const numericStars = books.map(bookStars).filter(value => value !== null);
  return {
    period,
    diaries,
    books,
    months,
    moodCounts: countValues(diaries.map(item => item.mood)),
    weatherCounts: countValues(diaries.map(item => item.weather)),
    diaryTagCounts: countValues(diaries.flatMap(item => normalizeArray(item.tags))),
    bookCategoryCounts: countValues(books.flatMap(bookCategories)),
    averageStars: numericStars.length ? (numericStars.reduce((sum, value) => sum + value, 0) / numericStars.length).toFixed(1) : '0',
    topBooks: [...books].sort((a, b) => (bookStars(b) || 0) - (bookStars(a) || 0)).slice(0, 12)
  };
}

function renderReportNav(model) {
  const yearLink = `<a class="report-chip${model.period.type === 'year' ? ' active' : ''}" href="${reportUrl({ type: 'year', year: model.period.year, key: String(model.period.year) })}">${model.period.year}年度总览</a>`;
  const monthLinks = model.months.map(key => {
    const [, rawMonth] = key.split('-');
    return `<a class="report-chip${model.period.key === key ? ' active' : ''}" href="/reports/${key}/">${Number(rawMonth)}月</a>`;
  }).join('');
  return `<nav class="report-nav">${yearLink}${monthLinks}</nav>`;
}

function renderStatCard(value, label, note = '') {
  return `<div class="report-stat"><strong>${escapeHtmlReport(value)}</strong><span>${escapeHtmlReport(label)}</span>${note ? `<small>${escapeHtmlReport(note)}</small>` : ''}</div>`;
}

function renderReportPage(model) {
  const title = reportTitle(model.period);
  const topMood = model.moodCounts[0]?.[0] || '暂无';
  const topCategory = model.bookCategoryCounts[0]?.[0] || '暂无';
  const diaryDays = new Set(model.diaries.map(item => item.date)).size;
  const bookCards = model.topBooks.length ? model.topBooks.map(book => `
      <article class="book-card">
        ${book.cover ? `<img src="${escapeHtmlReport(book.cover)}" alt="${escapeHtmlReport(book.title)}">` : '<div class="cover-fallback"></div>'}
        <div>
          <h3>${escapeHtmlReport(book.title)}</h3>
          <p>${escapeHtmlReport([book.author, book.reading_time, book.stars ? `${book.stars}分` : ''].filter(Boolean).join(' / '))}</p>
          <small>${escapeHtmlReport(stripText(book.summary, 90))}</small>
        </div>
      </article>`).join('') : '<p class="empty-report">这个周期还没有读完书。</p>';
  const diaryCards = model.diaries.length ? model.diaries.map(item => `
      <article class="diary-card">
        <time>${escapeHtmlReport([item.date, item.weekday].filter(Boolean).join(' '))}</time>
        <h3>${escapeHtmlReport([item.mood, item.weather].filter(Boolean).join(' / ') || '一则日记')}</h3>
        <p>${escapeHtmlReport(stripText(item.content, 150))}</p>
      </article>`).join('') : '<p class="empty-report">这个周期还没有日记。</p>';
  const tagBars = [...model.diaryTagCounts.slice(0, 8), ...model.bookCategoryCounts.slice(0, 8)].slice(0, 12);
  const maxTag = Math.max(1, ...tagBars.map(([, count]) => count));
  const bars = tagBars.length ? tagBars.map(([name, count]) => `<div class="report-bar"><span>${escapeHtmlReport(name)}</span><i style="width:${Math.round((count / maxTag) * 100)}%"></i><b>${count}</b></div>`).join('') : '<p class="empty-report">暂无标签数据。</p>';
  const frontMatter = {
    title,
    date: new Date().toISOString().slice(0, 19).replace('T', ' '),
    layout: 'page',
    comments: false
  };
  return `---\n${dumpYaml(frontMatter)}---\n\n<style>
.monthly-report{--bg:#111827;--panel:#1b2838;--panel2:#22384f;--line:rgba(255,255,255,.12);--text:#e5eef9;--muted:#9fb4ca;--green:#66c0f4;--gold:#c7a45d;max-width:1180px;margin:0 auto;padding:28px;color:var(--text);background:radial-gradient(circle at 20% 0,#25486b 0,transparent 30%),linear-gradient(135deg,#101822,#17263a 55%,#0e151f);border-radius:18px}
.monthly-report *{box-sizing:border-box}.report-hero{min-height:280px;display:grid;align-content:end;padding:36px;border:1px solid var(--line);background:linear-gradient(140deg,rgba(102,192,244,.18),rgba(199,164,93,.10)),var(--panel);border-radius:14px}.report-kicker{color:var(--green);font-weight:800;letter-spacing:.08em}.report-hero h1{margin:.25em 0;font-size:clamp(36px,7vw,76px);line-height:1}.report-hero p{max-width:720px;color:var(--muted);font-size:18px}.report-nav{display:flex;flex-wrap:wrap;gap:10px;margin:18px 0}.report-chip{padding:9px 13px;border:1px solid var(--line);border-radius:999px;color:var(--text);background:rgba(255,255,255,.06);text-decoration:none}.report-chip.active{border-color:var(--green);background:rgba(102,192,244,.18)}.report-stats{display:grid;grid-template-columns:repeat(auto-fit,minmax(160px,1fr));gap:12px;margin:18px 0}.report-stat{padding:18px;border:1px solid var(--line);border-radius:12px;background:linear-gradient(180deg,rgba(255,255,255,.08),rgba(255,255,255,.03))}.report-stat strong{display:block;font-size:34px;color:#fff}.report-stat span,.report-stat small{display:block;color:var(--muted)}.report-section{margin-top:22px;padding:22px;border:1px solid var(--line);border-radius:14px;background:rgba(27,40,56,.72)}.report-section h2{margin-top:0}.book-grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(260px,1fr));gap:14px}.book-card{display:grid;grid-template-columns:76px 1fr;gap:12px;min-height:128px;padding:12px;border:1px solid var(--line);border-radius:12px;background:linear-gradient(90deg,rgba(102,192,244,.12),rgba(255,255,255,.04))}.book-card img,.cover-fallback{width:76px;height:104px;object-fit:cover;border-radius:7px;background:#2d3f55}.book-card h3{margin:0 0 6px;font-size:17px}.book-card p,.book-card small,.diary-card p{color:var(--muted)}.diary-list{display:grid;gap:12px}.diary-card{padding:14px;border-left:4px solid var(--green);border-radius:10px;background:rgba(255,255,255,.05)}.diary-card time{color:var(--gold);font-weight:800}.diary-card h3{margin:6px 0}.report-bars{display:grid;gap:10px}.report-bar{display:grid;grid-template-columns:120px 1fr 36px;gap:10px;align-items:center}.report-bar i{display:block;height:10px;border-radius:999px;background:linear-gradient(90deg,var(--green),var(--gold))}.report-bar b{color:var(--green)}.empty-report{color:var(--muted)}
</style>

<div class="monthly-report">
  <section class="report-hero">
    <div class="report-kicker">STEAM STYLE RECAP</div>
    <h1>${escapeHtmlReport(title)}</h1>
    <p>从日记和书籍记录里自动生成的本地总结：读了什么、写了多少、哪些情绪和主题反复出现。</p>
  </section>
  ${renderReportNav(model)}
  <section class="report-stats">
    ${renderStatCard(model.diaries.length, '日记条数', `${diaryDays} 个记录日`)}
    ${renderStatCard(model.books.length, '读完书籍', `平均 ${model.averageStars} 分`)}
    ${renderStatCard(topMood, '本期高频心情')}
    ${renderStatCard(topCategory, '阅读主分类')}
  </section>
  <section class="report-section">
    <h2>阅读星系</h2>
    <div class="book-grid">${bookCards}</div>
  </section>
  <section class="report-section">
    <h2>生活轨迹</h2>
    <div class="diary-list">${diaryCards}</div>
  </section>
  <section class="report-section">
    <h2>主题热度</h2>
    <div class="report-bars">${bars}</div>
  </section>
</div>
`;
}

function writeReportPage(root, period) {
  const model = collectReportData(root, period);
  const reportDir = ensureInside(root, path.join(root, 'source', 'reports', period.key));
  const reportFile = ensureInside(root, path.join(reportDir, 'index.md'));
  writeAtomic(reportFile, renderReportPage(model));
  return { title: reportTitle(period), file: reportFile, url: reportUrl(period), counts: { diaries: model.diaries.length, books: model.books.length }, months: model.months };
}

function generateReport(root, periodInput) {
  assertBlogRoot(root);
  const period = normalizeReportPeriod(periodInput);
  const yearPeriod = { type: 'year', year: period.year, key: String(period.year) };
  const yearResult = writeReportPage(root, yearPeriod);
  for (const key of yearResult.months) {
    const [, month] = key.split('-');
    writeReportPage(root, { type: 'month', year: period.year, month: Number(month), key });
  }
  if (period.type === 'year') return { ...yearResult, generated: yearResult.months.length + 1 };
  const monthResult = writeReportPage(root, period);
  return { ...monthResult, generated: yearResult.months.length + 1 };
}

function readPosts(root) {
  const postsDir = filePath(root, 'posts');
  if (!fs.existsSync(postsDir)) return [];
  return fs.readdirSync(postsDir).filter(name => name.toLowerCase().endsWith('.md')).map(name => {
    const parsed = parseFrontMatter(path.join(postsDir, name));
    const data = parsed.data;
    const known = new Set(['title', 'date', 'updated', 'thumbnail', 'description', 'password', 'tags', 'categories']);
    const extra = {};
    for (const [key, value] of Object.entries(data)) if (!known.has(key)) extra[key] = value;
    return {
      id: name,
      filename: path.basename(name, '.md'),
      title: data.title || path.basename(name, '.md'),
      date: data.date || '',
      updated: data.updated || '',
      thumbnail: data.thumbnail || '',
      description: data.description || '',
      password: data.password || '',
      tags: normalizeArray(data.tags),
      categories: normalizeArray(data.categories),
      extra,
      content: parsed.content
    };
  }).sort((a, b) => (dateValue(b.date) - dateValue(a.date)) || a.title.localeCompare(b.title, 'zh-Hans-CN'));
}

function normalizeAlbum(album = {}) {
  const pathValue = String(album.path || '').trim();
  return { name: String(album.name || '').trim() || '未命名相册', cover: String(album.cover || '').trim(), desc: String(album.desc || '').trim(), path: pathValue || `/gallery/${slugify(album.slug || album.name, 'album')}/` };
}

function albumSlugFromPath(albumPath, name) {
  const match = String(albumPath || '').match(/^\/?gallery\/([^/]+)\/?$/);
  return slugify(match ? match[1] : name, 'album');
}

function normalizePhoto(photo = {}) {
  return { url: String(photo.url || '').trim(), desc: String(photo.desc || '').trim(), location: String(photo.location || '').trim(), date: String(photo.date || '').trim() };
}

function readGallery(root) {
  const parsed = parseFrontMatter(filePath(root, 'gallery'), { title: '画廊', layout: 'gallery', albums: [] });
  const albums = Array.isArray(parsed.data.albums) ? parsed.data.albums : [];
  return {
    title: parsed.data.title || '画廊',
    window_title: parsed.data.window_title || '',
    layout: parsed.data.layout || 'gallery',
    comment: parsed.data.comment ?? false,
    extra: Object.fromEntries(Object.entries(parsed.data).filter(([key]) => !['title', 'window_title', 'layout', 'comment', 'albums'].includes(key))),
    albums: albums.map(album => {
      const normalized = normalizeAlbum(album);
      const slug = albumSlugFromPath(normalized.path, normalized.name);
      const albumFile = path.join(root, 'source', 'gallery', slug, 'index.md');
      const detail = fs.existsSync(albumFile) ? parseFrontMatter(albumFile) : { data: { title: normalized.name, window_title: normalized.name, layout: 'album', photos: [] } };
      return { ...normalized, slug, title: detail.data.title || normalized.name, window_title: detail.data.window_title || '', layout: detail.data.layout || 'album', photos: Array.isArray(detail.data.photos) ? detail.data.photos.map(normalizePhoto) : [], albumExtra: Object.fromEntries(Object.entries(detail.data).filter(([key]) => !['title', 'window_title', 'layout', 'photos'].includes(key))) };
    })
  };
}

function normalizeCategoryMap(source = {}) {
  return Object.entries(source || {}).map(([name, value]) => ({ name, cover: value?.cover || '', summary: value?.summary || '', icon: value?.icon || '', color: value?.color || '', order: value?.order ?? '' }));
}

function categoriesToMap(categories = []) {
  const result = {};
  for (const category of categories) {
    const name = String(category.name || '').trim();
    if (!name) continue;
    const value = { cover: String(category.cover || '').trim(), summary: String(category.summary || '').trim(), icon: String(category.icon || '').trim(), color: String(category.color || '').trim() };
    const orderText = String(category.order ?? '').trim();
    if (orderText) {
      const number = Number(orderText);
      value.order = Number.isNaN(number) ? orderText : number;
    }
    result[name] = value;
  }
  return result;
}

function loadAll(root) {
  assertBlogRoot(root);
  const diary = parseFrontMatter(filePath(root, 'diary')).data;
  const rawBooks = loadYamlFile(filePath(root, 'books'), []);
  const books = attachBookNotes(root, Array.isArray(rawBooks) ? rawBooks : []);
  const movies = loadYamlFile(filePath(root, 'movies'), []);
  const posts = readPosts(root);
  const gallery = readGallery(root);
  const categories = normalizeCategoryMap(loadYamlFile(filePath(root, 'categories'), {}));
  return {
    root,
    counts: { diaries: Array.isArray(diary.diaries) ? diary.diaries.length : 0, books: books.length, movies: Array.isArray(movies) ? movies.length : 0, posts: posts.length, albums: gallery.albums.length, categories: categories.length },
    diary: { title: diary.title || '日记', date: diary.date || '', layout: diary.layout || 'diary', subtitles: Array.isArray(diary.subtitles) ? diary.subtitles : [], diaries: Array.isArray(diary.diaries) ? diary.diaries : [] },
    books,
    movies: Array.isArray(movies) ? movies : [],
    posts,
    gallery,
    categories
  };
}

function savePosts(root, posts) {
  const postsDir = filePath(root, 'posts');
  fs.mkdirSync(postsDir, { recursive: true });
  const seen = new Set();
  for (const rawPost of posts) {
    const post = normalizePost(rawPost);
    let filename = `${post.filename}.md`;
    let nextFile = ensureInside(root, path.join(postsDir, filename));
    let suffix = 2;
    while (seen.has(filename.toLowerCase())) {
      filename = `${post.filename}-${suffix}.md`;
      nextFile = ensureInside(root, path.join(postsDir, filename));
      suffix += 1;
    }
    seen.add(filename.toLowerCase());
    const oldFile = rawPost.id && rawPost.id.toLowerCase().endsWith('.md') ? ensureInside(root, path.join(postsDir, rawPost.id)) : '';
    writeAtomic(nextFile, `---\n${dumpYaml(post.data)}---\n\n${post.content.trimEnd()}\n`);
    if (oldFile && path.resolve(oldFile) !== path.resolve(nextFile)) removeFileWithBackup(oldFile);
  }
  for (const name of fs.readdirSync(postsDir).filter(name => name.toLowerCase().endsWith('.md'))) {
    if (!seen.has(name.toLowerCase())) removeFileWithBackup(ensureInside(root, path.join(postsDir, name)));
  }
}

function saveGallery(root, gallery) {
  const existing = parseFrontMatter(filePath(root, 'gallery')).data;
  const albums = Array.isArray(gallery.albums) ? gallery.albums.map(normalizeAlbum) : [];
  writeAtomic(filePath(root, 'gallery'), `---\n${dumpYaml({ ...existing, ...(gallery.extra || {}), title: gallery.title || existing.title || '画廊', window_title: gallery.window_title || existing.window_title || gallery.title || '画廊', layout: gallery.layout || existing.layout || 'gallery', comment: gallery.comment ?? existing.comment ?? false, albums })}---\n`);
  const galleryDir = path.join(root, 'source', 'gallery');
  const desired = new Set();
  for (const rawAlbum of gallery.albums || []) {
    const album = normalizeAlbum(rawAlbum);
    const slug = albumSlugFromPath(album.path, album.name);
    desired.add(slug.toLowerCase());
    const albumFile = ensureInside(root, path.join(galleryDir, slug, 'index.md'));
    const oldData = fs.existsSync(albumFile) ? parseFrontMatter(albumFile).data : { title: album.name, window_title: album.name, layout: 'album', photos: [] };
    writeAtomic(albumFile, `---\n${dumpYaml({ ...oldData, ...(rawAlbum.albumExtra || {}), title: rawAlbum.title || oldData.title || album.name, window_title: rawAlbum.window_title || oldData.window_title || rawAlbum.title || album.name, layout: rawAlbum.layout || oldData.layout || 'album', photos: Array.isArray(rawAlbum.photos) ? rawAlbum.photos.map(normalizePhoto).filter(photo => photo.url) : [] })}---\n`);
  }
  for (const entry of fs.readdirSync(galleryDir, { withFileTypes: true })) {
    const albumFile = path.join(galleryDir, entry.name, 'index.md');
    if (entry.isDirectory() && fs.existsSync(albumFile) && !desired.has(entry.name.toLowerCase())) removeFileWithBackup(ensureInside(root, albumFile));
  }
}

function saveAll(root, payload) {
  assertBlogRoot(root);
  if (payload.diary) {
    const existing = parseFrontMatter(filePath(root, 'diary')).data;
    const next = { ...existing, title: payload.diary.title || existing.title || '日记', date: payload.diary.date || existing.date || '', layout: payload.diary.layout || existing.layout || 'diary', subtitles: Array.isArray(payload.diary.subtitles) ? payload.diary.subtitles : existing.subtitles || [], diaries: Array.isArray(payload.diary.diaries) ? payload.diary.diaries.map(normalizeDiary) : [] };
    writeAtomic(filePath(root, 'diary'), `---\n${dumpYaml(next)}---\n`);
  }
  if (Array.isArray(payload.books)) {
    const fields = ['title', 'author', 'cover', 'review', 'notes', 'stars', 'reading_time', 'category', 'publisher', 'translator', 'summary', 'download'];
    payload.books.forEach(book => saveBookNotes(root, book));
    writeAtomic(filePath(root, 'books'), `# 文学类作品\n${dumpYaml(payload.books.map(item => normalizeEntry(item, fields)))}`);
  }
  if (Array.isArray(payload.movies)) {
    const fields = ['title', 'poster', 'director', 'actors', 'year', 'duration', 'country', 'category', 'rating', 'summary', 'details', 'watching_time'];
    writeAtomic(filePath(root, 'movies'), dumpYaml(payload.movies.map(item => normalizeEntry(item, fields))));
  }
  if (Array.isArray(payload.posts)) savePosts(root, payload.posts);
  if (payload.gallery) saveGallery(root, payload.gallery);
  if (Array.isArray(payload.categories)) writeAtomic(filePath(root, 'categories'), `# 分类封面映射表\n${dumpYaml(categoriesToMap(payload.categories))}`);
}

function runHexo(root, steps, res) {
  assertBlogRoot(root);
  const localHexo = process.platform === 'win32' ? path.join(root, 'node_modules', '.bin', 'hexo.cmd') : path.join(root, 'node_modules', '.bin', 'hexo');
  const command = fs.existsSync(localHexo) ? localHexo : (process.platform === 'win32' ? 'npx.cmd' : 'npx');
  let output = '';
  let index = 0;
  const runNext = () => {
    if (index >= steps.length) return send(res, 200, { code: 0, output });
    const step = steps[index++];
    const args = fs.existsSync(localHexo) ? [step] : ['hexo', step];
    output += `\n> hexo ${step}\n`;
    const child = spawn(command, args, { cwd: root, shell: process.platform === 'win32', env: { ...process.env, FORCE_COLOR: '0' } });
    child.stdout.on('data', chunk => { output += chunk.toString(); });
    child.stderr.on('data', chunk => { output += chunk.toString(); });
    child.on('error', error => send(res, 500, { code: -1, output: `${output}\n${error.message}` }));
    child.on('close', code => (code === 0 ? runNext() : send(res, 500, { code, output })));
  };
  runNext();
}

function mediaFile(req, res, requestUrl) {
  const root = rootFromQuery(requestUrl);
  assertBlogRoot(root);
  const raw = requestUrl.searchParams.get('path') || '';
  if (!raw || /^(https?:)?\/\//i.test(raw) || /^data:/i.test(raw)) return bad(res, 400, '不是本地图片路径');

  let target;
  const decoded = decodeURIComponent(raw.split('#')[0].split('?')[0]);
  if (/^[A-Za-z]:[\\/]/.test(decoded)) {
    target = ensureInside(root, decoded);
  } else {
    const clean = decoded.replace(/^\/+/, '');
    const candidates = [
      path.join(root, clean),
      path.join(root, 'source', clean),
      path.join(root, 'source', 'images', clean),
      path.join(root, 'source', decoded)
    ];
    target = candidates.map(file => {
      try { return ensureInside(root, file); } catch { return ''; }
    }).find(file => file && fs.existsSync(file));
  }

  if (!target || !fs.existsSync(target) || fs.statSync(target).isDirectory()) return bad(res, 404, '图片不存在');
  const ext = path.extname(target).toLowerCase();
  const types = { '.jpg': 'image/jpeg', '.jpeg': 'image/jpeg', '.png': 'image/png', '.gif': 'image/gif', '.webp': 'image/webp', '.svg': 'image/svg+xml', '.avif': 'image/avif', '.bmp': 'image/bmp' };
  send(res, 200, fs.readFileSync(target), types[ext] || 'application/octet-stream');
}

function staticFile(req, res, pathname) {
  if (pathname.startsWith('/vendor/mathjax/')) {
    const relative = pathname.replace('/vendor/mathjax/', '').replace(/\\/g, '/');
    const target = path.resolve(rootFromRequest(req), 'node_modules', 'mathjax', 'es5', relative);
    const mathjaxRoot = path.resolve(rootFromRequest(req), 'node_modules', 'mathjax', 'es5');
    if (target !== mathjaxRoot && !target.startsWith(`${mathjaxRoot}${path.sep}`)) return bad(res, 403, '拒绝访问');
    if (!fs.existsSync(target)) return bad(res, 404, '没有找到本地 MathJax');
    const types = { '.js': 'application/javascript', '.css': 'text/css', '.woff': 'font/woff', '.woff2': 'font/woff2', '.otf': 'font/otf', '.svg': 'image/svg+xml' };
    return send(res, 200, fs.readFileSync(target), types[path.extname(target).toLowerCase()] || 'application/octet-stream');
  }
  const safePath = pathname === '/' ? '/index.html' : pathname;
  const target = path.resolve(publicDir, `.${safePath}`);
  if (!target.startsWith(publicDir)) return bad(res, 403, '拒绝访问');
  if (!fs.existsSync(target) || fs.statSync(target).isDirectory()) return bad(res, 404, '文件不存在');
  const types = { '.html': 'text/html', '.css': 'text/css', '.js': 'application/javascript', '.svg': 'image/svg+xml' };
  send(res, 200, fs.readFileSync(target), types[path.extname(target).toLowerCase()] || 'text/plain');
}

async function route(req, res) {
  const url = new URL(req.url, `http://${req.headers.host}`);
  try {
    if (url.pathname === '/api/content' && req.method === 'GET') return send(res, 200, loadAll(rootFromQuery(url)));
    if (url.pathname === '/api/content' && req.method === 'PUT') {
      const body = await readBody(req);
      const root = path.resolve(body.root || DEFAULT_ROOT);
      saveAll(root, body);
      return send(res, 200, loadAll(root));
    }
    if (url.pathname === '/api/hexo' && req.method === 'POST') {
      const body = await readBody(req);
      const actions = { clean: ['clean'], generate: ['generate'], deploy: ['deploy'], publish: ['clean', 'generate', 'deploy'], server: ['server'] };
      if (!actions[body.action]) return bad(res, 400, '未知 Hexo 操作');
      return runHexo(path.resolve(body.root || DEFAULT_ROOT), actions[body.action], res);
    }
    if (url.pathname === '/api/report' && req.method === 'POST') {
      const body = await readBody(req);
      return send(res, 200, generateReport(path.resolve(body.root || DEFAULT_ROOT), body.period));
    }
    if (url.pathname === '/api/media' && req.method === 'GET') return mediaFile(req, res, url);
    return staticFile(req, res, url.pathname);
  } catch (error) {
    return bad(res, 500, error.message);
  }
}

http.createServer(route).listen(PORT, () => {
  console.log(`博客可视化管理端已启动：http://localhost:${PORT}`);
  console.log(`默认博客根目录：${DEFAULT_ROOT}`);
});
