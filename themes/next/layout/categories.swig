{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}{{ page.title }} | {{ title }}{% endblock %}
{% block class %}categories-page{% endblock %}

{% block content %}
<div class="categories-container" style="width:100%;max-width:none;margin:0;padding:40px 5%;box-sizing:border-box;position:relative;background:#f8f9fa;min-height:100vh;">

  <!-- 页面标题 -->
  <div class="categories-header-wrapper" style="max-width:1200px;margin:0 auto 40px;">
    <div class="categories-header-glass" style="background:rgba(255,255,255,0.85);border-radius:20px;padding:30px 40px;box-shadow:0 15px 35px rgba(0,0,0,0.08);border:1px solid rgba(255,255,255,0.5);">
      <div class="categories-header" style="text-align:center;">
        <h1 class="categories-title" style="font-size:2.2em;margin-bottom:15px;font-weight:600;color:#2c3e50;line-height:1.2;">{{ page.title }}</h1>
        {% if page.subtitle %}
          <p class="categories-subtitle" style="color:#7f8c8d;font-size:1.1em;font-weight:300;margin-bottom:20px;">{{ page.subtitle }}</p>
        {% endif %}
        
        <!-- 统计信息 -->
        <div class="stats-cards" style="display:grid;grid-template-columns:repeat(3,minmax(0,1fr));gap:24px;justify-content:center;margin:28px auto 0;max-width:900px;width:100%;">
          <div class="stat-card" style="text-align:center;padding:18px 16px;background:rgba(255,255,255,0.6);border-radius:15px;min-width:0;">
            <div class="stat-number" style="font-size:2em;font-weight:700;color:#3498db;margin-bottom:5px;">{{ site.categories.length }}</div>
            <div class="stat-label" style="font-size:0.9em;color:#7f8c8d;font-weight:500;">分类</div>
          </div>
          
          <div class="stat-card" style="text-align:center;padding:18px 16px;background:rgba(255,255,255,0.6);border-radius:15px;min-width:0;">
            <div class="stat-number" style="font-size:2em;font-weight:700;color:#e74c3c;margin-bottom:5px;">{{ site.posts.length }}</div>
            <div class="stat-label" style="font-size:0.9em;color:#7f8c8d;font-weight:500;">文章</div>
          </div>
          
          <div class="stat-card" style="text-align:center;padding:18px 16px;background:rgba(255,255,255,0.6);border-radius:15px;min-width:0;">
            <div class="stat-number" style="font-size:2em;font-weight:700;color:#2ecc71;margin-bottom:5px;">
              {% set total_words = 0 %}
              {% for post in site.posts.toArray() %}
                {% if post.content %}
                  {% set post_content = post.content %}
                  {% set plain_text = post_content | replace(r/<[^>]+>/g, '') %}
                  {% set total_words = total_words + plain_text.length %}
                {% endif %}
              {% endfor %}
              {% if total_words >= 10000 %}
                {{ (total_words / 10000) | round(1) }}万
              {% else %}
                {{ total_words | number_format(0, '.', ',') }}
              {% endif %}
            </div>
            <div class="stat-label" style="font-size:0.9em;color:#7f8c8d;font-weight:500;">字数</div>
          </div>
        </div>
      </div>
    </div>
  </div>

  <!-- 分类网格 -->
  <div class="categories-grid" style="display:grid;grid-template-columns:repeat(auto-fit,minmax(350px,1fr));gap:30px;max-width:1200px;margin:0 auto;">
    {% for category in site.categories.toArray() %}
      {% set name = category.name %}
      {% set category_posts = category.posts %}
      {% set category_length = category.length %}
      {% set category_url = url_for('categories/' + name) %}

      {% set cover_url = null %}
      {% set category_summary = '' %}
      {% set category_color = '#3498db' %}

      {% if site.data.categories[name] %}
        {% set cover_url = site.data.categories[name].cover %}
        {% set category_summary = site.data.categories[name].summary %}
        {% set category_color = site.data.categories[name].color or '#3498db' %}
      {% endif %}

      <!-- 提取分类下的标签 -->
      {% set category_tags = [] %}
      {% for post in category_posts.toArray().slice(0, 5) %}
        {% if post.tags %}
          {% for tag in post.tags.toArray() %}
            {% set tag_name = tag.name %}
            {% set tag_exists = false %}
            {% for existing_tag in category_tags %}
              {% if existing_tag == tag_name %}
                {% set tag_exists = true %}
              {% endif %}
            {% endfor %}
            {% if not tag_exists and category_tags.length < 5 %}
              {% set category_tags = category_tags.concat([tag_name]) %}
            {% endif %}
          {% endfor %}
        {% endif %}
      {% endfor %}
      
      <article class="category-card-wrapper" style="width:100%;">
        <div class="category-card-glass" 
             style="background:rgba(255,255,255,0.9);border-radius:16px;overflow:hidden;box-shadow:0 8px 25px rgba(0,0,0,0.1);border:1px solid rgba(255,255,255,0.8);transition:all 0.4s cubic-bezier(0.25,0.46,0.45,0.94);position:relative;height:100%;display:flex;flex-direction:column;">
          
          <!-- 卡片图片 -->
          <div class="category-card-image-section" style="position:relative;height:180px;overflow:hidden;flex-shrink:0;">
            <img src="{{ cover_url or theme.default_banner or '/images/default-category.jpg' }}" 
                 alt="{{ name }}" 
                 class="category-card-image"
                 style="width:100%;height:100%;object-fit:cover;transition:transform 0.7s ease;"
                 loading="lazy">
            <div class="image-overlay" style="position:absolute;top:0;left:0;width:100%;height:100%;background:linear-gradient(to bottom,transparent 40%,rgba(0,0,0,0.25) 100%);"></div>
            <div class="post-count" style="position:absolute;top:15px;right:15px;background:rgba(255,255,255,0.95);color:#2c3e50;padding:6px 12px;border-radius:12px;font-size:0.85em;font-weight:600;box-shadow:0 3px 8px rgba(0,0,0,0.12);border:1px solid rgba(255,255,255,0.8);transition:all 0.3s ease;">
              {{ category_length }} 篇文章
            </div>
          </div>

          <!-- 卡片内容 -->
          <div class="category-card-content" style="padding:25px 20px;flex:1;display:flex;flex-direction:column;">
            <!-- 分类标题 -->
            <h2 class="category-card-title" style="font-size:1.4em;margin-bottom:12px;color:#2c3e50;font-weight:600;line-height:1.3;">
              {{ name }}
            </h2>

            <!-- 内容摘要 -->
            <div class="category-card-description" style="color:#5a6c7d;font-size:0.9em;line-height:1.5;margin-bottom:20px;font-weight:300;display:-webkit-box;-webkit-box-orient:vertical;-webkit-line-clamp:3;overflow:hidden;text-overflow:ellipsis;">
              {{ category_summary or '' }}
            </div>

            <!-- 标签区域 - 修复：添加 clear:both 确保从顶格开始 -->
            {% if category_tags.length > 0 %}
              <div class="category-tags" style="margin-bottom:25px;clear:both;">
                <div style="display:flex;flex-wrap:wrap;gap:8px;align-items:flex-start;">
                  {% for tag in category_tags %}
                    {% set tag_url = url_for('tags/' + tag) %}
                    <a href="{{ tag_url }}" class="tag-item" style="background:rgba(52,152,219,0.1);color:#3498db;padding:5px 12px;border-radius:10px;font-size:0.85em;font-weight:500;transition:all 0.3s ease;text-decoration:none;display:inline-block;border:1px solid rgba(52,152,219,0.2);flex-shrink:0;white-space:nowrap;"
                       onmouseover="this.style.transform='translateY(-2px)';this.style.background='rgba(52,152,219,0.2)';"
                       onmouseout="this.style.transform='translateY(0)';this.style.background='rgba(52,152,219,0.1)';"
                       ontouchstart="this.style.transform='translateY(-2px)';this.style.background='rgba(52,152,219,0.2)';"
                       ontouchend="this.style.transform='translateY(0)';this.style.background='rgba(52,152,219,0.1)';">
                      #{{ tag }}
                    </a>
                  {% endfor %}
                </div>
              </div>
            {% endif %}

            <!-- 查看分类按钮 -->
            <div class="category-card-meta" style="text-align:right;margin-top:auto;">
              <a href="{{ category_url }}" 
                 class="view-button"
                 style="display:inline-flex;align-items:center;gap:8px;background:linear-gradient(135deg, #4dc2ff 0%, #2196f3 100%);color:white;padding:10px 22px;border-radius:10px;font-size:0.9em;font-weight:600;text-decoration:none;transition:all 0.3s ease;box-shadow:0 4px 12px rgba(33,150,243,0.3);border:none;cursor:pointer;"
                 onmouseover="this.style.transform='translateY(-3px)';this.style.background='linear-gradient(135deg, #2196f3 0%, #1976d2 100%)';"
                 onmouseout="this.style.transform='translateY(0)';this.style.background='linear-gradient(135deg, #4dc2ff 0%, #2196f3 100%)';"
                 ontouchstart="this.style.transform='translateY(-3px)';this.style.background='linear-gradient(135deg, #2196f3 0%, #1976d2 100%)';"
                 ontouchend="this.style.transform='translateY(0)';this.style.background='linear-gradient(135deg, #4dc2ff 0%, #2196f3 100%)';">
                查看分类
                <svg style="width:16px;height:16px;fill:white;transition:transform 0.3s;" viewBox="0 0 24 24">
                  <path d="M10 6L8.59 7.41 13.17 12l-4.58 4.59L10 18l6-6z"/>
                </svg>
              </a>
            </div>
          </div>
          
          <!-- 悬停效果 -->
          <div class="hover-overlay" style="position:absolute;top:0;left:0;width:100%;height:100%;background:linear-gradient(135deg, rgba(52,152,219,0.06) 0%, transparent 100%);opacity:0;transition:opacity 0.3s ease;pointer-events:none;border-radius:16px;"></div>
        </div>
      </article>
    {% endfor %}
  </div>

  {% if site.categories|length == 0 %}
    <div class="empty-categories" style="text-align:center;padding:60px 20px;">
      <div style="background:rgba(255,255,255,0.8);border-radius:20px;padding:50px;max-width:600px;margin:0 auto;box-shadow:0 15px 35px rgba(0,0,0,0.08);">
        <h3 style="color:#2c3e50;margin-bottom:20px;font-weight:400;">暂无分类</h3>
        <p style="color:#7f8c8d;line-height:1.6;">您还没有创建任何文章分类，请先为文章添加分类标签。</p>
      </div>
    </div>
  {% endif %}

