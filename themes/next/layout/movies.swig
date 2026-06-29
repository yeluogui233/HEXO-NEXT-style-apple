{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}
  {{ page.title }} | {{ config.title }}
{% endblock %}

{% block content %}
<style>
/* === 新增的响应式样式 === */
/* === 改进后的响应式样式（手机端三列优化） === */
/* ====== 强力修复：手机端严格三列（替换原有移动端 media 查询） ====== */
@media (max-width: 767px) {
  .movies-grid {
    display: grid !important;
    grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
    gap: 12px 8px !important;
    align-items: start;
    justify-items: stretch;
    width: 100%;
  }

  .movies-wrapper,
  .movies-grid,
  .movie-card,
  .movie-poster,
  .movie-poster img {
    box-sizing: border-box;
    -webkit-box-sizing: border-box;
  }

  /* 每个卡片强制占满一列宽度，去掉左右 margin */
  .movie-card {
    width: 100% !important;
    max-width: 100% !important;
    margin: 0 !important;
    padding: 0 !important;
    border-radius: 10px;
    overflow: hidden;
    display: flex;
    flex-direction: column;
    align-items: stretch;
    min-width: 0; /* 防止内部 flex/item 撑开 */
  }

  /* 使用 padding-bottom 保持 2:3 比例 */
  .movie-poster {
    width: 100%;
    height: 0;
    padding-bottom: calc(100% * 3 / 2); /* 2:3 -> padding-bottom = 150% */
    position: relative;
    border-radius: 10px 10px 0 0;
    overflow: hidden;
  }
  .movie-poster img {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
    transform: none !important;
  }

  /* 片名遮罩适配多行 */
  .movie-title-overlay {
    position: absolute;
    bottom: 0;
    left: 0;
    right: 0;
    padding: 6px 8px;
    white-space: normal;
    text-overflow: unset;
    overflow: hidden;
    font-size: 0.75rem;
    line-height: 1.1;
  }

  /* 评分小一号，位置微调 */
  .movie-rating {
    top: 6px;
    right: 6px;
    padding: 3px 5px;
    border-radius: 8px;
    box-shadow: none;
  }
  .star { font-size: 0.62rem; }
  .watching-indicator { font-size: 0.62rem; }

  /* 按钮组在卡片底部横向排列并居中 */
  .movie-buttons {
    display: flex;
    gap: 6px;
    justify-content: center;
    padding: 8px 6px 12px;
    width: 100%;
    box-sizing: border-box;
  }
  .btn {
    width: 44px !important;
    height: 22px !important;
    font-size: 0.62rem !important;
    padding: 2px 6px !important;
    border-radius: 8px !important;
    box-shadow: none !important;
  }

  .movies-wrapper {
    padding: 14px 12px;
    margin-bottom: 20px;
    box-shadow: none;
  }
  .page-header h1.page-title { font-size: 1.4rem; margin-bottom: 6px; }
  .page-subtitle { font-size: 0.9rem; }

  .lightbox-content { width: 94%; max-width: 640px; padding: 16px; margin: 8% auto; }
  .lightbox-content {
    max-height: 70vh;
    overflow-y: auto;
    -webkit-overflow-scrolling: touch; 
  }

  .movie-info-container { flex-direction: column; align-items: center; gap: 10px; }
  .movie-poster-large { width: 96px; }
  .movie-meta { text-align: center; font-size: 0.88rem; }

  /* 移动端兔子按钮调整 */
  .rabbit-toggle {
    position: relative !important;
    right: auto !important;
    top: auto !important;
    transform: none !important;
    margin: 10px auto !important;
    display: block !important;
  }

  /* 移动端分类选择器调整 */
  .category-selector {
    position: relative !important;
    left: auto !important;
    top: auto !important;
    transform: none !important;
    margin: 10px auto !important;
    display: block !important;
  }
}

/* 超小屏幕再减小一些间距（<=480px） */
@media (max-width: 480px) {
  .movies-grid { gap: 8px 6px; }
  .btn { width: 40px !important; height: 20px !important; font-size: 0.58rem !important; }
  .movie-title-overlay { font-size: 0.68rem; padding: 5px 6px; }
}

