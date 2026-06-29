// themes/next/scripts/helpers.js
hexo.extend.helper.register('getWeatherType', function(weather) {
  const weatherMap = {
    '晴朗': 'sunny',
    '晴天': 'sunny',
    '晴': 'sunny',
    '多云': 'cloudy',
    '阴天': 'cloudy',
    '阴': 'cloudy',
    '小雨': 'rainy',
    '中雨': 'rainy',
    '大雨': 'rainy',
    '暴雨': 'rainy',
    '雨': 'rainy',
    '小雪': 'snowy',
    '中雪': 'snowy',
    '大雪': 'snowy',
    '雪': 'snowy',
    '大风': 'windy',
    '台风': 'windy',
    '雷阵雨': 'stormy',
    '雷雨': 'stormy',
    '雾': 'foggy',
    '雾霾': 'foggy'
  };
  return weatherMap[weather] || 'sunny';
});

hexo.extend.helper.register('getWeatherEmoji', function(weather) {
  const emojiMap = {
    '晴朗': '☀️',
    '晴天': '☀️',
    '晴': '☀️',
    '多云': '⛅️',
    '阴天': '☁️',
    '阴': '☁️',
    '小雨': '🌧️',
    '中雨': '🌧️',
    '大雨': '🌧️',
    '暴雨': '🌧️',
    '雨': '🌧️',
    '小雪': '❄️',
    '中雪': '❄️',
    '大雪': '❄️',
    '雪': '❄️',
    '大风': '💨',
    '台风': '💨',
    '雷阵雨': '⛈️',
    '雷雨': '⛈️',
    '雾': '🌫️',
    '雾霾': '🌫️'
  };
  return emojiMap[weather] || '☀️';
});

hexo.extend.helper.register('post_cover', function(post) {
  const fallback = '/images/apple-touch-icon-next.png';
  if (!post) return this.url_for(fallback);
  const directCover = post.thumbnail || post.cover || post.banner || post.image;
  if (directCover) return this.url_for(directCover);
  if (post.photos && post.photos.length) return this.url_for(post.photos[0]);
  const content = post.raw || post.content || post.excerpt || '';
  const markdownImage = content.match(/!\[[^\]]*\]\(([^)\s]+)(?:\s+["'][^"']*["'])?\)/);
  if (markdownImage && markdownImage[1]) return this.url_for(markdownImage[1]);
  const htmlImage = content.match(/<img[^>]+src=["']([^"']+)["']/i);
  if (htmlImage && htmlImage[1]) return this.url_for(htmlImage[1]);
  return this.url_for(fallback);
});

hexo.extend.helper.register('post_plain_excerpt', function(post, length) {
  const limit = Number(length) || 120;
  if (!post) return '';
  let text = post.description || post.excerpt || post.content || post.raw || '';
  text = String(text)
    .replace(/<script[\s\S]*?<\/script>/gi, '')
    .replace(/<style[\s\S]*?<\/style>/gi, '')
    .replace(/!\[[^\]]*\]\([^)]+\)/g, '')
    .replace(/<[^>]+>/g, '')
    .replace(/[#>*_`~\-\[\]\(\)]/g, '')
    .replace(/\s+/g, ' ')
    .trim();
  if (text.length <= limit) return text;
  return text.slice(0, limit).trim() + '...';
});