</div>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}

{% block head %}
{{- super() }}
<style>
/* === 修复卡片悬浮效果 === */
.category-card-wrapper {
  position: relative;
}

/* 重要：修复CSS优先级问题，使用更高特异性的选择器 */
.category-card-wrapper .category-card-glass {
  transform: translateY(0);
  transition: all 0.4s cubic-bezier(0.25, 0.46, 0.45, 0.94);
  cursor: default; /* 整张卡片不可点击 */
}

/* 重要：这里需要覆盖内联样式 */
.category-card-wrapper:hover .category-card-glass,
.category-card-wrapper.hover-active .category-card-glass {
  transform: translateY(-12px) !important;
  box-shadow: 0 20px 40px rgba(0,0,0,0.15) !important;
  border-color: rgba(52,152,219,0.3) !important;
  background: rgba(255,255,255,0.95) !important;
}

/* 图片缩放效果 */
.category-card-wrapper:hover .category-card-image,
.category-card-wrapper.hover-active .category-card-image {
  transform: scale(1.08) !important;
}

/* 悬停覆盖层效果 */
.category-card-wrapper:hover .hover-overlay,
.category-card-wrapper.hover-active .hover-overlay {
  opacity: 1 !important;
}

/* 文章数徽章效果 */
.category-card-wrapper:hover .post-count,
.category-card-wrapper.hover-active .post-count {
  background: rgba(52,152,219,0.95) !important;
  color: white !important;
  border-color: rgba(52,152,219,0.3) !important;
  transform: translateY(-2px) !important;
}

