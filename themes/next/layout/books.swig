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
  .books-grid {
    display: grid !important;
    grid-template-columns: repeat(3, minmax(0, 1fr)) !important;
    gap: 12px 8px !important;
    align-items: start;
    justify-items: stretch;
    width: 100%;
  }

  .books-wrapper,
  .books-grid,
  .book-card,
  .book-cover,
  .book-cover img {
    box-sizing: border-box;
    -webkit-box-sizing: border-box;
  }

  /* 每个卡片强制占满一列宽度，去掉左右 margin */
  .book-card {
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

  /* 使用 padding-bottom 保持 3:4 比例并避免 img 高度撑开布局 */
  .book-cover {
    width: 100%;
    height: 0;
    padding-bottom: calc(100% * 4 / 3); /* 3:4 -> padding-bottom = 133.33% */
    position: relative;
    border-radius: 10px 10px 0 0;
    overflow: hidden;
  }
  .book-cover img {
    position: absolute;
    inset: 0;
    width: 100%;
    height: 100%;
    object-fit: cover; /* 保证图片裁切而不拉伸 */
    display: block;
    transform: none !important;
  }

  /* 书名遮罩适配多行，避免换行裁剪 */
  .book-title-overlay {
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

  /* 星级和正在读标识小一号，位置微调 */
  .book-rating {
    top: 6px;
    right: 6px;
    padding: 3px 5px;
    border-radius: 8px;
    box-shadow: none;
  }
  .star { font-size: 0.62rem; }
  .reading-indicator { font-size: 0.62rem; }

  /* 按钮组在卡片底部横向排列并居中 */
  .book-buttons {
    display: grid;
    grid-auto-columns: 50px;
    grid-auto-flow: column;
    gap: 6px;
    justify-content: center;
    padding: 8px 6px 12px;
    width: 100%;
    box-sizing: border-box;
  }
      .book-buttons .btn {
    width: 50px !important;
    min-width: 50px !important;
    max-width: 50px !important;
    height: 22px !important;
    font-size: 0.62rem !important;
    padding: 0 !important;
    border-radius: 8px !important;
    box-shadow: none !important;
  }


  .books-wrapper {
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

/* 优化滚动条美观（可选） */
.lightbox-content::-webkit-scrollbar {
  width: 6px;
}
.lightbox-content::-webkit-scrollbar-thumb {
  background-color: rgba(0, 0, 0, 0.25);
  border-radius: 6px;
}
.lightbox-content::-webkit-scrollbar-thumb:hover {
  background-color: rgba(0, 0, 0, 0.4);
}
  .book-info-container { flex-direction: column; align-items: center; gap: 10px; }
  .book-cover-large { width: 96px; }
  .book-meta { text-align: center; font-size: 0.88rem; }

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
  .books-grid { gap: 8px 6px; }
  .book-buttons { grid-auto-columns: 46px !important; }
  .book-buttons .btn { width: 46px !important; min-width: 46px !important; max-width: 46px !important; height: 20px !important; font-size: 0.58rem !important; padding: 0 !important; }
  .book-title-overlay { font-size: 0.68rem; padding: 5px 6px; }
}
/* 分类标签样式 - 活力多巴胺配色 */
.book-category-tag {
  display: inline-block;
  padding: 4px 10px;
  border-radius: 12px;
  font-size: 0.75rem;
  font-weight: 600;
  margin: 2px;
  color: #333;
  box-shadow: 0 2px 4px rgba(0,0,0,0.1);
}

/* 活力多巴胺配色方案 */
.category-文学 { 
  background: linear-gradient(135deg, #FF6B9D, #FF8EAF) !important;
  color: #333; !important/* 改为深色文字 */
  text-shadow: 0 1px 3px rgba(0,0,0,0.3) !important;
  box-shadow: 0 2px 8px rgba(255,107,157,0.3) !important;
}
.category-奥地利文学 {
  background: linear-gradient(135deg, #B76E79, #E6B8B7); /* 玫瑰金渐变，灵感来自维也纳艺术史博物馆和经典建筑 */
  color: #2C2A2A; /* 深灰色文字，确保在浅色背景上可读 */
  text-shadow: 0 1px 2px rgba(255, 255, 255, 0.3); /* 柔和白色文字阴影 */
  box-shadow: 0 2px 8px rgba(183, 110, 121, 0.4); /* 与主色呼应的阴影 */
}
.category-存在主义 {
  background: linear-gradient(135deg, #34495e, #6b7b8d);
  color: #f5f5f5;
  font-weight: 500;
  border-left: 2px solid #f1c40f; /* 加缪的太阳 */
}
.category-纪实文学 {
  background: linear-gradient(135deg, #2C3E50, #3498DB) !important;
  color: white !important;
  text-shadow: 0 1px 2px rgba(0,0,0,0.2) !important;
  box-shadow: 0 2px 8px rgba(52,152,219,0.3) !important;
}
.category-小说 { background-color: #aeb9ff; } /* 宝蓝色 - 与德国文学区分 */
.category-科幻 { background-color: #2139d5; color: white;} /* 亮绿色 */
.category-历史 { background-color: #FFF67A; } /* 亮黄色 */
.category-哲学 { background-color: #C97AFF; } /* 亮紫色 */
.category-心理学 { background-color: #FFB47A; } /* 亮橙色 */
.category-传记 { background-color: #7AFFF0; } /* 亮青色 */
.category-科普 { background-color: #FF7A7A; } /* 亮红色 */
.category-艺术 { background-color: #D97AFF; } /* 亮淡紫 */
.category-经济 { background-color: #7AFFA3; } /* 亮薄荷绿 */
.category-政治 { background-color: #FFD47A; } /* 亮珊瑚色 */
.category-社会学 { background-color: #7AD4FF; } /* 亮天蓝色 */
.category-中国文学 { background-color: #ff9c9c; } /* 浅粉色 - 与文学区分 */
.category-中国古典文学 { background-color: #FFF9A3; } /* 亮米色 */
.category-乡土文学 { background-color: #D9B4FF; } /* 亮淡紫色 */
.category-红色文学 { background-color: #e90035;  color: #ffff4e; } /* 亮浅红色 */
.category-英国文学 { background-color: #7AE6FF; } /* 亮粉蓝色 */
.category-美国文学 { background-color: #A3FFA3; } /* 亮淡绿色 */
.category-法国文学 { background-color: #FF7AFF; } /* 亮梅红色 */
.category-俄国文学 { background-color: #FFF07A; } /* 亮卡其色 */
.category-德国文学 { background-color: #33B5E5; } /* 深天蓝 - 与小说区分 */
.category-日本文学 { background-color: #FFB47A; } /* 亮浅橙色 */
.category-拉美文学 {color: #007073;background-color: #a9ebe7;} /* 亮海绿色 */
.category-韩国文学 { background-color: #FF47B4; } /* 亮热粉色 */
.category-西班牙文学 { 
background-color: #FF7AFF; color: white;}/* 亮梅红色，和其他国家文学保持一致 */
.category-推理小说 {
  background: repeating-linear-gradient(
    45deg,
    #8B6914,
    #8B6914 16px,
    #A0782C 16px,
    #A0782C 32px
  ) !important;
  color: #F5E6D3 !important;
  position: relative;
  font-weight: 600;
  text-shadow: 1px 1px 2px rgba(0,0,0,0.3);
  border: 1px solid #6B4E12;
}

@keyframes subtlePulse {
  0%, 100% { opacity: 0.7; transform: scale(1); }
  50% { opacity: 1; transform: scale(1.05); }
}.category-恐怖小说 { background-color: #FF47FF; } /* 亮紫红色 */
.category-反乌托邦 { background-color: #FF4747; color: white; } /* 亮红色 */
.category-中国史 { background-color: #FFD47A; } /* 亮实木色 */
.category-宋史 { background-color: #FFE6A3; } /* 亮棕褐色 */
.category-明史 { background-color: #FFB4B4; } /* 亮玫瑰棕色 */
.category-全球史 { background-color: #47B8FF; color: white; } /* 亮钢蓝色 */
.category-世界史 { background-color: #47E6E6; } /* 亮军蓝色 */
.category-西方哲学 { background-color: #B47AFF; color: white; } /* 亮中紫色 */
.category-马哲 { background-color: #FF4747; color: white; } /* 亮深红色 */
.category-商业 { background-color: #FFE647; } /* 亮金色 */
.category-散文 { background-color: #FF7AE6; color: white; } /* 亮兰花紫 */
.category-诗歌 { background-color: #FF47E6; color: white; } /* 亮中兰花紫 */
.category-史诗 { background-color: #E647FF; color: white; } /* 亮深兰花紫 */
.category-儿童文学 {color: #ffffff;background-color: #ffa7e2;}/* 粉色 */
.category-瑞典文学 { background-color: #00CC99; color: white; } /* 北欧绿 - 象征瑞典的自然风光 */
.category-杂文 { background-color: #A347FF; color: white; } /* 亮蓝紫色 */
.category-书信 { background-color: #7A47FF; color: white; } /* 亮靛蓝色 */
.category-戏剧 { background-color: #7A7AFF; color: white; } /* 亮板岩蓝 */
.category-医学 { background: linear-gradient(135deg, #FF6B6B, #FF8E8E); color: white; text-shadow: 0 1px 2px rgba(0,0,0,0.1); } /* 柔和的急救红渐变 */
.category-科普 { background: linear-gradient(135deg, #4ECDC4, #66CCFF); color: white; text-shadow: 0 1px 2px rgba(0,0,0,0.1); } /* 科技感蓝绿渐变 */
.category-传说 { background: linear-gradient(45deg, #FFD700, #FFA500); color: #333; } /* 黄金渐变 */
.category-神话 { background: linear-gradient(45deg, #9B30FF, #FF00FF); color: white; } /* 紫红渐变 */
.category-女性主义 {
  background: linear-gradient(135deg, #8E44AD, #9B59B6);
  color: white;
  border-left: 2px solid #F1C40F; /* 金色点缀，象征尊严与平等 */
}
.category-漫画 {
  background: #FF6B6B;
  color: white;
  position: relative;
  border: 2px solid #333;
  box-shadow: 2px 2px 0 #333;
}

.category-漫画::before {
  content: "";
  position: absolute;
  top: -3px;
  left: -3px;
  right: -3px;
  bottom: -3px;
  background: 
    radial-gradient(circle at 20% 30%, #4ECDC4 8px, transparent 9px),
    radial-gradient(circle at 80% 70%, #FFE66D 6px, transparent 7px),
    radial-gradient(circle at 40% 80%, #FF6B9D 7px, transparent 8px);
  z-index: -1;
}


.category-站长推荐 {
  background: linear-gradient(135deg, #000000, #2a2a2a, #000000);
  color: #FFD700 !important;
  font-weight: 700;
  box-shadow: 
    0 0 15px rgba(255, 215, 0, 0.4);
  position: relative;
  /* 去掉黄色边框 */
  border: none;
  /* 保持和其他分类一样的高度 */
  padding: 4px 10px;
  font-size: 0.75rem;
}

.category-站长推荐::before {
  content: "👑 ";
  font-size: 0.8em;
  margin-right: 3px;
}

/* 默认分类样式 */
.book-category {
  background-color: #FFE6A3;
  color: #666;
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

/* 大分类系统样式 */
.main-category-selector {
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
  min-width: 140px;
  justify-content: center;
}

.main-category-selector:hover {
  transform: translateY(-50%) scale(1.05);
  box-shadow: 0 6px 20px rgba(0,0,0,0.2);
}

.main-category-icon {
  font-size: 1.2rem;
}

/* 二级分类下拉菜单 */
.sub-category-dropdown {
  position: absolute;
  top: 100%;
  left: 0;
  background: var(--content-bg-color, #fff);
  border-radius: 12px;
  padding: 8px 0;
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
  min-width: 200px;
  max-width: 300px;
  z-index: 20;
  display: none;
  margin-top: 8px;
  max-height: 400px;
  overflow-y: auto;
}

.sub-category-dropdown.show {
  display: block;
  animation: dropdownFadeIn 0.2s ease;
}

/* 大分类选项 */
.main-category-option {
  padding: 10px 16px;
  cursor: pointer;
  transition: background-color 0.2s ease;
  font-size: 0.9rem;
  color: var(--text-color);
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  position: relative;
  border-bottom: 1px solid rgba(0,0,0,0.05);
}

.main-category-option:last-child {
  border-bottom: none;
}

.main-category-option:hover {
  background-color: rgba(0,0,0,0.05);
}

.main-category-option.active {
  background-color: var(--primary-color);
  color: #333;
  font-weight: 600;
}

/* 小分类选项 */
.sub-category-option {
  padding: 8px 16px 8px 28px;
  cursor: pointer;
  transition: background-color 0.2s ease;
  font-size: 0.85rem;
  color: var(--text-color-secondary);
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  display: none;
}

.sub-category-option.show {
  display: block;
}

.sub-category-option:hover {
  background-color: rgba(0,0,0,0.08);
}

.sub-category-option.active {
  background-color: rgba(0,0,0,0.08);
  color: var(--text-color);
  font-weight: 500;
}

/* 箭头指示器 */
.main-category-option::after {
  content: "▶";
  font-size: 0.7rem;
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%) rotate(0deg);
  transition: transform 0.2s ease;
}

.main-category-option.expanded::after {
  transform: translateY(-50%) rotate(90deg);
}

/* 全部书籍选项 */
.category-option-all {
  padding: 10px 16px;
  cursor: pointer;
  transition: background-color 0.2s ease;
  font-size: 0.9rem;
  color: var(--text-color);
  border: none;
  background: none;
  width: 100%;
  text-align: left;
  border-bottom: 1px solid rgba(0,0,0,0.05);
}

.category-option-all:hover {
  background-color: rgba(0,0,0,0.05);
}

.category-option-all.active {
  background-color: var(--primary-color);
  color: #333;
  font-weight: 600;
}

/* 移动端适配 */
@media (max-width: 767px) {
  .main-category-selector {
    position: relative !important;
    left: auto !important;
    top: auto !important;
    transform: none !important;
    margin: 10px auto !important;
    display: block !important;
    min-width: 160px;
  }
  
  .sub-category-dropdown {
    position: fixed !important;
    left: 50% !important;
    transform: translateX(-50%) !important;
    min-width: 280px !important;
    max-width: 90vw !important;
  }
}

/* 画布翻转动画 - 保持原有画布样式 */
.books-container {
  position: relative;
  width: 100%;
}

.books-wrapper {
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

.books-wrapper.flipped {
  transform: rotateY(180deg);
}

.books-front, .books-friends {
  backface-visibility: hidden;
  width: 100%;
  height: auto;
}

.books-front {
  transform: rotateY(0deg);
}

.books-friends {
  position: absolute;
  top: 0;
  left: 0;
  transform: rotateY(180deg);
  display: none;
}

.books-wrapper.flipped .books-front {
  display: none;
}

.books-wrapper.flipped .books-friends {
  display: block;
  position: relative;
}

/* 页面标题区域定位 */
.page-header {
  position: relative;
  text-align: center;
  margin-bottom: 30px;
  padding: 0 160px; /* 为两个按钮留出更多空间 */
  min-height: 50px;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
}
</style>

<div class="books-container">
  <div class="books-wrapper" id="booksWrapper">
    <!-- 我的书单 -->
    <div class="books-front">
      <header class="page-header">
        <!-- 大分类选择器 -->
        <div class="main-category-selector" id="mainCategorySelector">
          <span class="main-category-icon">📚</span>
          <span id="currentMainCategory">全部书籍</span>
          <div class="sub-category-dropdown" id="subCategoryDropdown">
            <button class="category-option-all active" data-category="all">全部书籍</button>
            <!-- 大分类和小分类将通过JavaScript动态生成 -->
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

      <div class="books-grid" id="myBooksGrid">
        {% for book in site.data.books %}
          {% if not book.referee or book.referee == '' %}
          <div class="book-card card" data-book-index="{{ loop.index0 }}" 
               data-category="{{ book.category | default('未分类') }}">
            <!-- 星级评分 -->
            {% if book.stars %}
            <div class="book-rating">
              {% if book.stars == 'reading' %}
                <!-- 正在读标志 -->
                <div class="reading-indicator" title="正在阅读">
                  📖
                </div>
              {% else %}
                <div class="stars">
                  {% for i in range(1, 6) %}
                    {% set fullStars = (book.stars / 2) | round(0, 'floor') %}
                    {% set hasHalfStar = book.stars % 2 == 1 %}
                    
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
                </div>
              {% endif %}
            </div>
            {% endif %}
            
            <div class="book-cover">
              <img src="{{ book.cover }}" alt="{{ book.title }}" loading="lazy" class="book-cover-img">
              <div class="book-title-overlay">
                <h3>{{ book.title }}</h3>
              </div>
            </div>
            {% if book.review or book.notes %}
            <div class="book-buttons">
              {% if book.review %}
                <a href="{{ book.review }}" class="btn" target="_blank" rel="noopener">书评</a>
              {% endif %}
              {% if book.notes %}
                <a href="{{ book.notes }}" class="btn" target="_blank" rel="noopener">摘要</a>
              {% endif %}
            </div>
            {% endif %}
          </div>
          {% endif %}
        {% endfor %}
      </div>
    </div>

    <!-- 朋友推荐书单 -->
    <div class="books-friends">
      <header class="page-header">
        <!-- 朋友书单的大分类选择器 -->
        <div class="main-category-selector" id="mainCategorySelectorFriends">
          <span class="main-category-icon">📚</span>
          <span id="currentMainCategoryFriends">全部书籍</span>
          <div class="sub-category-dropdown" id="subCategoryDropdownFriends">
            <button class="category-option-all active" data-category="all">全部书籍</button>
            <!-- 大分类和小分类将通过JavaScript动态生成 -->
          </div>
        </div>

        <h1 class="page-title">书友推荐</h1>
        <p class="page-subtitle" style="color:var(--text-color-secondary); margin-top:6px;">
          "我们聊聊天,悲伤就过去了"
        </p>
        <button class="rabbit-toggle" id="rabbitToggleBack">
          <span class="rabbit-icon">🐇</span>
          <span>回到我的</span>
        </button>
      </header>

      <div class="books-grid" id="friendsBooksGrid">
        {% for book in site.data.books %}
          {% if book.referee and book.referee != '' %}
          <div class="book-card card" data-book-index="{{ loop.index0 }}" 
               data-category="{{ book.category | default('未分类') }}">
            <!-- 星级评分 -->
            {% if book.stars %}
            <div class="book-rating">
              {% if book.stars == 'reading' %}
                <!-- 正在读标志 -->
                <div class="reading-indicator" title="正在阅读">
                  📖
                </div>
              {% else %}
                <div class="stars">
                  {% for i in range(1, 6) %}
                    {% set fullStars = (book.stars / 2) | round(0, 'floor') %}
                    {% set hasHalfStar = book.stars % 2 == 1 %}
                    
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
                </div>
              {% endif %}
            </div>
            {% endif %}
            
            <div class="book-cover">
              <img src="{{ book.cover }}" alt="{{ book.title }}" loading="lazy" class="book-cover-img">
              <div class="book-title-overlay">
                <h3>{{ book.title }}</h3>
              </div>
            </div>
            {% if book.review or book.notes %}
            <div class="book-buttons">
              {% if book.review %}
                <a href="{{ book.review }}" class="btn" target="_blank" rel="noopener">书评</a>
              {% endif %}
              {% if book.notes %}
                <a href="{{ book.notes }}" class="btn" target="_blank" rel="noopener">摘要</a>
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

<!-- 灯箱弹窗 - 完全保持您的原有样式 -->
<div id="bookLightbox" class="lightbox">
  <div class="lightbox-overlay"></div>
  <div class="lightbox-content">
    <button class="lightbox-close">&times;</button>
    <div class="book-detail">
      <div class="book-detail-header">
        <h2 id="lightbox-title"></h2>
        <div class="book-info-container">
          <div class="book-cover-large">
            <img id="lightbox-cover" src="" alt="">
          </div>
          <div class="book-meta" id="lightbox-meta"></div>
        </div>
      </div>
      <div class="book-summary" id="lightbox-summary"></div>
      <div class="book-detail-footer">
        <a href="#" class="download-btn" id="lightbox-download" target="_blank">豆瓣链接</a>
      </div>
    </div>
  </div>
</div>

<style>
/* 灯箱样式 - 完全保持您的原有样式 */
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
  background: rgba(0, 0, 0, 0.7);
  backdrop-filter: blur(8px);
}

.lightbox-content {
  position: relative;
  background: var(--content-bg-color, #fff);
  border-radius: 20px;
  padding: 30px;
  max-width: 600px;
  width: 80%;
  margin: 5% auto;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
  animation: lightboxFadeIn 0.3s ease;
}

@keyframes lightboxFadeIn {
  from {
    opacity: 0;
    transform: scale(0.9) translateY(-20px);
  }
  to {
    opacity: 1;
    transform: scale(1) translateY(0);
  }
}

.lightbox-close {
  position: absolute;
  top: 15px;
  right: 20px;
  background: none;
  border: none;
  font-size: 1.5rem;
  color: var(--text-color-secondary);
  cursor: pointer;
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  transition: all 0.2s ease;
}

.lightbox-close:hover {
  background: rgba(0, 0, 0, 0.1);
  color: var(--text-color);
}

/* 书籍详情样式 */
.book-detail-header h2 {
  margin: 0 0 20px 0;
  color: var(--text-color);
  font-size: 1.5rem;
  font-weight: 700;
  text-align: center;
}

.book-info-container {
  display: flex;
  gap: 25px;
  align-items: flex-start;
  margin-bottom: 25px;
}

.book-cover-large {
  flex-shrink: 0;
  width: 140px;
}

.book-cover-large img {
  width: 100%;
  height: auto;
  border-radius: 12px;
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.15);
}

.book-meta {
  color: var(--text-color-secondary);
  font-size: 0.95rem;
  line-height: 1.8;
  flex: 1;
  text-align: left;
}

.book-meta div {
  margin-bottom: 6px; /* 减少间距 */
  padding: 2px 0;    /* 减少内边距 */
}

.book-meta strong {
  color: var(--text-color);
  margin-right: 8px;
  font-weight: 600;
}

/* 个人评分样式 - 紧凑版 */
.personal-rating {
  font-weight: 600;
  margin-top: 8px;    /* 减少上边距 */
  margin-bottom: 2px; /* 减少下边距 */
  padding-top: 8px;   /* 减少内边距 */
  border-top: 1px solid rgba(0, 0, 0, 0.1);
}

.personal-rating strong {
  color: inherit !important; /* 继承评分颜色 */
}

/* 推荐人样式 - 紧凑版 */
.book-referee {
  color: #8338d3; /* 紫色 */
  font-weight: 600;
  margin-top: 4px;    /* 减少上边距 */
  margin-bottom: 2px; /* 减少下边距 */
  padding-top: 4px;   /* 减少内边距 */
  /* 移除分割线 */
  border: none;
}

.book-referee strong {
  color: inherit !important;
}

/* 简介样式 - 紧凑版 */
.book-summary {
  color: var(--text-color);
  line-height: 1.6;   /* 减少行高 */
  margin-bottom: 20px; /* 减少底部间距 */
  margin-top: 8px;    /* 添加上边距 */
  font-size: 0.95rem;
  text-indent: 2em;
  background: rgba(0, 0, 0, 0.02);
  padding: 16px;      /* 减少内边距 */
  border-radius: 12px;
  border-left: 4px solid var(--primary-color);
}

.book-summary p {
  text-indent: 2em;
  margin-bottom: 0.5em; /* 减少段落间距 */
}

.book-summary p:first-child {
  margin-top: 0;
}
.book-detail-footer {
  text-align: center;
  padding-top: 20px;
  border-top: 1px solid rgba(0, 0, 0, 0.1);
}

.download-btn {
  display: inline-block;
  background: var(--primary-color);
  color: #333;
  padding: 14px 32px;
  border-radius: 16px;
  text-decoration: none;
  font-weight: 600;
  font-size: 1rem;
  border: none;
  cursor: pointer;
  transition: all 0.3s ease;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
}

.download-btn:hover {
  background: var(--primary-color-hover);
  transform: translateY(-2px);
  box-shadow: 0 6px 20px rgba(0, 0, 0, 0.2);
}


/* 六列网格布局 */
.books-grid {
  display: grid;
  grid-template-columns: repeat(6, minmax(120px, 1fr));
  gap: 28px 20px;
  justify-content: center;
}

/* 书籍卡片 */
.book-card {
  background: var(--card-bg, #fff);
  border-radius: 14px;
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  overflow: hidden;
  transition: transform 0.3s ease, box-shadow 0.3s ease;
  display: flex;
  flex-direction: column;
  align-items: center;
  position: relative; /* 为星级定位 */
  cursor: pointer;
}
.book-card:hover {
  transform: translateY(-8px);
  box-shadow: 0 10px 28px rgba(0,0,0,0.15);
}

/* 星级评分样式 */
.book-rating {
  position: absolute;
  top: 8px;
  right: 8px;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-radius: 12px;
  padding: 4px 6px;
  z-index: 2;
  box-shadow: 0 2px 8px rgba(0,0,0,0.15);
}

.stars {
  display: flex;
  gap: 1px;
  align-items: center;
}

.star {
  font-size: 0.7rem;
  position: relative;
  display: inline-block;
}

.star.full {
  color: #ffc107; /* 完整亮星 */
}

.star.empty {
  color: #ddd; /* 空星 */
}

/* 半星样式 - 黄色部分占50% */
.star.half {
  background: linear-gradient(to right, #ffc107 50%, #ddd 50%);
  -webkit-background-clip: text;
  background-clip: text;
  color: transparent;
}

/* 正在读标志 */
.reading-indicator {
  font-size: 0.7rem;
  display: flex;
  align-items: center;
  justify-content: center;
}

/* 封面容器 */
.book-cover {
  position: relative;
  width: 100%;
  aspect-ratio: 3 / 4; /* 保持3:4比例 */
  overflow: hidden;
  border-radius: 14px 14px 0 0;
}
.book-cover img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
  transition: transform 0.5s ease;
}
.book-cover:hover img {
  transform: scale(1.05);
}

/* 磨砂书名覆盖底部 */
.book-title-overlay {
  position: absolute;
  bottom: 0;
  width: 100%;
  padding: 4px 6px;
  background: rgba(255 255 255 / 0.25);
  backdrop-filter: blur(8px);
  color: var(--text-color);
  font-weight: 600;
  font-size: 0.8rem;
  text-align: center;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  box-sizing: border-box;
}

/* 按钮组 */
.book-buttons {
  margin: 8px 0;
  display: grid;
  gap: 8px;
  grid-auto-columns: 62px;
  grid-auto-flow: column;
  width: 100%;
  justify-content: center;
  padding: 0 10px;
  box-sizing: border-box;
}

/* 统一按钮样式 */
.btn {
  display: inline-flex; /* 改为flex布局 */
  align-items: center;  /* 垂直居中 */
  justify-content: center; /* 水平居中 */
  padding: 4px 0;
  font-size: 0.75rem;
  border-radius: 12px;
  font-weight: 600;
  text-decoration: none;
  user-select: none;
  transition: all 0.2s ease;
  box-shadow: 0 1px 3px rgba(0,0,0,0.1);
  width: 56px; /* 固定宽度 */
  height: 24px; /* 固定高度 */
  box-sizing: border-box; /* 确保宽高包含padding */
  background-color: var(--primary-color);
  color: #333;
  border: none;
}
.btn:hover {
  background-color: var(--primary-color-hover);
  transform: translateY(-1px);
  color: #333 !important;
  box-shadow: 0 2px 4px rgba(0,0,0,0.15);
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
  const lightbox = document.getElementById('bookLightbox');
  const lightboxTitle = document.getElementById('lightbox-title');
  const lightboxCover = document.getElementById('lightbox-cover');
  const lightboxMeta = document.getElementById('lightbox-meta');
  const lightboxSummary = document.getElementById('lightbox-summary');
  const lightboxDownload = document.getElementById('lightbox-download');
  const closeBtn = document.querySelector('.lightbox-close');
  const overlay = document.querySelector('.lightbox-overlay');
  
  // 兔子按钮和翻转功能
  const rabbitToggle = document.getElementById('rabbitToggle');
  const rabbitToggleBack = document.getElementById('rabbitToggleBack');
  const booksWrapper = document.getElementById('booksWrapper');

  // 大分类系统
  const mainCategorySelector = document.getElementById('mainCategorySelector');
  const subCategoryDropdown = document.getElementById('subCategoryDropdown');
  const currentMainCategory = document.getElementById('currentMainCategory');
  const mainCategorySelectorFriends = document.getElementById('mainCategorySelectorFriends');
  const subCategoryDropdownFriends = document.getElementById('subCategoryDropdownFriends');
  const currentMainCategoryFriends = document.getElementById('currentMainCategoryFriends');

  // 书籍数据
  const books = {{ site.data.books | json }};

  // 分类映射表（大分类 -> 小分类数组）
  const categoryHierarchy = {
    // 文学大类
    '文学': [
      '小说', '散文', '诗歌', '戏剧', '杂文', '书信',
      ,'中国古典文学', '乡土文学', '纪实文学','红色文学'
    ],
    
    // 地区文学
    '地区文学': [
      '英国文学', '美国文学', '法国文学', '俄国文学', '德国文学',
      '日本文学', '拉美文学', '韩国文学', '西班牙文学', '奥地利文学','中国文学','瑞典文学'
    ],
    
    // 历史大类
    '历史': [
      '中国史', '宋史', '明史', '全球史', '世界史'
    ],
    
    // 哲学大类
    '哲学': [
      '西方哲学', '马哲','存在主义'
    ],
    
    // 类型小说
    '类型小说': [
      '推理小说', '恐怖小说', '科幻', '反乌托邦', '儿童文学'
    ],
    
    // 科普教育
    '科普教育': [
      '科普', '医学', '心理学', '传记', '经济', '商业'
    ],
    
    // 社会科学
    '社会科学': [
      '政治', '社会学', '艺术','女性主义'
    ],
    
    // 特殊类型
    '特殊类型': [
      '漫画', '史诗', '传说', '神话', '站长推荐'
    ]
  };

  // 获取所有存在的分类（从书籍数据中提取）
  function getExistingCategories() {
    const categories = new Set(['all']);
    books.forEach(book => {
      if (book.category && book.category.trim() !== '') {
        const categoryList = book.category.split(' ').filter(cat => cat.trim() !== '');
        categoryList.forEach(cat => {
          categories.add(cat);
        });
      }
    });
    return categories;
  }

  // 初始化大分类下拉菜单
  function initMainCategoryDropdown(dropdownElement, currentCategoryElement, gridElement) {
    const existingCategories = getExistingCategories();
    
    // 清空现有选项（除了"全部书籍"）
    while (dropdownElement.children.length > 1) {
      dropdownElement.removeChild(dropdownElement.lastChild);
    }
    
    // 添加大分类选项
    Object.keys(categoryHierarchy).forEach(mainCategory => {
      // 检查这个大分类下是否有实际存在的书籍分类
      const hasExistingSubcategories = categoryHierarchy[mainCategory].some(
        subCat => existingCategories.has(subCat)
      );
      
      if (hasExistingSubcategories) {
        const mainOption = document.createElement('button');
        mainOption.className = 'main-category-option';
        mainOption.setAttribute('data-main-category', mainCategory);
        mainOption.textContent = mainCategory;
        dropdownElement.appendChild(mainOption);
        
        // 添加小分类选项
        categoryHierarchy[mainCategory].forEach(subCategory => {
          if (existingCategories.has(subCategory)) {
            const subOption = document.createElement('button');
            subOption.className = 'sub-category-option';
            subOption.setAttribute('data-category', subCategory);
            subOption.textContent = subCategory;
            subOption.style.display = 'none'; // 默认隐藏
            dropdownElement.appendChild(subOption);
          }
        });
      }
    });
    
    // 添加大分类点击事件（展开/收起小分类）
    dropdownElement.querySelectorAll('.main-category-option').forEach(option => {
      option.addEventListener('click', function(e) {
        e.stopPropagation();
        const mainCategory = this.getAttribute('data-main-category');
        
        // 切换展开状态
        const isExpanded = this.classList.toggle('expanded');
        
        // 显示/隐藏对应的小分类
        let nextElement = this.nextElementSibling;
        while (nextElement && nextElement.classList.contains('sub-category-option')) {
          if (isExpanded) {
            nextElement.style.display = 'block';
            nextElement.classList.add('show');
          } else {
            nextElement.style.display = 'none';
            nextElement.classList.remove('show');
          }
          nextElement = nextElement.nextElementSibling;
        }
      });
    });
    
    // 添加小分类点击事件
    dropdownElement.querySelectorAll('.sub-category-option').forEach(option => {
      option.addEventListener('click', function(e) {
        e.stopPropagation();
        const category = this.getAttribute('data-category');
        
        // 更新选中状态
        dropdownElement.querySelectorAll('.category-option-all, .sub-category-option').forEach(opt => {
          opt.classList.remove('active');
        });
        this.classList.add('active');
        
        // 更新显示文本
        currentCategoryElement.textContent = this.textContent;
        
        // 筛选书籍
        filterBooks(category, gridElement);
        
        // 关闭下拉菜单
        dropdownElement.classList.remove('show');
      });
    });
    
    // 添加"全部书籍"点击事件
    const allOption = dropdownElement.querySelector('.category-option-all');
    allOption.addEventListener('click', function() {
      const category = this.getAttribute('data-category');
      
      // 更新选中状态
      dropdownElement.querySelectorAll('.category-option-all, .sub-category-option').forEach(opt => {
        opt.classList.remove('active');
      });
      this.classList.add('active');
      
      // 更新显示文本
      currentCategoryElement.textContent = this.textContent;
      
      // 筛选书籍
      filterBooks(category, gridElement);
      
      // 关闭下拉菜单
      dropdownElement.classList.remove('show');
    });
  }

  // 筛选书籍（支持多分类）
  function filterBooks(category, gridElement) {
    const bookCards = gridElement.querySelectorAll('.book-card');
    
    bookCards.forEach(card => {
      if (category === 'all') {
        card.style.display = 'flex';
      } else {
        const bookCategories = card.getAttribute('data-category').split(' ');
        if (bookCategories.includes(category)) {
          card.style.display = 'flex';
        } else {
          card.style.display = 'none';
        }
      }
    });
  }

  // 初始化大分类功能
  initMainCategoryDropdown(subCategoryDropdown, currentMainCategory, document.getElementById('myBooksGrid'));
  initMainCategoryDropdown(subCategoryDropdownFriends, currentMainCategoryFriends, document.getElementById('friendsBooksGrid'));

  // 大分类选择器点击事件
  mainCategorySelector.addEventListener('click', function(e) {
    e.stopPropagation();
    subCategoryDropdown.classList.toggle('show');
  });

  mainCategorySelectorFriends.addEventListener('click', function(e) {
    e.stopPropagation();
    subCategoryDropdownFriends.classList.toggle('show');
  });

  // 点击页面其他地方关闭下拉菜单
  document.addEventListener('click', function() {
    subCategoryDropdown.classList.remove('show');
    subCategoryDropdownFriends.classList.remove('show');
    
    // 收起所有展开的大分类
    document.querySelectorAll('.main-category-option.expanded').forEach(option => {
      option.classList.remove('expanded');
      let nextElement = option.nextElementSibling;
      while (nextElement && nextElement.classList.contains('sub-category-option')) {
        nextElement.style.display = 'none';
        nextElement.classList.remove('show');
        nextElement = nextElement.nextElementSibling;
      }
    });
  });

  // 阻止下拉菜单内部点击事件冒泡
  subCategoryDropdown.addEventListener('click', function(e) {
    e.stopPropagation();
  });

  subCategoryDropdownFriends.addEventListener('click', function(e) {
    e.stopPropagation();
  });

  // 兔子按钮点击事件
  rabbitToggle.addEventListener('click', function() {
    this.classList.add('running');
    booksWrapper.classList.add('flipped');
    
    // 动画结束后移除running类
    setTimeout(() => {
      this.classList.remove('running');
    }, 600);
  });

  rabbitToggleBack.addEventListener('click', function() {
    this.classList.add('running');
    booksWrapper.classList.remove('flipped');
    
    // 动画结束后移除running类
    setTimeout(() => {
      this.classList.remove('running');
    }, 600);
  });

  // 获取评分颜色
  function getRatingColor(stars) {
    if (stars === 10) return '#ff5500'; // 绿色
  if (stars === 9) return '#c35c00'; // 绿色
    if (stars >= 0 && stars <= 4) return '#ef4444'; // 红色
    if (stars > 4 && stars <= 6) return '#f97316'; // 橙色
    if (stars > 6 && stars < 9) return '#3b82f6'; // 蓝色
    return '#6b7280'; // 默认灰色
  }

  // 点击书籍卡片打开灯箱 - 完全保持您的原有逻辑
  document.querySelectorAll('.book-card').forEach(card => {
    card.addEventListener('click', function(e) {
      // 防止点击按钮时触发
      if (e.target.closest('.btn') || e.target.closest('.book-rating')) {
        return;
      }
      
      const bookIndex = this.getAttribute('data-book-index');
      const book = books[bookIndex];
      
      if (book) {
        lightboxTitle.textContent = book.title;
        lightboxCover.src = book.cover;
        lightboxCover.alt = book.title;
        
        // 构建元数据 - 只有有值的字段才显示
        let metaHTML = `<div><strong>作者:</strong> ${book.author}</div>`;
        if (book.publisher) {
          metaHTML += `<div><strong>出版社:</strong> ${book.publisher}</div>`;
        }
        if (book.translator && book.translator.trim() !== '') {
          metaHTML += `<div><strong>译者:</strong> ${book.translator}</div>`;
        }
        
        // 添加分类信息（如果有）- 没有分割线
        if (book.category && book.category.trim() !== '') {
          // 分割分类字符串并创建彩色标签
          const categories = book.category.split(' ').filter(cat => cat.trim() !== '');
          const categoryTags = categories.map(cat => 
            `<span class="book-category-tag category-${cat}">${cat}</span>`
          ).join('');
          
          metaHTML += `<div><strong>分类:</strong> ${categoryTags}</div>`;
        }
        
        // 添加推荐人信息（如果有）- 没有分割线
        if (book.referee && book.referee.trim() !== '') {
          metaHTML += `<div class="book-referee">
            <strong>推荐人:</strong> ${book.referee}
          </div>`;
        }
        
        // 添加个人评分（只有当stars存在且不是'reading'时显示）- 有分割线
        if (book.stars && book.stars !== 'reading') {
          const ratingColor = getRatingColor(book.stars);
          metaHTML += `<div class="personal-rating" style="color: ${ratingColor}">
            <strong>个人评分🍂:</strong> ${book.stars}/10.0
          </div>`;
        }
        
        // 注意：这里删除了阅读时间的显示代码，但数据字段仍然保留
        // 如果你以后需要重新显示阅读时间，可以取消注释下面的代码：
        // if (book.reading_time && book.reading_time.trim() !== '') {
        //   metaHTML += `<div class="reading-time">
        //     <strong>阅读时间:</strong> ${book.reading_time}
        //   </div>`;
        // }
        
        lightboxMeta.innerHTML = metaHTML;
        
        // 简评
  if (book.summary) {
    // 将文本按段落分割，并为每段添加缩进
    const paragraphs = book.summary.split('\n');
    const formattedSummary = paragraphs.map(p => {
      if (p.trim()) {
        return `<p style="text-indent: 2em; margin-bottom: 0em;">${p}</p>`;
      }
      return '';
    }).join('');
    lightboxSummary.innerHTML = formattedSummary;
  } else {
    lightboxSummary.textContent = '暂无简介';
  }
        
        // 下载链接
        if (book.download) {
          lightboxDownload.href = book.download;
          lightboxDownload.style.display = 'inline-block';
        } else {
          lightboxDownload.style.display = 'none';
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