/* 影视分类标签样式 - 专业配色方案 */
.movie-category-tag {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  margin: 2px;
  color: #fff;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

/* 主要类别配色 */
.category-电影 { 
  background: linear-gradient(135deg, #E50914, #B81D24);
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}
.category-电视剧 { 
  background: linear-gradient(135deg, #1E40AF, #3B82F6);
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}
.category-动画 { 
  background: linear-gradient(135deg, #10B981, #34D399);
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}
.category-动漫 { 
  background: linear-gradient(135deg, #8B5CF6, #A78BFA);
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}
.category-纪录片 { 
  background: linear-gradient(135deg, #F59E0B, #FBBF24);
  text-shadow: 0 1px 2px rgba(0,0,0,0.3);
}

/* 类型分类配色 */
.category-剧情 { background-color: #4F46E5; }
.category-喜剧 { background-color: #F59E0B; color: #333; }
.category-爱情 { background-color: #EC4899; }
.category-动作 { background-color: #EF4444; }
.category-科幻 { background-color: #06B6D4; }
.category-悬疑 { background-color: #8B5CF6; }
.category-推理 { background-color: #7C3AED; }
.category-恐怖 { background-color: #7C3AED; }
.category-惊悚 { background-color: #DC2626; }
.category-犯罪 { background-color: #111827; }
.category-奇幻 { background-color: #D946EF; }
.category-冒险 { background-color: #059669; }
.category-战争 { background-color: #D97706; }
.category-历史 { background-color: #92400E; }
.category-传记 { background-color: #0891B2; }
.category-歌舞 { background-color: #DB2777; }
.category-家庭 { background-color: #7C3AED; }
.category-儿童 { background-color: #F0ABFC; color: #333; }
.category-动画电影 { background-color: #10B981; }
.category-短剧 { background-color: #6366F1; }
.category-体育 { background-color: #EA580C; }
.category-音乐 { background-color: #A855F7; }

/* 国籍/地区分类配色 */
.category-中国大陆 { background-color: #E11D48; }
.category-中国香港 { background-color: #F43F5E; }
.category-中国台湾 { background-color: #FB7185; }
.category-日本 { background-color: #0D9488; }
.category-韩国 { background-color: #2563EB; }
.category-美国 { background-color: #4338CA; }
.category-英国 { background-color: #7C2D12; }
.category-法国 { background-color: #1D4ED8; }
.category-德国 { background-color: #1F2937; }
.category-意大利 { background-color: #059669; }
.category-西班牙 { background-color: #A855F7; }
.category-印度 { background-color: #F59E0B; color: #333; }
.category-泰国 { background-color: #4F46E5; }
.category-俄罗斯 { background-color: #BE123C; }
.category-加拿大 { background-color: #DC2626; }
.category-澳大利亚 { background-color: #0284C7; }
.category-墨西哥 { background-color: #7C3AED; }
.category-巴西 { background-color: #16A34A; }
.category-瑞典 { background-color: #0891B2; }
.category-挪威 { background-color: #0D9488; }
.category-丹麦 { background-color: #92400E; }

/* 题材/风格分类 */
.category-都市 { background-color: #6B7280; }
.category-校园 { background-color: #F472B6; }
.category-职场 { background-color: #4B5563; }
.category-古装 { background-color: #92400E; }
.category-武侠 { background-color: #78350F; }
.category-仙侠 { background-color: #86198F; }
.category-玄幻 { background-color: #7C3AED; }
.category-谍战 { background-color: #111827; }
.category-警匪 { background-color: #1E40AF; }
.category-医疗 { background-color: #0F766E; }
.category-律政 { background-color: #1D4ED8; }
.category-美食 { background-color: #F97316; }
.category-旅行 { background-color: #059669; }
.category-电竞 { background-color: #3B82F6; }

/* 特殊分类 */
.category-站长推荐 {
  background: linear-gradient(135deg, #000000, #2a2a2a, #000000);
  color: #FFD700 !important;
  font-weight: 700;
  box-shadow: 0 0 15px rgba(255, 215, 0, 0.4);
  position: relative;
  border: none;
  padding: 4px 10px;
  font-size: 0.75rem;
}

.category-站长推荐::before {
  content: "🎬 ";
  font-size: 0.8em;
  margin-right: 3px;
}

/* 导演/演员特别分类 */
.category-导演作品 {
  background: linear-gradient(135deg, #9333EA, #C084FC);
  color: white;
}
.category-明星主演 {
  background: linear-gradient(135deg, #F59E0B, #FBBF24);
  color: #333;
}

/* 兔子按钮样式 */
.rabbit-toggle {
  position: absolute;
  right: 30px;
  top: 50%;
  transform: translateY(-50%);
  background: var(--primary-color);
  border: none;
  border-radius: 50px;
  padding: 8px 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  color: #333;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  transition: all 0.3s ease;
  z-index: 10;
}

.rabbit-toggle:hover {
  transform: translateY(-50%) scale(1.05);
  box-shadow: 0 6px 20px rgba(0,0,0,0.2);
}

.rabbit-icon {
  font-size: 1.2rem;
  transition: transform 0.3s ease;
}

.running .rabbit-icon {
  animation: rabbitRun 0.6s ease-in-out infinite;
}

@keyframes rabbitRun {
  0%, 100% { transform: translateY(0) rotate(0deg); }
  25% { transform: translateY(-2px) rotate(-5deg); }
  75% { transform: translateY(2px) rotate(5deg); }
}

/* 分类选择器样式 */
.category-selector {
  position: absolute;
  left: 30px;
  top: 50%;
  transform: translateY(-50%);
  background: var(--primary-color);
  border: none;
  border-radius: 50px;
  padding: 8px 16px;
  cursor: pointer;
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  font-weight: 600;
  color: #333;
  box-shadow: 0 4px 12px rgba(0,0,0,0.15);
  transition: all 0.3s ease;
  z-index: 10;
}

.category-selector:hover {
  transform: translateY(-50%) scale(1.05);
  box-shadow: 0 6px 20px rgba(0,0,0,0.2);
}

.category-icon {
  font-size: 1.2rem;
  transition: transform 0.3s ease;
}

.category-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  background: var(--content-bg-color, #fff);
  border-radius: 12px;
  padding: 8px 0;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
  min-width: 160px;
  max-height: 300px;
  overflow-y: auto;
  z-index: 20;
  display: none;
  margin-top: 8px;
}

.category-dropdown.show {
  display: block;
  animation: dropdownFadeIn 0.2s ease;
}

@keyframes dropdownFadeIn {
  from {
    opacity: 0;
    transform: translateY(-10px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.category-option {
  padding: 10px 16px;
  cursor: pointer;
  transition: background-color 0.2s ease;
  font-size: 0.9rem;
  color: var(--text-color);
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  white-space: nowrap;
}

.category-option:hover {
  background-color: rgba(0,0,0,0.05);
}

.category-option.active {
  background-color: var(--primary-color);
  color: #333;
  font-weight: 600;
}

/* 画布翻转动画 */
.movies-container {
  position: relative;
  width: 100%;
}

.movies-wrapper {
  background: var(--content-bg-color, #fff);
  border-radius: 14px;
  padding: 30px 24px;
  box-shadow: 0 6px 20px rgba(0,0,0,0.05);
  margin-bottom: 40px;
  max-width: 1140px;
  width: 100%;
  margin-left: auto;
  margin-right: auto;
  
  /* 翻转动画 */
  transition: transform 0.6s ease;
  transform-style: preserve-3d;
  position: relative;
}

.movies-wrapper.flipped {
  transform: rotateY(180deg);
}

.movies-front, .movies-friends {
  backface-visibility: hidden;
  width: 100%;
  height: auto;
}

.movies-front {
  transform: rotateY(0deg);
}

.movies-friends {
  position: absolute;
  top: 0;
  left: 0;
  transform: rotateY(180deg);
  display: none;
}

.movies-wrapper.flipped .movies-front {
  display: none;
}

.movies-wrapper.flipped .movies-friends {
  display: block;
  position: relative;
}

/* 页面标题区域定位 */
.page-header {
  position: relative;
  text-align: center;
  margin-bottom: 30px;
  padding: 0 80px; /* 为按钮留出空间 */
}
</style>

<div class="movies-container">
  <div class="movies-wrapper" id="moviesWrapper">
    <!-- 我的影视 -->
    <div class="movies-front">
      <header class="page-header">
        <!-- 分类选择器 -->
        <div class="category-selector" id="categorySelector">
          <span class="category-icon">🎬</span>
          <span id="currentCategory">全部影视</span>
          <div class="category-dropdown" id="categoryDropdown">
            <button class="category-option active" data-category="all">全部影视</button>
            <!-- 动态分类选项将通过JavaScript生成 -->
          </div>
        </div>

        <h1 class="page-title">{{ page.title }}</h1>
        {% if page.subtitle %}
          <p class="page-subtitle" style="color:var(--text-color-secondary); margin-top:6px;">
            {{ page.subtitle }}
          </p>
        {% endif %}
        <button class="rabbit-toggle" id="rabbitToggle">
          <span class="rabbit-icon">🐇</span>
          <span>看看朋友的</span>
        </button>
      </header>

      <div class="movies-grid" id="myMoviesGrid">
        {% for movie in site.data.movies %}
          {% if not movie.referee or movie.referee == '' %}
          <div class="movie-card card" data-movie-index="{{ loop.index0 }}" 
               data-category="{{ movie.category | default('未分类') }}">
            <!-- 评分 -->
            {% if movie.rating %}
            <div class="movie-rating">
              {% if movie.rating == 'watching' %}
                <!-- 正在看标志 -->
                <div class="watching-indicator" title="正在观看">
                  📺
                </div>
              {% else %}
                <div class="stars">
                  {% for i in range(1, 5) %}
                    {% set fullStars = movie.rating | round(0, 'floor') %}
                    {% set hasHalfStar = movie.rating % 1 >= 0.5 %}
                    
                    {% if i <= fullStars %}
                      <!-- 完整星 -->
                      <span class="star full">★</span>
                    {% elseif i == fullStars + 1 and hasHalfStar %}
                      <!-- 半星 -->
                      <span class="star half">★</span>
                    {% else %}
                      <!-- 空星 -->
                      <span class="star empty">☆</span>
                    {% endif %}
                  {% endfor %}
                  <span class="rating-number">{% if movie.rating % 1 == 0 %}{{ movie.rating | int }}{% else %}{{ movie.rating }}{% endif %}</span>
                </div>
              {% endif %}
            </div>
            {% endif %}
            
            <div class="movie-poster">
              <img src="{{ movie.poster }}" alt="{{ movie.title }}" loading="lazy" class="movie-poster-img">
              <div class="movie-title-overlay">
                <h3>{{ movie.title }}</h3>
                {% if movie.year %}
                <small>{{ movie.year }}</small>
                {% endif %}
              </div>
            </div>
            {% if movie.review or movie.details %}
            <div class="movie-buttons">
              {% if movie.review %}
                <a href="{{ movie.review }}" class="btn" target="_blank" rel="noopener">影评</a>
              {% endif %}
              {% if movie.details %}
                <a href="{{ movie.details }}" class="btn" target="_blank" rel="noopener">详情</a>
              {% endif %}
            </div>
            {% endif %}
          </div>
          {% endif %}
        {% endfor %}
      </div>
    </div>

    <!-- 朋友推荐影视 -->
    <div class="movies-friends">
      <header class="page-header">
        <!-- 朋友影视的分类选择器 -->
        <div class="category-selector" id="categorySelectorFriends">
          <span class="category-icon">🎬</span>
          <span id="currentCategoryFriends">全部影视</span>
          <div class="category-dropdown" id="categoryDropdownFriends">
            <button class="category-option active" data-category="all">全部影视</button>
            <!-- 动态分类选项将通过JavaScript生成 -->
          </div>
        </div>

        <h1 class="page-title">友邻推荐</h1>
        <p class="page-subtitle" style="color:var(--text-color-secondary); margin-top:6px;">
          "一起分享光影世界"
        </p>
        <button class="rabbit-toggle" id="rabbitToggleBack">
          <span class="rabbit-icon">🐇</span>
          <span>回到我的</span>
        </button>
      </header>

      <div class="movies-grid" id="friendsMoviesGrid">
        {% for movie in site.data.movies %}
          {% if movie.referee and movie.referee != '' %}
          <div class="movie-card card" data-movie-index="{{ loop.index0 }}" 
               data-category="{{ movie.category | default('未分类') }}">
            <!-- 评分 -->
            {% if movie.rating %}
            <div class="movie-rating">
              {% if movie.rating == 'watching' %}
                <!-- 正在看标志 -->
                <div class="watching-indicator" title="正在观看">
                  📺
                </div>
              {% else %}
                <div class="stars">
                  {% for i in range(1, 5) %}
                    {% set fullStars = movie.rating | round(0, 'floor') %}
                    {% set hasHalfStar = movie.rating % 1 >= 0.5 %}
                    
                    {% if i <= fullStars %}
                      <!-- 完整星 -->
                      <span class="star full">★</span>
                    {% elseif i == fullStars + 1 and hasHalfStar %}
                      <!-- 半星 -->
                      <span class="star half">★</span>
                    {% else %}
                      <!-- 空星 -->
                      <span class="star empty">☆</span>
                    {% endif %}
                  {% endfor %}
                  <span class="rating-number">{% if movie.rating % 1 == 0 %}{{ movie.rating | int }}{% else %}{{ movie.rating }}{% endif %}</span>
                </div>
              {% endif %}
            </div>
            {% endif %}
            
            <div class="movie-poster">
              <img src="{{ movie.poster }}" alt="{{ movie.title }}" loading="lazy" class="movie-poster-img">
              <div class="movie-title-overlay">
                <h3>{{ movie.title }}</h3>
                {% if movie.year %}
                <small>{{ movie.year }}</small>
                {% endif %}
              </div>
            </div>
            {% if movie.review or movie.details %}
            <div class="movie-buttons">
              {% if movie.review %}
                <a href="{{ movie.review }}" class="btn" target="_blank" rel="noopener">影评</a>
              {% endif %}
              {% if movie.details %}
                <a href="{{ movie.details }}" class="btn" target="_blank" rel="noopener">详情</a>
              {% endif %}
            </div>
            {% endif %}
          </div>
          {% endif %}
        {% endfor %}
      </div>
    </div>
  </div>
</div>

<!-- 灯箱弹窗 -->
<div id="movieLightbox" class="lightbox">
  <div class="lightbox-overlay"></div>
  <div class="lightbox-content">
    <button class="lightbox-close">&times;</button>
    <div class="movie-detail">
      <div class="movie-detail-header">
        <h2 id="lightbox-title"></h2>
        <div class="movie-info-container">
          <div class="movie-poster-large">
            <img id="lightbox-poster" src="" alt="">
          </div>
          <div class="movie-meta" id="lightbox-meta"></div>
        </div>
      </div>
      <div class="movie-summary" id="lightbox-summary"></div>
      <div class="movie-detail-footer">
        <a href="#" class="download-btn" id="lightbox-details" target="_blank">详情链接</a>
      </div>
    </div>
  </div>
</div>

<style>
/* ================ 优化后的灯箱样式 ================ */
/* 灯箱样式 */
.lightbox {
  display: none;
  position: fixed;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  z-index: 1000;
}

.lightbox-overlay {
  position: absolute;
  top: 0;
  left: 0;
  width: 100%;
  height: 100%;
  background: rgba(0, 0, 0, 0.85);
  backdrop-filter: blur(12px);
}

.lightbox-content {
  position: relative;
  background: var(--content-bg-color, #fff);
  border-radius: 20px;
  padding: 35px;
  max-width: 750px;
  width: 85%;
  margin: 4% auto;
  box-shadow: 0 30px 80px rgba(0, 0, 0, 0.5);
  animation: lightboxFadeIn 0.3s ease;
  max-height: 85vh;
  overflow-y: auto;
}

@keyframes lightboxFadeIn {
  from {
    opacity: 0;
    transform: scale(0.95) translateY(-15px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

.lightbox-close {
  position: absolute;
  top: 20px;
  right: 25px;
  background: rgba(0,0,0,0.08);
  border: none;
  font-size: 2rem;
  color: var(--text-color);
  cursor: pointer;
  width: 48px;
  height: 48px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.25s ease;
  z-index: 1;
}

.lightbox-close:hover {
  background: rgba(0, 0, 0, 0.15);
  transform: rotate(90deg) scale(1.1);
}

/* 影片详情样式 - 增大字体，减小间距 */
.movie-detail-header h2 {
  margin: 0 0 25px 0;
  color: var(--text-color);
  font-size: 2.2rem;
  font-weight: 800;
  text-align: center;
  line-height: 1.2;
  padding-bottom: 15px;
  border-bottom: 2px solid var(--primary-color);
}

.movie-info-container {
  display: flex;
  gap: 35px;
  align-items: flex-start;
  margin-bottom: 35px;
}

.movie-poster-large {
  flex-shrink: 0;
  width: 200px;
}

.movie-poster-large img {
  width: 100%;
  height: auto;
  border-radius: 16px;
  box-shadow: 0 12px 35px rgba(0, 0, 0, 0.3);
}

.movie-meta {
  color: var(--text-color-secondary);
  font-size: 1.05rem;
  line-height: 1.6;
  flex: 1;
  text-align: left;
}

.movie-meta div {
  margin-bottom: 8px;
  padding: 3px 0;
}

.movie-meta strong {
  color: var(--text-color);
  margin-right: 12px;
  font-weight: 700;
  min-width: 100px;
  display: inline-block;
  font-size: 1.05rem;
}

/* 优化分类标签间距 */
.movie-category-tag {
  font-size: 0.85rem;
  padding: 5px 12px;
  margin: 3px;
}

/* 个人评分样式 - 优化配色，去掉分割线 */
.personal-rating {
  font-weight: 700;
  margin-top: 10px;
  margin-bottom: 4px;
  padding: 5px 0;
  border: none;
  font-size: 1.1rem;
}

.personal-rating strong {
  color: inherit !important;
}

/* 推荐人样式 - 优化配色，去掉分割线 */
.movie-referee {
  color: #7B1FA2; /* 深紫色 - 更柔和 */
  font-weight: 700;
  margin-top: 8px;
  margin-bottom: 4px;
  padding: 5px 0;
  border: none;
  font-size: 1.1rem;
}

.movie-referee strong {
  color: inherit !important;
}

/* 观看时间样式 - 优化配色，去掉分割线 */
.watching-time {
  color: #388E3C; /* 深绿色 - 更沉稳 */
  font-weight: 700;
  margin-top: 8px;
  margin-bottom: 4px;
  padding: 5px 0;
  border: none;
  font-size: 1.1rem;
}

.watching-time strong {
  color: inherit !important;
}

/* 简介样式 - 增大字体，减少间距 */
.movie-summary {
  color: var(--text-color);
  line-height: 1.7;
  margin-bottom: 35px;
  font-size: 1.1rem;
  text-indent: 2em;
  background: linear-gradient(135deg, rgba(229, 9, 20, 0.03), rgba(59, 130, 246, 0.03));
  padding: 25px 28px;
  border-radius: 18px;
  border-left: 6px solid var(--primary-color);
}

.movie-summary p {
  text-indent: 2em;
  margin-bottom: 0.8em; /* 减少段落间距 */
  font-size: 1.05rem;
  line-height: 1.7;
}

.movie-summary p:first-child {
  margin-top: 0;
}

.movie-detail-footer {
  text-align: center;
  padding-top: 25px;
  border-top: 2px solid rgba(0, 0, 0, 0.1);
}

.download-btn {
  display: inline-block;
  background: linear-gradient(135deg, #E50914, #B81D24);
  color: white;
  padding: 18px 45px;
  border-radius: 25px;
  text-decoration: none;
  font-weight: 700;
  font-size: 1.2rem;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 8px 25px rgba(229, 9, 20, 0.4);
  text-shadow: 0 1px 3px rgba(0,0,0,0.3);
  position: relative;
  overflow: hidden;
}

.download-btn:hover {
  background: linear-gradient(135deg, #B81D24, #E50914);
  transform: translateY(-4px) scale(1.05);
  box-shadow: 0 12px 30px rgba(229, 9, 20, 0.5);
}

.download-btn:active {
  transform: translateY(-1px) scale(1.02);
}

/* 六列网格布局 */
.movies-grid {
  display: grid;
  grid-template-columns: repeat(6, minmax(120px, 1fr));
  gap: 28px 20px;
  justify-content: center;
}

/* 影视卡片 */
.movie-card {
  background: var(--card-bg, #fff);
  border-radius: 14px;
  box-shadow: 0 6px 18px rgba(0,0,0,0.12);
  overflow: hidden;
  transition: transform 0.4s ease, box-shadow 0.4s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative;
  cursor: pointer;
  border: 1px solid rgba(0,0,0,0.08);
}

.movie-card:hover {
  transform: translateY(-10px) scale(1.03);
  box-shadow: 0 15px 35px rgba(0,0,0,0.2);
  border-color: rgba(0,0,0,0.15);
}

/* 评分样式 */
.movie-rating {
  position: absolute;
  top: 10px;
  right: 10px;
  background: rgba(0, 0, 0, 0.75);
  backdrop-filter: blur(12px);
  border-radius: 14px;
  padding: 6px 10px;
  z-index: 2;
  box-shadow: 0 3px 12px rgba(0,0,0,0.3);
  display: flex;
  align-items: center;
  gap: 5px;
}

.stars {
  display: flex;
  gap: 2px;
  align-items: center;
}

.star {
  font-size: 0.8rem;
  position: relative;
  display: inline-block;
}

.star.full {
  color: #FFD700; /* 金色 */
  text-shadow: 0 0 8px rgba(255, 215, 0, 0.5);
}

.star.empty {
  color: rgba(255, 255, 255, 0.3);
}

/* 半星样式 */
.star.half {
  background: linear-gradient(to right, #FFD700 50%, rgba(255, 255, 255, 0.3) 50%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

.rating-number {
  color: white;
  font-weight: 600;
  font-size: 0.85rem;
  margin-left: 3px;
  text-shadow: 0 1px 2px rgba(0,0,0,0.5);
}

/* 正在看标志 */
.watching-indicator {
  font-size: 0.8rem;
  color: #10B981;
  display: flex;
  align-items: center;
  justify-content: center;
  text-shadow: 0 1px 3px rgba(0,0,0,0.5);
}

/* 海报容器 */
.movie-poster {
  position: relative;
  width: 100%;
  aspect-ratio: 2 / 3; /* 保持2:3比例 */
  overflow: hidden;
  border-radius: 14px 14px 0 0;
}

.movie-poster img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.6s ease;
}

.movie-card:hover .movie-poster img {
  transform: scale(1.1);
}

/* 磨砂片名覆盖底部 */
.movie-title-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  padding: 10px 12px;
  background: linear-gradient(to top, rgba(0, 0, 0, 0.9), rgba(0, 0, 0, 0.6), transparent);
  backdrop-filter: blur(8px);
  color: white;
  font-weight: 700;
  font-size: 0.85rem;
  text-align: left;
  white-space: normal;
  overflow: hidden;
  box-sizing: border-box;
  text-shadow: 0 2px 4px rgba(0,0,0,0.5);
}

.movie-title-overlay h3 {
  margin: 0 0 3px 0;
  font-size: 0.9rem;
  line-height: 1.2;
}

.movie-title-overlay small {
  opacity: 0.8;
  font-size: 0.75rem;
  font-weight: normal;
}

/* 按钮组 */
.movie-buttons {
  margin: 10px 0;
  display: flex;
  gap: 10px;
  width: 100%;
  justify-content: center;
  padding: 0 12px;
  flex-wrap: wrap;
}

/* 按钮样式 */
.btn {
  display: inline-flex;
  align-items: center;
  justify-content: center;
  padding: 6px 0;
  font-size: 0.75rem;
  border-radius: 12px;
  font-weight: 600;
  text-decoration: none;
  user-select: none;
  transition: all 0.25s ease;
  box-shadow: 0 2px 6px rgba(0,0,0,0.15);
  width: 60px;
  height: 28px;
  box-sizing: border-box;
  background: linear-gradient(135deg, #3B82F6, #1D4ED8);
  color: white;
  border: none;
  text-shadow: 0 1px 2px rgba(0,0,0,0.2);
}

.btn:hover {
  background: linear-gradient(135deg, #1D4ED8, #3B82F6);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(59, 130, 246, 0.3);
  color: white !important;
}

.btn:nth-child(2) {
  background: linear-gradient(135deg, #10B981, #059669);
}

.btn:nth-child(2):hover {
  background: linear-gradient(135deg, #059669, #10B981);
  box-shadow: 0 4px 12px rgba(16, 185, 129, 0.3);
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const lightbox = document.getElementById('movieLightbox');
  const lightboxTitle = document.getElementById('lightbox-title');
  const lightboxPoster = document.getElementById('lightbox-poster');
  const lightboxMeta = document.getElementById('lightbox-meta');
  const lightboxSummary = document.getElementById('lightbox-summary');
  const lightboxDetails = document.getElementById('lightbox-details');
  const closeBtn = document.querySelector('.lightbox-close');
  const overlay = document.querySelector('.lightbox-overlay');
  
  // 兔子按钮和翻转功能
  const rabbitToggle = document.getElementById('rabbitToggle');
  const rabbitToggleBack = document.getElementById('rabbitToggleBack');
  const moviesWrapper = document.getElementById('moviesWrapper');

  // 分类选择器
  const categorySelector = document.getElementById('categorySelector');
  const categoryDropdown = document.getElementById('categoryDropdown');
  const currentCategory = document.getElementById('currentCategory');
  
  const categorySelectorFriends = document.getElementById('categorySelectorFriends');
  const categoryDropdownFriends = document.getElementById('categoryDropdownFriends');
  const currentCategoryFriends = document.getElementById('currentCategoryFriends');

  // 影视数据
  const movies = {{ site.data.movies | json }};

  // 获取评分颜色 - 优化后的配色方案
  function getRatingColor(rating) {
    if (rating >= 9) return '#FFB300'; // 亮金色
    if (rating >= 8) return '#FF7043'; // 温暖橙色
    if (rating >= 7) return '#26C6DA'; // 清新青色
    if (rating >= 6) return '#29B6F6'; // 明亮蓝色
    if (rating >= 5) return '#66BB6A'; // 柔和绿色
    return '#9E9E9E'; // 中灰色
  }

  // 提取所有分类（支持多分类）
  function extractCategories() {
    const categories = new Set(['all']);
    movies.forEach(movie => {
      if (movie.category && movie.category.trim() !== '') {
        // 分割分类字符串，支持空格分隔的多个分类
        const categoryList = movie.category.split(' ').filter(cat => cat.trim() !== '');
        categoryList.forEach(cat => {
          categories.add(cat);
        });
      }
    });
    return Array.from(categories).sort();
  }

  // 初始化分类下拉菜单
  function initCategoryDropdown(dropdownElement, currentCategoryElement, gridElement) {
    const categories = extractCategories();
    
    // 清空现有选项（除了"全部影视"）
    while (dropdownElement.children.length > 1) {
      dropdownElement.removeChild(dropdownElement.lastChild);
    }
    
    // 按类别分组
    const categoryGroups = {
      '主要类别': [],
      '类型': [],
      '国家/地区': [],
      '题材风格': [],
      '特别推荐': []
    };
    
    // 分类映射
    const mainCategories = ['电影', '电视剧', '动画', '动漫', '纪录片'];
    const typeCategories = ['剧情', '喜剧', '爱情', '动作', '科幻', '悬疑','推理', '恐怖', '惊悚', '犯罪', '奇幻', '冒险', '战争', '历史', '传记', '歌舞', '家庭', '儿童', '动画电影', '短剧', '体育', '音乐'];
    const countryCategories = ['中国大陆', '中国香港', '中国台湾', '日本', '韩国', '美国', '英国', '法国', '德国', '意大利', '西班牙', '印度', '泰国', '俄罗斯', '加拿大', '澳大利亚', '墨西哥', '巴西', '瑞典', '挪威', '丹麦'];
    const themeCategories = ['都市', '校园', '职场', '古装', '武侠', '仙侠', '玄幻', '谍战', '警匪', '医疗', '律政', '美食', '旅行', '电竞'];
    const specialCategories = ['站长推荐', '导演作品', '明星主演'];
    
    // 分组分类
    categories.forEach(category => {
      if (category !== 'all') {
        if (mainCategories.includes(category)) {
          categoryGroups['主要类别'].push(category);
        } else if (typeCategories.includes(category)) {
          categoryGroups['类型'].push(category);
        } else if (countryCategories.includes(category)) {
          categoryGroups['国家/地区'].push(category);
        } else if (themeCategories.includes(category)) {
          categoryGroups['题材风格'].push(category);
        } else if (specialCategories.includes(category)) {
          categoryGroups['特别推荐'].push(category);
        } else {
          // 其他分类放到主要类别
          categoryGroups['主要类别'].push(category);
        }
      }
    });
    
    // 添加分组选项
    Object.keys(categoryGroups).forEach(groupName => {
      if (categoryGroups[groupName].length > 0) {
        // 添加分组标题
        const groupHeader = document.createElement('div');
        groupHeader.className = 'category-group-header';
        groupHeader.style.padding = '8px 16px 4px';
        groupHeader.style.fontSize = '0.8rem';
        groupHeader.style.color = 'var(--text-color-secondary)';
        groupHeader.style.fontWeight = '600';
        groupHeader.style.borderBottom = '1px solid rgba(0,0,0,0.1)';
        groupHeader.textContent = groupName;
        dropdownElement.appendChild(groupHeader);
        
        // 添加该组的分类选项
        categoryGroups[groupName].forEach(category => {
          const option = document.createElement('button');
          option.className = 'category-option';
          option.setAttribute('data-category', category);
          option.textContent = category;
          dropdownElement.appendChild(option);
        });
      }
    });
    
    // 添加分类选项点击事件
    dropdownElement.querySelectorAll('.category-option').forEach(option => {
      option.addEventListener('click', function() {
        const category = this.getAttribute('data-category');
        
        // 更新当前选中状态
        dropdownElement.querySelectorAll('.category-option').forEach(opt => {
          opt.classList.remove('active');
        });
        this.classList.add('active');
        
        // 更新显示文本
        currentCategoryElement.textContent = this.textContent;
        
        // 筛选影视
        filterMovies(category, gridElement);
        
        // 关闭下拉菜单
        dropdownElement.classList.remove('show');
      });
    });
  }

  // 筛选影视（支持多分类）
  function filterMovies(category, gridElement) {
    const movieCards = gridElement.querySelectorAll('.movie-card');
    
    movieCards.forEach(card => {
      if (category === 'all') {
        card.style.display = 'flex';
      } else {
        const movieCategories = card.getAttribute('data-category').split(' ');
        if (movieCategories.includes(category)) {
          card.style.display = 'flex';
        } else {
          card.style.display = 'none';
        }
      }
    });
  }

  // 初始化分类功能
  initCategoryDropdown(categoryDropdown, currentCategory, document.getElementById('myMoviesGrid'));
  initCategoryDropdown(categoryDropdownFriends, currentCategoryFriends, document.getElementById('friendsMoviesGrid'));

  // 分类选择器点击事件
  categorySelector.addEventListener('click', function(e) {
    e.stopPropagation();
    categoryDropdown.classList.toggle('show');
  });

  categorySelectorFriends.addEventListener('click', function(e) {
    e.stopPropagation();
    categoryDropdownFriends.classList.toggle('show');
  });

  // 点击页面其他地方关闭下拉菜单
  document.addEventListener('click', function() {
    categoryDropdown.classList.remove('show');
    categoryDropdownFriends.classList.remove('show');
  });

  // 阻止下拉菜单内部点击事件冒泡
  categoryDropdown.addEventListener('click', function(e) {
    e.stopPropagation();
  });

  categoryDropdownFriends.addEventListener('click', function(e) {
    e.stopPropagation();
  });

  // 兔子按钮点击事件
  rabbitToggle.addEventListener('click', function() {
    this.classList.add('running');
    moviesWrapper.classList.add('flipped');
    
    // 动画结束后移除running类
    setTimeout(() => {
      this.classList.remove('running');
    }, 600);
  });

  rabbitToggleBack.addEventListener('click', function() {
    this.classList.add('running');
    moviesWrapper.classList.remove('flipped');
    
    // 动画结束后移除running类
    setTimeout(() => {
      this.classList.remove('running');
    }, 600);
  });

  // 点击影视卡片打开灯箱
  document.querySelectorAll('.movie-card').forEach(card => {
    card.addEventListener('click', function(e) {
      // 防止点击按钮时触发
      if (e.target.closest('.btn') || e.target.closest('.movie-rating')) {
        return;
      }
      
      const movieIndex = this.getAttribute('data-movie-index');
      const movie = movies[movieIndex];
      
      if (movie) {
        lightboxTitle.textContent = movie.title;
        lightboxPoster.src = movie.poster;
        lightboxPoster.alt = movie.title;
        
        // 构建元数据 - 使用更紧凑的布局
        let metaHTML = '';
        
        if (movie.director) {
          metaHTML += `<div><strong>导演:</strong> ${movie.director}</div>`;
        }
        
        if (movie.actors && movie.actors.trim() !== '') {
          metaHTML += `<div><strong>主演:</strong> ${movie.actors}</div>`;
        }
        
        if (movie.year) {
          metaHTML += `<div><strong>年份:</strong> ${movie.year}</div>`;
        }
        
        if (movie.duration) {
          metaHTML += `<div><strong>片长:</strong> ${movie.duration}</div>`;
        }
        
        if (movie.country) {
          metaHTML += `<div><strong>国家/地区:</strong> ${movie.country}</div>`;
        }
        
        // 添加分类信息（如果有）- 与书单页面风格一致
        if (movie.category && movie.category.trim() !== '') {
          // 分割分类字符串并创建彩色标签
          const categories = movie.category.split(' ').filter(cat => cat.trim() !== '');
          const categoryTags = categories.map(cat => 
            `<span class="movie-category-tag category-${cat}">${cat}</span>`
          ).join('');
          
          metaHTML += `<div><strong>分类:</strong> ${categoryTags}</div>`;
        }
        
        // 添加推荐人信息（如果有）- 没有分割线
        if (movie.referee && movie.referee.trim() !== '') {
          metaHTML += `<div class="movie-referee">
            <strong>推荐人:</strong> ${movie.referee}
          </div>`;
        }
        
        // 添加个人评分（只有当rating存在且不是'watching'时显示）
        if (movie.rating && movie.rating !== 'watching') {
          const ratingColor = getRatingColor(movie.rating);
          metaHTML += `<div class="personal-rating" style="color: ${ratingColor}">
            <strong>个人评分:</strong> ${movie.rating}/5.0
          </div>`;
        }
        
        // 添加观看时间（如果有）- 没有分割线
        if (movie.watching_time && movie.watching_time.trim() !== '') {
          metaHTML += `<div class="watching-time">
            <strong>观看时间:</strong> ${movie.watching_time}
          </div>`;
        }
        
        lightboxMeta.innerHTML = metaHTML;
        
        // 简介 - 增大字体，减少间距
        if (movie.summary) {
          // 将文本按段落分割
          const paragraphs = movie.summary.split('\n');
          const formattedSummary = paragraphs.map(p => {
            if (p.trim()) {
              return `<p style="text-indent: 2em; margin-bottom: 0.8em; font-size: 1.05rem; line-height: 1.7;">${p}</p>`;
            }
            return '';
          }).join('');
          lightboxSummary.innerHTML = formattedSummary;
        } else {
          lightboxSummary.textContent = '暂无简介';
          lightboxSummary.style.fontSize = '1.1rem';
          lightboxSummary.style.color = 'var(--text-color-secondary)';
        }
        
        // 详情链接
        if (movie.details) {
          lightboxDetails.href = movie.details;
          lightboxDetails.style.display = 'inline-block';
        } else {
          lightboxDetails.style.display = 'none';
        }
        
        lightbox.style.display = 'block';
        document.body.style.overflow = 'hidden';
      }
    });
  });

  // 关闭灯箱
  function closeLightbox() {
    lightbox.style.display = 'none';
    document.body.style.overflow = 'auto';
  }

  closeBtn.addEventListener('click', closeLightbox);
  overlay.addEventListener('click', closeLightbox);

  // ESC键关闭
  document.addEventListener('keydown', function(e) {
    if (e.key === 'Escape') {
      closeLightbox();
    }
  });
});
</script>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}