/* 让标签容器成为稳定的 Flex 盒子，负责自动换行 */
.category-tags {
  width: 100%;
  margin: 0 0 22px 0;
  padding: 0;
  display: block;
}

/* 内层容器必须用 flex，否则会出现 “左边贴边 / 第二行顶上来” 的问题 */
.category-tags > div {
  display: flex;
  flex-wrap: wrap;
  align-items: flex-start;
  gap: 10px 12px;   /* 行间距 + 列间距 */
}

/* 每个标签项必须是固定的 inline-flex，不允许 float */
.tag-item {
  display: inline-flex;
  padding: 6px 12px;
  background: rgba(52,152,219,.12);
  border-radius: 8px;
  border: 1px solid rgba(52,152,219,.25);
  color: #3498db;
  line-height: 1.4;
  white-space: nowrap;   /* 防止文字折行导致卡顿 */
}

}

/* === 标签按钮悬浮效果 === */
.tag-item {
  transition: all 0.3s ease !important;
  background: rgba(52,152,219,0.1) !important;
  color: #3498db !important;
  padding: 5px 12px !important;
  border-radius: 10px !important;
  font-size: 0.85em !important;
  font-weight: 500 !important;
  text-decoration: none !important;
  border: 1px solid rgba(52,152,219,0.2) !important;
  flex-shrink: 0 !important;
  white-space: nowrap !important;
  cursor: pointer !important;
}

