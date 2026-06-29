{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}
  {{ page.window_title or page.title }} | {{ config.title }}
{% endblock %}

{% block content %}
  <div class="diary-wrapper">
    <!-- 将标题和副标题移到画布里 -->
    <header class="page-header" style="margin-bottom: 40px;">
      <h1 class="page-title">{{ page.title }}</h1>
      {% if page.subtitles and page.subtitles.length > 0 %}
        <div class="page-subtitle-container">
          <span class="quote-mark quote-left">"</span>
          <div class="subtitle-carousel">
            {% for subtitle in page.subtitles %}
              <!-- 修改这里：添加作品字段 -->
              <div class="subtitle-item{% if loop.first %} active{% endif %}" data-index="{{ loop.index0 }}">
                <p class="page-subtitle">{{ subtitle.quote or subtitle }}</p>
                {% if subtitle.work %}
                  <div class="work-info">
                    <span class="work-name">《{{ subtitle.work }}》</span>
                  </div>
                {% endif %}
              </div>
            {% endfor %}
          </div>
          <span class="quote-mark quote-right">"</span>
          {% if page.subtitles.length > 1 %}
            <button class="subtitle-changer">
              <svg viewBox="0 0 24 24" width="16" height="16">
                <path fill="currentColor" d="M6.99 11L3 15l3.99 4v-3H14v-2H6.99v-3zM21 9l-3.99-4v3H10v2h7.01v3L21 9z"/>
              </svg>
            </button>
          {% endif %}
        </div>
      {% endif %}
    </header>

    <!-- 添加分页容器 -->
    <div id="diary-container">
      <!-- 所有日记数据将存储在这里 -->
      <div id="diary-data-store" style="display: none;">
        {% for diary in page.diaries %}
          {% set diary_tags = diary.tags or [] %}
          {% set diary_images = diary.images or [] %}
          <div class="diary-data" 
               data-index="{{ loop.index0 }}"
               data-date="{{ diary.date }}"
               data-weekday="{{ diary.weekday or '' }}"
               data-weather="{{ diary.weather or '' }}"
               data-mood="{{ diary.mood or '' }}"
               data-tags="{{ diary_tags | join(',') }}"
               data-images="{{ diary_images | join('||') }}">
            <div class="diary-content-data">{{ diary.content | safe }}</div>
          </div>
        {% endfor %}
      </div>
      
      <!-- 动态加载的日记将显示在这里 -->
      <div class="diary-grid" id="current-page-diary">
        <!-- 这里将通过JavaScript动态填充 -->
      </div>
    </div>

    <!-- 分页控件 -->
    <div id="pagination-wrapper" style="display: none;">
      <nav class="diary-pagination">
        <button id="prev-page" class="pagination-btn pagination-prev" disabled>
          <svg style="margin-right: 6px; width: 18px; height: 18px;" fill="currentColor" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M11.354 1.646a.5.5 0 0 1 0 .708L5.707 8l5.647 5.646a.5.5 0 0 1-.708.708l-6-6a.5.5 0 0 1 0-.708l6-6a.5.5 0 0 1 .708 0z"/>
          </svg>
          上一页
        </button>
        
        <div id="page-info" class="pagination-info">
          第 <span id="current-page">1</span> 页 / 共 <span id="total-pages">?</span> 页
        </div>
        
        <button id="next-page" class="pagination-btn pagination-next">
          下一页
          <svg style="margin-left: 6px; width: 18px; height: 18px;" fill="currentColor" viewBox="0 0 16 16">
            <path fill-rule="evenodd" d="M4.646 1.646a.5.5 0 0 1 .708 0l6 6a.5.5 0 0 1 0 .708l-6 6a.5.5 0 0 1-.708-.708L10.293 8 4.646 2.354a.5.5 0 0 1 0-.708z"/>
          </svg>
        </button>
      </nav>
      
      <!-- 页面跳转 -->
      <div class="page-jump-container">
        <span class="page-jump-label">📄 跳转到</span>
        <div class="page-selector-wrapper">
          <select id="page-selector" class="page-selector">
            <!-- 选项将通过JavaScript动态生成 -->
          </select>
          <div class="selector-arrow">
            <svg width="12" height="12" fill="currentColor" viewBox="0 0 16 16">
              <path d="M7.247 11.14L2.451 5.658C1.885 5.013 2.345 4 3.204 4h9.592a1 1 0 0 1 .753 1.659l-4.796 5.48a1 1 0 0 1-1.506 0z"/>
            </svg>
          </div>
        </div>
      </div>
    </div>

  </div>

  <!-- 灯箱模态框 -->
  <div id="lightbox" class="lightbox">
    <span class="lightbox-close">&times;</span>
    <span class="lightbox-prev">&#10094;</span>
    <span class="lightbox-next">&#10095;</span>
    <div class="lightbox-content">
      <img id="lightbox-img" src="" alt="">
    </div>
  </div>

  <style>
    .diary-wrapper {
      background: #fff;
      border-radius: 20px;
      padding: 40px;
      box-shadow: 0 8px 32px rgba(0,0,0,0.08);
      margin-bottom: 40px;
      position: relative;
      max-width: 1400px;
      margin-left: auto;
      margin-right: auto;
    }

    /* 标题和副标题样式 */
    .page-header {
      text-align: center;
      margin-bottom: 40px;
    }

    .page-title {
      font-size: 2.5rem;
      font-weight: 300;
      margin-bottom: 16px;
      color: #333;
      letter-spacing: 1px;
    }

    /* 副标题容器 */
    .page-subtitle-container {
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      position: relative;
      max-width: 1200px;
      margin: 0 auto;
      width: 100%;
    }

    /* 引号样式 */
    .quote-mark {
      font-size: 2rem;
      color: #999;
      opacity: 0.6;
      font-weight: 300;
      line-height: 1;
      transition: opacity 0.3s ease;
    }

    .page-subtitle-container:hover .quote-mark {
      opacity: 0.8;
    }

    /* 副标题轮播 - 修改为更流畅的切换 */
    .subtitle-carousel {
      position: relative;
      min-height: 60px;
      overflow: hidden;
      flex: 0 1 auto;
      text-align: center;
      width: 100%;
      max-width: 800px;
    }

    /* 名言项容器 */
    .subtitle-item {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      opacity: 0;
      transform: translateY(20px);
      transition: all 0.5s ease;
      pointer-events: none;
    }

    .subtitle-item.active {
      opacity: 1;
      transform: translateY(0);
      pointer-events: auto;
      position: relative;
    }

    /* 名言文本 */
    .page-subtitle {
      color: #666;
      margin: 0 0 10px 0;
      font-size: 1.3rem;
      font-weight: 300;
      line-height: 1.6;
      letter-spacing: 0.5px;
      text-align: center;
    }

    /* 作品信息样式 */
    .work-info {
      text-align: center;
      margin-top: 8px;
    }

    .work-name {
      font-size: 0.95rem;
      color: #999;
      font-style: italic;
      letter-spacing: 0.5px;
      position: relative;
      padding-left: 20px;
      padding-right: 20px;
      display: inline-block;
    }

    .work-name::before {
      content: '';
      position: absolute;
      left: 0;
      top: 50%;
      width: 12px;
      height: 1px;
      background: linear-gradient(90deg, transparent, #ddd);
    }

    .work-name::after {
      content: '';
      position: absolute;
      right: 0;
      top: 50%;
      width: 12px;
      height: 1px;
      background: linear-gradient(90deg, #ddd, transparent);
    }

    /* 作品名的特殊样式 */
    .work-name:hover {
      color: #4cc9ff;
      transform: scale(1.05);
      transition: all 0.3s ease;
    }

    /* 更换按钮 */
    .subtitle-changer {
      background: transparent;
      border: none;
      cursor: pointer;
      padding: 8px;
      border-radius: 50%;
      color: #999;
      opacity: 0.6;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      margin-left: 4px;
      position: absolute;
      right: -40px;
      top: 50%;
      transform: translateY(-50%);
    }

    .subtitle-changer:hover {
      opacity: 1;
      background: rgba(153, 153, 153, 0.1);
    }

    /* Masonry 双列网格布局 */
    .diary-grid {
      display: grid;
      grid-template-columns: repeat(2, 1fr);
      gap: 30px;
      align-items: start;
    }

    /* 日记卡片基础样式 */
    .diary-card {
      opacity: 0;
      transform: translateY(30px);
      animation: fadeInUp 0.6s ease forwards;
      break-inside: avoid;
    }

    @keyframes fadeInUp {
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    /* 日记内容区域 - 纯白色 */
    .diary-content {
      background: #ffffff;
      border-radius: 16px;
      padding: 28px;
      box-shadow: 
        0 4px 20px rgba(0,0,0,0.06),
        0 1px 4px rgba(0,0,0,0.08);
      border: 1px solid rgba(0,0,0,0.05);
      transition: all 0.4s cubic-bezier(0.175, 0.885, 0.32, 1.275);
      position: relative;
      overflow: hidden;
      height: fit-content;
    }

    .diary-content::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 4px;
  background: linear-gradient(135deg, var(--card-color1, #FF6B6B), var(--card-color2, #FF8E8E));
  transform: scaleX(0);
  transition: transform 0.3s ease;
}

    .diary-card:hover .diary-content {
      transform: translateY(-8px);
      box-shadow: 
        0 12px 40px rgba(0,0,0,0.12),
        0 4px 15px rgba(0,0,0,0.08);
    }

    .diary-card:hover .diary-content::before {
      transform: scaleX(1);
    }

    /* 日记头部 */
    .diary-header {
      margin-bottom: 20px;
    }

    .diary-date-wrapper {
      margin-bottom: 12px;
    }

    /* 日期使用特殊颜色 */
    .diary-date {
      font-size: 1.5rem;
      font-weight: 800;
      margin: 0 0 8px 0;
      letter-spacing: -0.5px;
    }

    /* 元信息布局 - 星期、天气、心情在一行 */
    .diary-meta {
      display: flex;
      gap: 8px;
      flex-wrap: wrap;
      align-items: center;
    }

    /* 星期样式 */
    .diary-weekday {
      font-size: 0.85rem;
      color: #666;
      background: #f0f4ff;
      padding: 4px 10px;
      border-radius: 6px;
      font-weight: 500;
      border: 1px solid #e1e8ff;
    }

    /* 天气样式 */
    .diary-weather {
      font-size: 0.85rem;
      padding: 4px 10px;
      border-radius: 6px;
      font-weight: 500;
      border: 1px solid;
      position: relative;
      padding-left: 28px;
    }

    .diary-weather::before {
      content: '';
      position: absolute;
      left: 8px;
      top: 50%;
      transform: translateY(-50%);
      width: 16px;
      height: 16px;
      background-size: contain;
      background-repeat: no-repeat;
    }

    /* 不同天气的图标和颜色 */
    .diary-weather[data-weather*="晴"]::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%23F59E0B' d='M12 7c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5-2.24-5-5-5zm0 8c-1.66 0-3-1.34-3-3s1.34-3 3-3 3 1.34 3 3-1.34 3-3 3zm0-13L8.5 5.5 7 3 12 0l5 3-1.5 2.5L12 2z'/%3E%3C/svg%3E");
    }
    .diary-weather[data-weather*="晴"] {
      color: #B45309;
      background: #FEF3C7;
      border-color: #FBBF24;
    }

    .diary-weather[data-weather*="云"]::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%236B7280' d='M19.35 10.04C18.67 6.59 15.64 4 12 4 9.11 4 6.6 5.64 5.35 8.04 2.34 8.36 0 10.91 0 14c0 3.31 2.69 6 6 6h13c2.76 0 5-2.24 5-5 0-2.64-2.05-4.78-4.65-4.96z'/%3E%3C/svg%3E");
    }
    .diary-weather[data-weather*="云"] {
      color: #4B5563;
      background: #F3F4F6;
      border-color: #9CA3AF;
    }

    .diary-weather[data-weather*="雨"]::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%233B82F6' d='M8 13h2v6H8zm4 0h2v6h-2zm4 0h2v6h-2zm-8-4h2v2H8zm4 0h2v2h-2zm4 0h2v2h-2zM6 9c0-3.31 2.69-6 6-6s6 2.69 6 6c0 1.66-1.34 3-3 3H9c-1.66 0-3-1.34-3-3z'/%3E%3C/svg%3E");
    }
    .diary-weather[data-weather*="雨"] {
      color: #1D4ED8;
      background: #DBEAFE;
      border-color: #93C5FD;
    }

    .diary-weather[data-weather*="雪"]::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cg fill='none' stroke='%2360A5FA' stroke-width='1.5' stroke-linecap='round' stroke-linejoin='round'%3E%3Cpath d='M12 2v20M12 2l3 3M12 2L9 5M12 22l3-3M12 22l-3-3M2 12h20M2 12l3 3M2 12l3-3M22 12l-3 3M22 12l-3-3M6 6l12 12M6 18l12-12'/%3E%3C/g%3E%3C/svg%3E");
    }
    .diary-weather[data-weather*="雪"] {
      color: #1E40AF;
      background: #EFF6FF;
      border-color: #BFDBFE;
    }

    .diary-weather[data-weather*="风"]::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%2310B981' d='M4 10h12c1.1 0 2-.9 2-2s-.9-2-2-2H4c-1.1 0-2 .9-2 2s.9 2 2 2zm16 4H4c-1.1 0-2 .9-2 2s.9 2 2 2h16c1.1 0 2-.9 2-2s-.9-2-2-2zm-8 6H4c-1.1 0-2 .9-2 2s.9 2 2 2h8c1.1 0 2-.9 2-2s-.9-2-2-2z'/%3E%3C/svg%3E");
    }
    .diary-weather[data-weather*="风"] {
      color: #047857;
      background: #D1FAE5;
      border-color: #6EE7B7;
    }

    .diary-weather[data-weather*="雷"]::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%238B5CF6' d='M7 2v11h3v9l7-12h-4l3-8z'/%3E%3C/svg%3E");
    }
    .diary-weather[data-weather*="雷"] {
      color: #7C3AED;
      background: #EDE9FE;
      border-color: #C4B5FD;
    }

    .diary-weather[data-weather*="雾"]::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cg fill='%239CA3AF'%3E%3Ccircle cx='7' cy='13' r='1.2' opacity='0.3'/%3E%3Ccircle cx='10' cy='11' r='1.5' opacity='0.5'/%3E%3Ccircle cx='13' cy='13' r='1.8' opacity='0.7'/%3E%3Ccircle cx='16' cy='15' r='1.3' opacity='0.4'/%3E%3Ccircle cx='19' cy='13' r='1.6' opacity='0.6'/%3E%3Ccircle cx='12' cy='7' r='2' opacity='1'/%3E%3C/g%3E%3C/svg%3E");
    }
    .diary-weather[data-weather*="雾"] {
      color: #6B7280;
      background: #F9FAFB;
      border-color: #D1D5DB;
    }

    /* 默认天气样式 */
    .diary-weather:not([data-weather*="晴"]):not([data-weather*="云"]):not([data-weather*="雨"]):not([data-weather*="雪"]):not([data-weather*="风"]):not([data-weather*="雷"]):not([data-weather*="雾"])::before {
      background-image: url("data:image/svg+xml,%3Csvg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 24 24'%3E%3Cpath fill='%2366' d='M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8z'/%3E%3C/svg%3E");
    }
    .diary-weather:not([data-weather*="晴"]):not([data-weather*="云"]):not([data-weather*="雨"]):not([data-weather*="雪"]):not([data-weather*="风"]):not([data-weather*="雷"]):not([data-weather*="雾"]) {
      color: #666;
      background: #f5f5f5;
      border-color: #ddd;
    }

    /* 心情样式 */
    .diary-mood {
      font-size: 0.85rem;
      color: #333;
      background: #f8f9fa;
      padding: 4px 10px;
      border-radius: 6px;
      border: 1px solid #e9ecef;
      font-weight: 500;
    }

    /* 日记正文 */
    .diary-body {
      line-height: 1.7;
      color: #333;
    }

    .diary-text {
      font-size: 1.05rem;
    }

    .diary-text p {
      margin-bottom: 16px;
      line-height: 1.8;
    }

    .diary-text p:last-child {
      margin-bottom: 0;
    }

    /* 图片样式 */
    .diary-images {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(120px, 1fr));
      gap: 12px;
      margin-bottom: 20px;
    }

    .diary-image {
      width: 100%;
      height: 140px;
      object-fit: cover;
      border-radius: 12px;
      transition: all 0.4s ease;
      cursor: pointer;
      box-shadow: 0 3px 12px rgba(0,0,0,0.1);
    }

    .diary-image:hover {
      transform: scale(1.05);
      box-shadow: 0 6px 20px rgba(0,0,0,0.15);
    }

    /* 标签样式 */
    .diary-footer {
      margin-top: 20px;
      padding-top: 20px;
      border-top: 1px solid rgba(0,0,0,0.08);
    }

    .diary-tags {
      display: flex;
      flex-wrap: wrap;
      gap: 8px;
    }

    .diary-tag {
      font-size: 0.8rem;
      color: #667eea;
      background: rgba(102, 126, 234, 0.1);
      padding: 6px 12px;
      border-radius: 8px;
      transition: all 0.3s ease;
      font-weight: 500;
    }

    .diary-tag:hover {
      background: rgba(102, 126, 234, 0.2);
      transform: translateY(-1px);
    }

    /* ========== 分页样式 ========== */
    .diary-pagination {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-top: 50px;
      padding-top: 25px;
      border-top: 1px solid #e2e8f0;
    }

    /* 浅蓝色分页按钮 */
    .pagination-btn {
      padding: 14px 32px;
      background: linear-gradient(135deg, #4cc9ff, #2a9eff);
      color: white;
      text-decoration: none;
      border-radius: 16px;
      font-weight: 600;
      transition: all 0.3s ease;
      box-shadow: 0 6px 20px rgba(76, 201, 255, 0.25);
      border: none;
      cursor: pointer;
      font-size: 16px;
      letter-spacing: 0.5px;
      display: flex;
      align-items: center;
      justify-content: center;
      min-width: 140px;
    }

    .pagination-btn:disabled {
      background: linear-gradient(135deg, #b3e7ff, #91d2ff);
      cursor: not-allowed;
      opacity: 0.8;
      box-shadow: 0 4px 12px rgba(76, 201, 255, 0.15);
    }

    .pagination-btn:disabled:hover {
      transform: none;
      box-shadow: 0 4px 12px rgba(76, 201, 255, 0.15);
    }

    .pagination-btn:not(:disabled):hover {
      transform: translateY(-4px);
      box-shadow: 0 10px 30px rgba(76, 201, 255, 0.4);
      background: linear-gradient(135deg, #3ab9ff, #188eff);
    }

    .pagination-btn:not(:disabled):active {
      transform: translateY(-1px);
      box-shadow: 0 6px 20px rgba(76, 201, 255, 0.25);
    }

    /* 页面信息 */
    .pagination-info {
      color: #2a9eff;
      font-size: 1.1rem;
      font-weight: 700;
      padding: 12px 24px;
      background: rgba(76, 201, 255, 0.1);
      border-radius: 14px;
      border: 2px solid rgba(76, 201, 255, 0.2);
      text-align: center;
      min-width: 180px;
    }

    /* 页面跳转容器 */
    .page-jump-container {
      text-align: center;
      margin-top: 25px;
      padding: 20px;
      background: linear-gradient(135deg, rgba(76, 201, 255, 0.05), rgba(42, 158, 255, 0.08));
      border-radius: 16px;
      border: 2px solid rgba(76, 201, 255, 0.15);
      display: flex;
      flex-direction: column;
      align-items: center;
      gap: 15px;
    }

    .page-jump-label {
      color: #2a9eff;
      font-weight: 600;
      font-size: 15px;
      display: flex;
      align-items: center;
      gap: 8px;
    }

    /* 下拉选择器容器 */
    .page-selector-wrapper {
      position: relative;
      width: 200px;
    }

    /* 美化下拉选择器 */
    .page-selector {
      width: 100%;
      padding: 14px 20px;
      border-radius: 12px;
      border: 2px solid #a3dfff;
      background: white;
      color: #2a9eff;
      font-weight: 600;
      font-size: 15px;
      cursor: pointer;
      transition: all 0.3s ease;
      appearance: none;
      text-align: center;
    }

    .page-selector:hover {
      border-color: #4cc9ff;
      box-shadow: 0 0 0 4px rgba(76, 201, 255, 0.15);
      background-color: #f8fdff;
    }

    .page-selector:focus {
      outline: none;
      border-color: #2a9eff;
      box-shadow: 0 0 0 4px rgba(76, 201, 255, 0.25);
      background-color: #f8fdff;
    }

    .page-selector option {
      padding: 12px;
      background: white;
      color: #333;
      font-weight: 500;
    }

    /* 下拉箭头 */
    .selector-arrow {
      position: absolute;
      right: 18px;
      top: 50%;
      transform: translateY(-50%);
      color: #2a9eff;
      pointer-events: none;
    }

    /* 灯箱样式 */
    .lightbox {
      display: none;
      position: fixed;
      z-index: 1000;
      left: 0;
      top: 0;
      width: 100%;
      height: 100%;
      background-color: rgba(0,0,0,0.9);
      animation: fadeIn 0.3s ease;
    }

    @keyframes fadeIn {
      from { opacity: 0; }
      to { opacity: 1; }
    }

    .lightbox-content {
      position: relative;
      margin: auto;
      padding: 20px;
      width: 90%;
      max-width: 800px;
      top: 50%;
      transform: translateY(-50%);
    }

    #lightbox-img {
      width: 100%;
      height: auto;
      border-radius: 8px;
    }

    .lightbox-close {
      position: absolute;
      top: 20px;
      right: 35px;
      color: #fff;
      font-size: 40px;
      font-weight: bold;
      cursor: pointer;
      transition: 0.3s;
    }

    .lightbox-close:hover {
      color: #ccc;
    }

    .lightbox-prev,
    .lightbox-next {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      color: #fff;
      font-size: 30px;
      font-weight: bold;
      cursor: pointer;
      padding: 16px;
      transition: 0.3s;
      user-select: none;
    }

    .lightbox-prev {
      left: 20px;
    }

    .lightbox-next {
      right: 20px;
    }

    .lightbox-prev:hover,
    .lightbox-next:hover {
      background-color: rgba(255,255,255,0.1);
      border-radius: 50%;
    }

    /* 响应式设计 */
    @media (max-width: 1024px) {
      .diary-grid {
        grid-template-columns: 1fr;
        gap: 25px;
      }
    }

    @media (max-width: 768px) {
      .diary-wrapper {
        padding: 25px 20px;
        border-radius: 16px;
        margin: 20px;
      }

      .diary-content {
        padding: 24px;
      }

      .diary-date {
        font-size: 1.3rem;
      }

      .diary-images {
        grid-template-columns: repeat(auto-fit, minmax(100px, 1fr));
      }

      .diary-image {
        height: 120px;
      }

      .page-title {
        font-size: 2rem !important;
      }
      
      .page-subtitle {
        font-size: 1.1rem !important;
      }

      .work-name {
        font-size: 0.85rem;
      }

      .quote-mark {
        font-size: 1.5rem;
      }

      /* 副标题容器 */
      .page-subtitle-container {
        flex-wrap: wrap;
        justify-content: center;
        gap: 6px;
      }

      /* 响应式分页 */
      .diary-pagination {
        flex-direction: column;
        gap: 20px;
        text-align: center;
      }
      
      .pagination-btn {
        width: 100%;
        max-width: 280px;
        margin: 0 auto;
      }
      
      .pagination-info {
        order: -1;
        width: 100%;
      }
      
      .page-selector-wrapper {
        width: 100%;
        max-width: 250px;
      }
    }

    @media (max-width: 480px) {
      .diary-wrapper {
        padding: 20px 15px;
        margin: 10px;
      }

      .diary-content {
        padding: 20px;
      }

      .diary-meta {
        flex-direction: column;
        align-items: flex-start;
        gap: 6px;
      }
      
      .page-title {
        font-size: 1.8rem !important;
      }
      
      .page-subtitle {
        font-size: 1rem !important;
      }

      .work-name {
        font-size: 0.8rem;
        padding-left: 16px;
        padding-right: 16px;
      }

      .page-subtitle-container {
        gap: 4px;
      }

      .quote-mark {
        font-size: 1.2rem;
      }
      
      .pagination-btn {
        padding: 12px 20px;
        font-size: 14px;
        min-width: 120px;
      }
      
      .pagination-info {
        font-size: 1rem;
        padding: 10px 16px;
      }
    }

    /* 卡片动画延迟 */
    .diary-card:nth-child(1) { animation-delay: 0.1s; }
    .diary-card:nth-child(2) { animation-delay: 0.15s; }
    .diary-card:nth-child(3) { animation-delay: 0.2s; }
    .diary-card:nth-child(4) { animation-delay: 0.25s; }
    .diary-card:nth-child(5) { animation-delay: 0.3s; }
    .diary-card:nth-child(6) { animation-delay: 0.35s; }
  </style>

<script>
  document.addEventListener('DOMContentLoaded', function() {
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightbox-img');
    const lightboxClose = document.querySelector('.lightbox-close');
    const lightboxPrev = document.querySelector('.lightbox-prev');
    const lightboxNext = document.querySelector('.lightbox-next');
    
    let currentImageIndex = 0;
    let currentImages = [];

    // 多巴胺渐变色数组
    const gradientColors = [
      ['#FF6B6B', '#FFA8A8'],
      ['#4ECDC4', '#88F0E8'],
      ['#45B7D1', '#7ADBFF'],
      ['#96CEB4', '#C5E8C5'],
      ['#FFE66D', '#FFF4B3'],
      ['#DDA0DD', '#F5C2F5'],
      ['#FF9F68', '#FFC5A1'],
      ['#6C5CE7', '#9D8EFF'],
      ['#00B894', '#4CDFC0'],
      ['#FD79A8', '#FFB1D0'],
      ['#FDCB6E', '#FFE5A5'],
      ['#74B9FF', '#A9D4FF'],
      ['#FF7675', '#FFA8A7'],
      ['#55E6C1', '#8EF9D9'],
      ['#A29BFE', '#C8C4FF'],
      ['#FAB1A0', '#FFD4C8']
    ];

    // ==================== 分页功能 ====================
    const diaryPagination = {
      pageSize: 20,
      currentPage: 1,
      totalPages: 0,
      totalItems: 0,
      isLoading: false,
      allDiaries: []
    };

    // 初始化分页功能
    function initPagination() {
      const dataItems = document.querySelectorAll('#diary-data-store .diary-data');
      diaryPagination.totalItems = dataItems.length;
      
      dataItems.forEach((item, index) => {
        diaryPagination.allDiaries.push({
          index: index,
          date: item.dataset.date,
          weekday: item.dataset.weekday || '',
          weather: item.dataset.weather || '',
          mood: item.dataset.mood || '',
          tags: item.dataset.tags ? item.dataset.tags.split(',') : [],
          images: item.dataset.images ? item.dataset.images.split('||').filter(img => img) : [],
          content: item.querySelector('.diary-content-data').innerHTML
        });
      });
      
      diaryPagination.totalPages = Math.ceil(diaryPagination.totalItems / diaryPagination.pageSize);
      
      // 初始化所有功能
      initOriginalFeatures();
      
      if (diaryPagination.totalItems <= diaryPagination.pageSize) {
        renderAllDiaries();
        return;
      }
      
      document.getElementById('pagination-wrapper').style.display = 'block';
      initPageSelector();
      loadPage(1);
      bindPaginationEvents();
    }

    // 初始化页面选择器
    function initPageSelector() {
      const selector = document.getElementById('page-selector');
      selector.innerHTML = '';
      
      for (let i = 1; i <= diaryPagination.totalPages; i++) {
        const option = document.createElement('option');
        option.value = i;
        option.textContent = `第 ${i} 页`;
        selector.appendChild(option);
      }
      
      selector.addEventListener('change', function() {
        const pageNum = parseInt(this.value);
        if (!isNaN(pageNum) && pageNum >= 1 && pageNum <= diaryPagination.totalPages) {
          loadPage(pageNum);
        }
      });
    }

    // 绑定分页事件
    function bindPaginationEvents() {
      document.getElementById('prev-page').addEventListener('click', function() {
        if (diaryPagination.currentPage > 1 && !diaryPagination.isLoading) {
          loadPage(diaryPagination.currentPage - 1);
        }
      });
      
      document.getElementById('next-page').addEventListener('click', function() {
        if (diaryPagination.currentPage < diaryPagination.totalPages && !diaryPagination.isLoading) {
          loadPage(diaryPagination.currentPage + 1);
        }
      });
      
      document.addEventListener('keydown', function(e) {
        if (diaryPagination.isLoading) return;
        
        if (e.key === 'ArrowLeft') {
          document.getElementById('prev-page').click();
        } else if (e.key === 'ArrowRight') {
          document.getElementById('next-page').click();
        }
      });
    }

    // 加载指定页
    function loadPage(pageNum) {
      if (diaryPagination.isLoading || pageNum < 1 || pageNum > diaryPagination.totalPages) {
        return;
      }
      
      diaryPagination.isLoading = true;
      diaryPagination.currentPage = pageNum;
      
      showLoading();
      
      const startIndex = (pageNum - 1) * diaryPagination.pageSize;
      const endIndex = Math.min(startIndex + diaryPagination.pageSize, diaryPagination.totalItems);
      
      const container = document.getElementById('current-page-diary');
      container.innerHTML = '';
      
      for (let i = startIndex; i < endIndex; i++) {
        const diary = diaryPagination.allDiaries[i];
        const card = createDiaryCard(diary, i);
        container.appendChild(card);
      }
      

      
      updatePaginationInfo();
      hideLoading();
      
      window.scrollTo({ top: 0, behavior: 'smooth' });
      
      diaryPagination.isLoading = false;
    }

    // 显示加载状态
    function showLoading() {
      const container = document.getElementById('current-page-diary');
      const loadingHTML = `
        <div style="grid-column: 1 / -1; text-align: center; padding: 60px 20px;">
          <div style="display: inline-block; width: 50px; height: 50px; border: 3px solid rgba(76, 201, 255, 0.2); border-top: 3px solid #4cc9ff; border-radius: 50%; animation: spin 1s linear infinite;"></div>
          <p style="margin-top: 20px; color: #4cc9ff; font-weight: 600; font-size: 16px;">正在加载日记...</p>
        </div>
      `;
      container.innerHTML = loadingHTML;
      
      document.getElementById('prev-page').disabled = true;
      document.getElementById('next-page').disabled = true;
      document.getElementById('page-selector').disabled = true;
    }

    // 隐藏加载状态
    function hideLoading() {
      document.getElementById('prev-page').disabled = diaryPagination.currentPage === 1;
      document.getElementById('next-page').disabled = diaryPagination.currentPage === diaryPagination.totalPages;
      document.getElementById('page-selector').disabled = false;
    }

    // 创建日记卡片
function createDiaryCard(diary, globalIndex) {
  const card = document.createElement('article');
  card.className = 'diary-card';
  card.dataset.date = diary.date;
  
  const cardIndex = globalIndex % 20;
  card.style.animationDelay = `${0.1 + cardIndex * 0.05}s`;
  
  const dateFormatted = formatChineseDate(diary.date);
  
  // 使用全局索引计算颜色，确保一致性
  const colorIndex = globalIndex % gradientColors.length;
  const [color1, color2] = gradientColors[colorIndex];
  
  card.innerHTML = `
    <div class="diary-content">
      <header class="diary-header">
        <div class="diary-date-wrapper">
          <h2 class="diary-date">${dateFormatted}</h2>
        </div>
        <div class="diary-meta">
          ${diary.weekday ? `<span class="diary-weekday">${diary.weekday}</span>` : ''}
          ${diary.weather ? `<span class="diary-weather" data-weather="${diary.weather}">${diary.weather}</span>` : ''}
          ${diary.mood ? `<span class="diary-mood">${diary.mood}</span>` : ''}
        </div>
      </header>
      
      <div class="diary-body">
        ${diary.images.length > 0 ? `
          <div class="diary-images">
            ${diary.images.map(img => `<img src="${img}" alt="日记图片" class="diary-image" loading="lazy" data-src="${img}">`).join('')}
          </div>
        ` : ''}
        
        <div class="diary-text">
          ${diary.content}
        </div>
      </div>
      
      ${diary.tags.length > 0 ? `
        <footer class="diary-footer">
          <div class="diary-tags">
            ${diary.tags.map(tag => `<span class="diary-tag">#${tag}</span>`).join('')}
          </div>
        </footer>
      ` : ''}
    </div>
  `;
  
  const dateElement = card.querySelector('.diary-date');
  dateElement.style.background = `linear-gradient(135deg, ${color1}, ${color2})`;
  dateElement.style.webkitBackgroundClip = 'text';
  dateElement.style.webkitTextFillColor = 'transparent';
  dateElement.style.backgroundClip = 'text';
  dateElement.style.fontWeight = '900';
  dateElement.style.textShadow = 'none';
  
  // 修改这里：直接设置悬浮条颜色，使用相同的渐变颜色
  const diaryContent = card.querySelector('.diary-content');
  diaryContent.style.setProperty('--card-color1', color1);
  diaryContent.style.setProperty('--card-color2', color2);
  
  // 添加内联样式到卡片本身，而不是创建全局样式
  const style = document.createElement('style');
  style.textContent = `
    .diary-card[data-date="${diary.date}"] .diary-content::before {
      background: linear-gradient(135deg, ${color1}, ${color2}) !important;
    }
  `;
  card.appendChild(style);
  
  // 图片点击事件
  const images = card.querySelectorAll('.diary-image');
  images.forEach(img => {
    img.addEventListener('click', function(e) {
      const diaryCard = e.target.closest('.diary-card');
      const cardImages = Array.from(diaryCard.querySelectorAll('.diary-image'));
      const index = cardImages.indexOf(e.target);
      openLightbox(index, cardImages);
    });
  });
  
  return card;
}

    // 显示所有日记（当日记数量不超过一页时使用）
    function renderAllDiaries() {
      const container = document.getElementById('current-page-diary');
      
      diaryPagination.allDiaries.forEach((diary, index) => {
        const card = createDiaryCard(diary, index);
        container.appendChild(card);
      });
      
    }

    // 更新分页信息
    function updatePaginationInfo() {
      document.getElementById('current-page').textContent = diaryPagination.currentPage;
      document.getElementById('total-pages').textContent = diaryPagination.totalPages;
      document.getElementById('page-selector').value = diaryPagination.currentPage;
    }

    // ==================== 灯箱功能 ====================
    function openLightbox(index, images) {
      currentImageIndex = index;
      currentImages = images;
      lightboxImg.src = images[index].src;
      lightbox.style.display = 'block';
      document.body.style.overflow = 'hidden';
    }

    function closeLightbox() {
      lightbox.style.display = 'none';
      document.body.style.overflow = 'auto';
    }

    function changeImage(direction) {
      currentImageIndex += direction;
      if (currentImageIndex >= currentImages.length) {
        currentImageIndex = 0;
      } else if (currentImageIndex < 0) {
        currentImageIndex = currentImages.length - 1;
      }
      lightboxImg.src = currentImages[currentImageIndex].src;
    }

    function formatChineseDate(dateString) {
      try {
        const date = new Date(dateString);
        if (isNaN(date.getTime())) {
          return dateString;
        }
        const year = date.getFullYear();
        const month = date.getMonth() + 1;
        const day = date.getDate();
        return `${year}年${month}月${day}日`;
      } catch (e) {
        return dateString;
      }
    }

    // ==================== 名言轮播功能 ====================
    function initSubtitleCarousel() {
      const changer = document.querySelector('.subtitle-changer');
      if (!changer) return;
      
      const subtitleItems = document.querySelectorAll('.subtitle-item');
      let currentIndex = 0;
      let autoRotateInterval;
      
      // 显示指定索引的名言
      function showSubtitle(index) {
        subtitleItems.forEach(item => {
          item.classList.remove('active');
        });
        
        if (index >= subtitleItems.length) index = 0;
        if (index < 0) index = subtitleItems.length - 1;
        
        subtitleItems[index].classList.add('active');
        currentIndex = index;
      }
      
      // 切换到下一句名言
      function nextSubtitle() {
        let nextIndex = currentIndex + 1;
        if (nextIndex >= subtitleItems.length) nextIndex = 0;
        showSubtitle(nextIndex);
      }
      
      // 切换到上一句名言
      function prevSubtitle() {
        let prevIndex = currentIndex - 1;
        if (prevIndex < 0) prevIndex = subtitleItems.length - 1;
        showSubtitle(prevIndex);
      }
      
      // 点击按钮切换名言
      changer.addEventListener('click', function(e) {
        e.preventDefault();
        nextSubtitle();
        resetAutoRotate();
      });
      
      // 鼠标悬停暂停自动轮播
      changer.addEventListener('mouseenter', () => {
        clearInterval(autoRotateInterval);
      });
      
      changer.addEventListener('mouseleave', () => {
        startAutoRotate();
      });
      
      // 点击名言容器也可以切换
      const subtitleCarousel = document.querySelector('.subtitle-carousel');
      if (subtitleCarousel) {
        subtitleCarousel.addEventListener('click', function(e) {
          if (e.target.classList.contains('page-subtitle') || 
              e.target.classList.contains('work-name') ||
              e.target.closest('.page-subtitle') || 
              e.target.closest('.work-name')) {
            nextSubtitle();
            resetAutoRotate();
          }
        });
      }
      
      // 支持键盘导航
      document.addEventListener('keydown', function(e) {
        if (changer && document.activeElement !== changer && 
            subtitleCarousel && !subtitleCarousel.contains(document.activeElement)) {
          return;
        }
        
        if (e.key === 'ArrowLeft') {
          prevSubtitle();
          resetAutoRotate();
        } else if (e.key === 'ArrowRight') {
          nextSubtitle();
          resetAutoRotate();
        }
      });
      
      // 启动自动轮播
      function startAutoRotate() {
        clearInterval(autoRotateInterval);
        autoRotateInterval = setInterval(() => {
          nextSubtitle();
        }, 8000); // 8秒切换一次
      }
      
      // 重置自动轮播
      function resetAutoRotate() {
        clearInterval(autoRotateInterval);
        startAutoRotate();
      }
      
      // 初始化自动轮播
      startAutoRotate();
    }

    

    // 初始化所有原始功能
    function initOriginalFeatures() {
      // 初始化名言轮播
      initSubtitleCarousel();
      
      // 初始化图片点击事件（全局监听）
      document.addEventListener('click', function(e) {
        if (e.target.classList.contains('diary-image')) {
          const diaryCard = e.target.closest('.diary-card');
          const images = Array.from(diaryCard.querySelectorAll('.diary-image'));
          const index = images.indexOf(e.target);
          openLightbox(index, images);
        }
      });
    }

    // 灯箱事件绑定
    lightboxClose.addEventListener('click', closeLightbox);
    lightboxPrev.addEventListener('click', () => changeImage(-1));
    lightboxNext.addEventListener('click', () => changeImage(1));

    lightbox.addEventListener('click', function(e) {
      if (e.target === lightbox) {
        closeLightbox();
      }
    });

    document.addEventListener('keydown', function(e) {
      if (lightbox.style.display === 'block') {
        if (e.key === 'Escape') closeLightbox();
        if (e.key === 'ArrowLeft') changeImage(-1);
        if (e.key === 'ArrowRight') changeImage(1);
      }
    });

    // 启动分页功能
    initPagination();
  });
</script>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}