.tag-item:hover,
.tag-item:active {
  background: rgba(52,152,219,0.2) !important;
  color: #2196f3 !important;
  border-color: rgba(52,152,219,0.3) !important;
  transform: translateY(-2px) !important;
}

/* === 按钮悬浮效果 === */
.view-button {
  transition: all 0.3s ease !important;
  display: inline-flex !important;
  align-items: center !important;
  gap: 8px !important;
  background: linear-gradient(135deg, #4dc2ff 0%, #2196f3 100%) !important;
  color: white !important;
  padding: 10px 22px !important;
  border-radius: 10px !important;
  font-size: 0.9em !important;
  font-weight: 600 !important;
  text-decoration: none !important;
  box-shadow: 0 4px 12px rgba(33,150,243,0.3) !important;
  border: none !important;
  cursor: pointer !important;
}

.view-button:hover,
.view-button:active {
  background: linear-gradient(135deg, #2196f3 0%, #1976d2 100%) !important;
  transform: translateY(-3px) !important;
  box-shadow: 0 6px 20px rgba(33,150,243,0.4) !important;
}

.view-button:hover svg,
.view-button:active svg {
  transform: translateX(5px) !important;
}

/* === 统计卡片悬停 === */
.stat-card {
  transition: all 0.3s ease !important;
}

.stat-card:hover {
  transform: translateY(-6px) !important;
  box-shadow: 0 12px 25px rgba(0,0,0,0.1) !important;
  background: rgba(255,255,255,0.8) !important;
}

/* === 触摸设备优化 === */
@media (hover: hover) {
  /* 桌面设备悬停效果 */
  .category-card-wrapper:hover .category-card-glass {
    transform: translateY(-12px) !important;
  }
  
  .tag-item:hover {
    transform: translateY(-2px) !important;
  }
  
  .view-button:hover {
    transform: translateY(-3px) !important;
  }
}

@media (hover: none) and (pointer: coarse) {
  /* 触摸设备激活效果 */
  .category-card-wrapper:active .category-card-glass {
    transform: translateY(-8px) !important;
    box-shadow: 0 15px 30px rgba(0,0,0,0.15) !important;
  }
  
  .category-card-wrapper:active .category-card-image {
    transform: scale(1.05) !important;
  }
  
  .tag-item:active {
    transform: translateY(-2px) !important;
    background: rgba(52,152,219,0.2) !important;
  }
  
  .view-button:active {
    transform: translateY(-3px) !important;
    background: linear-gradient(135deg, #2196f3 0%, #1976d2 100%) !important;
  }
}

/* === 卡片点击事件处理 === */
/* 确保只有按钮和标签可点击 */
.tag-item, .view-button {
  cursor: pointer;
}

/* === 加载动画 === */
@keyframes fadeInUp {
  from {
    opacity: 0;
    transform: translateY(30px) scale(0.98);
  }
  to {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

.category-card-wrapper {
  animation: fadeInUp 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94) forwards;
  opacity: 0;
}

.category-card-wrapper:nth-child(1){animation-delay:0.1s;}
.category-card-wrapper:nth-child(2){animation-delay:0.2s;}
.category-card-wrapper:nth-child(3){animation-delay:0.3s;}
.category-card-wrapper:nth-child(4){animation-delay:0.4s;}
.category-card-wrapper:nth-child(5){animation-delay:0.5s;}
.category-card-wrapper:nth-child(6){animation-delay:0.6s;}
.category-card-wrapper:nth-child(7){animation-delay:0.7s;}
.category-card-wrapper:nth-child(8){animation-delay:0.8s;}

/* === 响应式设计 === */
@media (max-width: 1200px) { 
  .categories-grid { 
    grid-template-columns: repeat(auto-fit, minmax(320px, 1fr)) !important; 
    gap: 25px !important; 
  }
}

@media (max-width: 992px) {
  .categories-grid { 
    grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)) !important; 
    gap: 20px !important; 
  }
  .category-card-image-section { 
    height: 160px !important; 
  }
  .categories-header-glass { 
    padding: 25px 30px !important; 
  }
  .categories-title { 
    font-size: 2em !important; 
  }
  .stat-card {
    padding: 12px 18px !important;
    min-width: 100px !important;
  }
  .stat-number {
    font-size: 1.6em !important;
  }
}

/* 平板设备 */
@media (max-width: 768px) { 
  .categories-container { 
    padding: 30px 15px !important; 
  } 
  .categories-header-glass { 
    padding: 20px 25px !important; 
    border-radius: 16px !important; 
    margin-bottom: 25px !important; 
  } 
  .categories-title { 
    font-size: 1.8em !important; 
    margin-bottom: 10px !important; 
  } 
  .categories-subtitle { 
    font-size: 1em !important; 
  } 
  
  /* 统计卡片垂直排列 */
  .stats-cards {
    flex-direction: row;
    gap: 15px !important;
    justify-content: space-around !important;
  }
  
  .stat-card {
    width: auto !important;
    flex: 1;
    min-width: 0;
    margin: 0 5px;
  }
  
  /* 平板端改为双列布局 - 改为更小尺寸 */
  .categories-grid { 
    grid-template-columns: repeat(2, minmax(150px, 1fr)) !important; 
    gap: 16px !important;  /* 减少间距 */
    max-width: 100% !important;
  }
  
  /* 优化卡片尺寸 */
  .category-card-content { 
    padding: 16px 14px !important;  /* 减少内边距 */
  } 
  .category-card-title { 
    font-size: 1.1em !important;  /* 减小字体 */
    margin-bottom: 8px !important; 
  }
  .category-card-description { 
    font-size: 0.8em !important;  /* 减小字体 */
    margin-bottom: 12px !important; 
    line-height: 1.4 !important; 
    -webkit-line-clamp: 2 !important;  /* 减少显示行数 */
  }
  .category-card-image-section { 
    height: 140px !important;  /* 减小图片高度 */
  }
  
  /* 移动端减少悬浮效果 */
  .category-card-wrapper:hover .category-card-glass,
  .category-card-wrapper:active .category-card-glass,
  .category-card-wrapper.hover-active .category-card-glass {
    transform: translateY(-8px) !important;
    box-shadow: 0 15px 30px rgba(0,0,0,0.12) !important;
  }
}

/* 修改这段代码 */
@media (max-width: 600px) {
  .categories-grid { 
    grid-template-columns: repeat(2, minmax(140px, 1fr)) !important;  /* 保持双列但更紧凑 */
    gap: 12px !important;  /* 进一步减少间距 */
    padding: 0 8px !important;  /* 增加左右内边距 */
  }
  
  /* 统计卡片横向排列但更紧凑 */
  .stats-cards {
    flex-direction: row;
    gap: 8px !important;
    justify-content: center !important;
    flex-wrap: wrap;
  }
  
  .stat-card {
    min-width: 90px !important;  /* 减少宽度 */
    padding: 12px 8px !important;
    border-radius: 10px !important;
  }
  
  .stat-number {
    font-size: 1.4em !important;
  }
  
  .stat-label {
    font-size: 0.8em !important;
  }
}

/* 修改这段代码 */
@media (max-width: 480px) { 
  .categories-container { 
    padding: 12px 8px !important;  /* 减少左右 padding */
    box-sizing: border-box;
    width: 100vw;  /* 确保不超出视口 */
    overflow-x: hidden;  /* 防止水平滚动 */
  } 
  
  .categories-header-glass { 
    padding: 16px 14px !important;
    margin: 0 auto 20px !important;
    max-width: 100%;
    box-sizing: border-box;
  } 
  .categories-title { 
    font-size: 1.4em !important; 
  } 
  .categories-subtitle { 
    font-size: 0.9em !important; 
  }
  
  .categories-grid { 
    grid-template-columns: repeat(2, minmax(calc(50% - 6px), 1fr)) !important; 
    gap: 12px !important; 
    padding: 0 4px !important;  /* 减少内边距 */
    margin: 0 auto !important;
    width: 100%;
    box-sizing: border-box;
  }
 .category-card-wrapper {
    min-width: 0;  /* 重要：允许卡片收缩 */
    width: 100%;
  }
  
  .category-card-glass {
    width: 100%;
    max-width: 100%;
    box-sizing: border-box;
  }
  
  .category-card-content { 
    padding: 14px 10px !important;  /* 进一步减少内边距 */
  }
  .category-card-title { 
    font-size: 1em !important; 
    margin-bottom: 6px !important; 
  }
  .category-card-description { 
    font-size: 0.75em !important; 
    margin-bottom: 10px !important; 
    line-height: 1.3 !important;
    -webkit-line-clamp: 2 !important;
  }
  .category-card-image-section { 
    height: 120px !important; 
  }
  .post-count { 
    padding: 4px 8px !important; 
    font-size: 0.75em !important; 
    top: 10px !important; 
    right: 10px !important; 
    border-radius: 8px !important;
  }
  .view-button { 
    font-size: 0.8em !important; 
    padding: 8px 14px !important;
  }
  .tag-item {
    padding: 3px 8px !important;
    font-size: 0.75em !important;
    border-radius: 6px !important;
  }
}
/* 新增：专门针对 375-400px 宽度的优化 */
@media (min-width: 361px) and (max-width: 400px) {
  .categories-container {
    padding: 12px 6px !important;
  }
  
  .categories-grid {
    grid-template-columns: repeat(2, 1fr) !important;
    gap: 10px !important;
    padding: 0 2px !important;
  }
  
  .category-card-content {
    padding: 12px 10px !important;
  }
  
  .category-card-title {
    font-size: 0.95em !important;
  }
  
  .category-card-description {
    font-size: 0.72em !important;
    line-height: 1.3 !important;
  }
  
  .category-card-image-section {
    height: 110px !important;
  }
  
  .view-button {
    padding: 7px 12px !important;
    font-size: 0.78em !important;
  }
  
  .tag-item {
    padding: 3px 6px !important;
    font-size: 0.7em !important;
    margin-bottom: 4px !important;
  }
}
/* 超小屏手机优化 */
/* 修改这段代码 */
@media (max-width: 360px) {
  .categories-container { 
    padding: 12px 6px !important; 
  }
  .categories-header-glass { 
    padding: 14px !important; 
  }
  .categories-title { 
    font-size: 1.3em !important; 
  }
  
  /* 超小屏改为单列布局 */
  .categories-grid { 
    grid-template-columns: 1fr !important; 
    gap: 12px !important; 
    max-width: 320px !important;
    margin: 0 auto !important;
  }
  
  .category-card-content { 
    padding: 16px 14px !important; 
  }
  .category-card-title { 
    font-size: 1.2em !important; 
  }
  .category-card-image-section { 
    height: 150px !important; 
  }
  .category-card-description { 
    -webkit-line-clamp: 3 !important;  /* 单列可以显示更多 */
  }
}
/* 新增这段代码 */
@media (max-width: 320px) {
  .categories-container { 
    padding: 10px 4px !important; 
  }
  .categories-header-glass { 
    padding: 12px !important; 
  }
  .categories-title { 
    font-size: 1.2em !important; 
  }
  .categories-subtitle { 
    font-size: 0.85em !important; 
  }
  
  .categories-grid { 
    max-width: 300px !important;
    gap: 10px !important; 
  }
  
  .stat-card {
    min-width: 80px !important;
    padding: 10px 6px !important;
  }
  
  .stat-number {
    font-size: 1.3em !important;
  }
}

/* 在移动端减少动画延迟 */
@media (max-width: 768px) {
  .category-card-wrapper:nth-child(n) { 
    animation-delay: 0.1s !important; 
  }
}

/* 深色模式适配 */
@media (prefers-color-scheme: dark) {
  .categories-container {
    background: #1a1a1a !important;
  }
  
  .categories-header-glass {
    background: rgba(30, 30, 30, 0.85) !important;
    border-color: rgba(255,255,255,0.1) !important;
  }
  
  .categories-title {
    color: #e0e0e0 !important;
  }
  
  .categories-subtitle {
    color: #a0a0a0 !important;
  }
  
  .stat-card {
    background: rgba(50, 50, 50, 0.6) !important;
  }
  
  .stat-number {
    color: #e0e0e0 !important;
  }
  
  .stat-label {
    color: #b0b0b0 !important;
  }
  
  .category-card-glass {
    background: rgba(35, 35, 35, 0.9) !important;
    border-color: rgba(255,255,255,0.1) !important;
  }
  
  .category-card-title {
    color: #e0e0e0 !important;
  }
  
  .category-card-description {
    color: #b0b0b0 !important;
  }
  
  .post-count {
    background: rgba(60, 60, 60, 0.95) !important;
    color: #e0e0e0 !important;
    border-color: rgba(255,255,255,0.1) !important;
  }
  
  .category-card-wrapper:hover .post-count,
  .category-card-wrapper.hover-active .post-count {
    background: rgba(52,152,219,0.95) !important;
    color: white !important;
  }
  
  .tag-item {
    background: rgba(52,152,219,0.15) !important;
    color: #5dade2 !important;
    border-color: rgba(52,152,219,0.3) !important;
  }
  
  .tag-item:hover, .tag-item:active {
    background: rgba(52,152,219,0.25) !important;
  }
  
  .view-button {
    background: linear-gradient(135deg, #2980b9 0%, #1f639b 100%) !important;
  }
  
  .view-button:hover, .view-button:active {
    background: linear-gradient(135deg, #3498db 0%, #2980b9 100%) !important;
  }
  
}
/* 方案 A：给描述区一个最小高度（按行数调整），并禁止 flex:1 拉伸 */
.category-card-content {
  display: flex;
  flex-direction: column;
}

/* 禁止描述区占据剩余高度 */
.category-card-description {
  flex: 0 0 auto !important;    /* 不再伸展 */
  min-height: 1.5em !important;  /* 约等于 3 行文本，按需调整（1 行 ≈ 1.5em） */
  -webkit-line-clamp: 3 !important; /* 保持你原来的行数裁剪设置 */
  display: -webkit-box !important;
  -webkit-box-orient: vertical !important;
  overflow: hidden !important;
}

/* 保证标签区始终紧跟在描述后面 */
.category-tags { 
  margin-top: 12px !important;
  clear: none !important;
  display: block !important;
}

</style>

<!-- 简化JavaScript处理触摸悬停 -->
<script>
document.addEventListener('DOMContentLoaded', function() {
  // 处理触摸设备的悬停效果
  const cardWrappers = document.querySelectorAll('.category-card-wrapper');
  
  cardWrappers.forEach(wrapper => {
    wrapper.addEventListener('touchstart', function(e) {
      // 防止触摸到按钮或标签时触发卡片悬停
      if (!e.target.closest('.tag-item') && !e.target.closest('.view-button')) {
        this.classList.add('hover-active');
      }
    });
    
    wrapper.addEventListener('touchend', function(e) {
      if (!e.target.closest('.tag-item') && !e.target.closest('.view-button')) {
        this.classList.remove('hover-active');
      }
    });
    
    wrapper.addEventListener('touchcancel', function(e) {
      this.classList.remove('hover-active');
    });
  });
  
  // 处理触摸设备上的标签和按钮点击
  document.querySelectorAll('.tag-item, .view-button').forEach(btn => {
    btn.addEventListener('touchstart', function(e) {
      this.style.opacity = '0.8';
      e.stopPropagation(); // 防止事件冒泡触发卡片悬停
    });
    
    btn.addEventListener('touchend', function(e) {
      this.style.opacity = '1';
    });
  });
});
</script>
{% endblock %}
