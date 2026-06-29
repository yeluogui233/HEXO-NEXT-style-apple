{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}
  {{ page.title }} | {{ config.title }}
{% endblock %}

{% block content %}
<style>
/* === 摘要页面专用样式 === */
/* 页面容器 */
.notes-container {
  position: relative;
  max-width: 1200px;
  margin: 0 auto;
  padding: 20px;
}

/* 简洁标题区域 */
.notes-header-wrapper {
  background: var(--content-bg-color, #fff);
  border-radius: 16px;
  padding: 30px 40px;
  margin-bottom: 30px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.08);
  border-left: 6px solid var(--primary-color, #667eea);
  position: relative;
  overflow: hidden;
}

/* 标题装饰背景 */
.header-bg {
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 40%;
  background: linear-gradient(45deg, transparent 70%, rgba(102, 126, 234, 0.05) 100%);
  z-index: 1;
}

.notes-header {
  position: relative;
  z-index: 2;
}

/* 主标题 */
.notes-title {
  font-size: 2rem;
  color: var(--text-color);
  margin-bottom: 15px;
  font-weight: 700;
  line-height: 1.3;
}

.notes-title::before {
  content: "📖";
  margin-right: 12px;
  font-size: 1.8rem;
  opacity: 0.8;
}

/* 文章信息栏 */
.notes-meta {
  display: flex;
  gap: 30px;
  align-items: center;
  padding-top: 15px;
  border-top: 1px solid rgba(0,0,0,0.1);
  flex-wrap: wrap;
}

.meta-item {
  display: flex;
  align-items: center;
  gap: 8px;
  color: var(--text-color-secondary);
  font-size: 0.95rem;
}

/* 标签样式 - 修复悬浮文字看不清问题 */
.notes-tags {
  display: flex;
  flex-wrap: wrap;
  gap: 8px;
  margin-top: 15px;
  padding-top: 15px;
  border-top: 1px solid rgba(0,0,0,0.1);
}

.tag-item {
  display: inline-block;
  padding: 4px 12px;
  background: rgba(102, 126, 234, 0.1);
  color: var(--primary-color);
  border-radius: 20px;
  font-size: 0.85rem;
  font-weight: 500;
  transition: all 0.2s ease;
  text-decoration: none;
  border: 1px solid rgba(102, 126, 234, 0.2);
  position: relative;
  overflow: hidden;
  z-index: 1;
}

/* 修复标签悬浮效果 - 确保文字可见 */
.tag-item::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: var(--primary-color);
  border-radius: 20px;
  transform: scaleX(0);
  transform-origin: left;
  transition: transform 0.3s ease;
  z-index: -1;
}

.tag-item:hover {
  color: #828282  !important; /* 悬停时强制白色文字 */
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(102, 126, 234, 0.25); /* 更柔和的阴影 */
  border-color: var(--primary-color);
}

.tag-item:hover::before {
  transform: scaleX(1);
}

/* 自定义图标 */
.meta-icon {
  width: 20px;
  height: 20px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.06);
  border-radius: 50%;
  padding: 4px;
  color: var(--primary-color);
}

/* 自定义SVG图标 */
.calendar-icon,
.folder-icon,
.tag-icon {
  width: 12px;
  height: 12px;
  fill: currentColor;
}

.tag-icon {
  width: 14px;
  height: 14px;
}

/* 内容区域 */
.notes-content-wrapper {
  background: var(--content-bg-color, #fff);
  border-radius: 16px;
  padding: 40px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.08);
  margin-bottom: 40px;
}

/* 正文内容 */
.notes-content {
  font-size: 1.05rem;
  line-height: 1.7;
  color: var(--text-color);
}

/* 无序列表美化 - 添加点状标识 */
.notes-content ul {
  list-style: none;
  padding: 0;
  margin: 0 0 30px 0;
}

.notes-content ul li {
  margin-bottom: 8px; /* 从15px改为8px - 减小行间距 */
  padding-left: 30px;
  position: relative;
  font-size: 1.05rem;
  line-height: 1.6;
  color: var(--text-color);
  transition: all 0.3s ease;
  border-radius: 8px;
  border: 1px solid transparent;
  padding: 10px 15px 10px 45px; /* 上下内边距从12px改为10px */
  background: transparent;
  min-height: 38px; /* 从44px改为38px */
}

/* 列表项悬停时的白色卡片效果 */
.notes-content ul li:hover {
  background: #fff;
  border-color: rgba(0,0,0,0.1);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
  margin-left: -5px; /* 轻微左移，避免完全覆盖其他项 */
  margin-right: -5px; /* 轻微右移，保持对称 */
  padding-left: 45px; /* 保持相同的左侧内边距 */
  z-index: 1; /* 确保悬浮卡片在上层 */
}

/* 调整圆点位置以匹配新的内边距 */
.notes-content ul li::before {
  content: "•";
  position: absolute;
  left: 20px; /* 从0改为20px，适应新的内边距 */
  top: 12px; /* 从14px改为12px，适应新的内边距 */
  color: var(--primary-color);
  font-size: 1.2rem;
  line-height: 1.6;
  transition: all 0.3s ease;
}

/* 悬停时圆点稍微变大 */
.notes-content ul li:hover::before {
  font-size: 1.4rem;
  color: var(--primary-color);
}

/* 多级列表支持 - 使用不同样式的点 */
.notes-content ul ul {
  margin: 8px 0 8px 20px; /* 从10px改为8px */
}

.notes-content ul ul li {
  padding-left: 40px; /* 二级列表减少左侧内边距 */
}

.notes-content ul ul li::before {
  content: "◦";
  color: var(--text-color-secondary);
  font-size: 1.1rem;
  left: 15px; /* 调整二级列表圆点位置 */
  top: 10px; /* 调整垂直位置 */
}

.notes-content ul ul li:hover::before {
  font-size: 1.3rem;
}

.notes-content ul ul ul {
  margin-left: 40px;
}

.notes-content ul ul ul li {
  padding-left: 35px; /* 三级列表再减少左侧内边距 */
}

.notes-content ul ul ul li::before {
  content: "▪";
  color: rgba(0,0,0,0.3);
  font-size: 1rem;
  left: 10px; /* 调整三级列表圆点位置 */
  top: 10px; /* 调整垂直位置 */
}

.notes-content ul ul ul li:hover::before {
  font-size: 1.2rem;
}


/* 引用块样式 */
.notes-content blockquote {
  border-left: 4px solid var(--primary-color);
  background: rgba(0,0,0,0.03);
  padding: 20px 25px;
  margin: 25px 0;
  border-radius: 0 10px 10px 0;
  position: relative;
}

.notes-content blockquote::before {
  content: "❝";
  position: absolute;
  left: 10px;
  top: 10px;
  font-size: 2rem;
  color: var(--primary-color);
  opacity: 0.3;
}

.notes-content blockquote p {
  margin: 0;
  color: var(--text-color-secondary);
  font-style: italic;
}

/* 代码块样式 */
.notes-content pre {
  background: #1a1a1a;
  color: #f8f8f2;
  padding: 20px;
  border-radius: 10px;
  overflow-x: auto;
  margin: 25px 0;
  font-family: 'Consolas', 'Monaco', monospace;
  font-size: 0.9rem;
  line-height: 1.5;
}

/* 分割线 */
.notes-content hr {
  border: none;
  height: 1px;
  background: linear-gradient(to right, transparent, rgba(0,0,0,0.1), transparent);
  margin: 40px 0;
}

/* 改进的返回按钮 - 白底黑字版本 */
.notes-actions {
  margin-top: 40px;
  padding-top: 30px;
  border-top: 1px solid rgba(0,0,0,0.1);
  text-align: center;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 10px;
  padding: 12px 28px;
  background: #fff !important;
  color: #333 !important;
  text-decoration: none;
  border-radius: 12px;
  font-weight: 600;
  font-size: 1rem;
  transition: all 0.3s ease;
  border: 2px solid rgba(0,0,0,0.1);
  cursor: pointer;
  box-shadow: 0 4px 12px rgba(0,0,0,0.08);
}

.back-btn:hover {
  background: #333 !important;
  color: #fff !important;
  transform: translateY(-3px);
  box-shadow: 0 8px 20px rgba(0,0,0,0.15);
  border-color: #333;
}

.back-btn::before {
  content: "←";
  font-size: 1.2rem;
  opacity: 0.9;
}

/* 响应式设计 */
@media (max-width: 768px) {
  .notes-container {
    padding: 15px;
  }
  
  .notes-header-wrapper {
    padding: 25px;
    margin-bottom: 20px;
  }
  
  .notes-title {
    font-size: 1.6rem;
  }
  
  .notes-content-wrapper {
    padding: 25px;
  }
  
  .notes-meta {
    gap: 20px;
    flex-direction: column;
    align-items: flex-start;
  }
  
  .notes-content ul li {
    padding-left: 35px; /* 移动端减少左侧内边距 */
    padding: 8px 12px 8px 40px; /* 从10px改为8px */
    margin-bottom: 6px; /* 移动端进一步减小间距 */
    min-height: 36px; /* 从40px改为36px */
  }
  
  .back-btn {
    width: 100%;
    justify-content: center;
  }
  
  .notes-tags {
    gap: 6px;
  }
  
  .tag-item {
    padding: 3px 10px;
    font-size: 0.8rem;
  }
  
  .notes-content ul li::before {
    left: 15px; /* 移动端调整圆点位置 */
    top: 10px; /* 移动端调整垂直位置 */
  }
  
  .notes-content ul li:hover {
    margin-left: -3px;
    margin-right: -3px;
    padding-left: 40px;
  }
  
  .notes-content ul li:hover::before {
    font-size: 1.3rem;
  }
  
    .notes-content ul ul {
    margin: 6px 0 6px 20px; /* 移动端进一步减小间距 */
  }
  .notes-content ul ul li {
    padding-left: 30px;
  }
  
  .notes-content ul ul li::before {
    left: 10px;
	top: 8px; /* 调整垂直位置 */

  }
  
  .notes-content ul ul li:hover::before {
    font-size: 1.2rem;
  }
  
  .notes-content ul ul ul li {
    padding-left: 25px;
  }
  
  .notes-content ul ul ul li::before {
    top: 8px; /* 调整垂直位置 */
    left: 5px;
  }
  
  .notes-content ul ul ul li:hover::before {
    font-size: 1.1rem;
  }
}

@media (max-width: 480px) {
  .notes-header-wrapper {
    padding: 20px;
  }
  
  .notes-title {
    font-size: 1.4rem;
  }
  
  .notes-content-wrapper {
    padding: 20px;
  }
  
  .notes-meta {
    gap: 15px;
  }
}
</style>

<div class="notes-container">
  <!-- 简洁标题区域 -->
  <div class="notes-header-wrapper">
    <div class="header-bg"></div>
    
    <header class="notes-header">
      <h1 class="notes-title">{{ page.title }}</h1>
      
      <div class="notes-meta">
        {% if page.date %}
        <div class="meta-item">
          <span class="meta-icon">
            <svg class="calendar-icon" viewBox="0 0 24 24">
              <path d="M19 3h-1V1h-2v2H8V1H6v2H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2V5c0-1.1-.9-2-2-2zm0 16H5V9h14v10zm0-12H5V5h14v2zm-7 4H7v5h5v-5z"/>
            </svg>
          </span>
          <span>{{ page.date.format('YYYY年MM月DD日') }}</span>
        </div>
        {% endif %}
        
        {% if page.categories and page.categories.length > 0 %}
        <div class="meta-item">
          <span class="meta-icon">
            <svg class="folder-icon" viewBox="0 0 24 24">
              <path d="M10 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V8c0-1.1-.9-2-2-2h-8l-2-2z"/>
            </svg>
          </span>
          {% if page.categories.join %}
            <span>{{ page.categories.join(' - ') }}</span> <!-- 将 / 改为 - -->
          {% else %}
            <span>{{ page.categories }}</span>
          {% endif %}
        </div>
        {% endif %}
        
        {% if page.tags and page.tags.length > 0 %}
        <div class="meta-item">
          <span class="meta-icon">
            <svg class="tag-icon" viewBox="0 0 24 24">
              <path d="M20 10V8h-4V4h-2v4h-4V4H8v4H4v2h4v4H4v2h4v4h2v-4h4v4h2v-4h4v-2h-4v-4h4zm-6 4h-4v-4h4v4z"/>
            </svg>
          </span>
          <span>{{ page.tags.length }}个标签</span>
        </div>
        {% endif %}
      </div>
      
      {% if page.tags and page.tags.length > 0 %}
      <div class="notes-tags">
        {% for tag in page.tags %}
          {% if tag %}
          <a href="{{ url_for('tags') }}{{ tag | replace(' ', '-') | replace('/', '-') }}" class="tag-item">
            {{ tag }}
          </a>
          {% endif %}
        {% endfor %}
      </div>
      {% endif %}
    </header>
  </div>

  <!-- 摘要内容区域 -->
  <div class="notes-content-wrapper">
    <article class="notes-content">
      {{ page.content }}
    </article>

    <!-- 改进的返回按钮 - 白底黑字 -->
    <div class="notes-actions">
      <a href="{{ url_for('books') }}" class="back-btn">
        返回书单
      </a>
    </div>
  </div>
</div>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // 为无序列表项添加悬停效果
  const listItems = document.querySelectorAll('.notes-content ul li');
  
  listItems.forEach(item => {
    // 点击列表项可以展开/折叠子列表
    const sublist = item.querySelector('ul');
    if (sublist) {
      sublist.style.display = 'none';
      item.style.cursor = 'pointer';
      
      // 添加展开图标
      const expandIcon = document.createElement('span');
      expandIcon.className = 'expand-icon';
      expandIcon.innerHTML = '▶';
      expandIcon.style.position = 'absolute';
      expandIcon.style.left = '-18px';
      expandIcon.style.top = '0.5em';
      expandIcon.style.fontSize = '0.8em';
      expandIcon.style.color = 'var(--primary-color)';
      expandIcon.style.transition = 'transform 0.3s ease';
      item.appendChild(expandIcon);
      
      item.addEventListener('click', function(e) {
        if (e.target.tagName === 'A') return;
        
        if (sublist.style.display === 'none') {
          sublist.style.display = 'block';
          expandIcon.style.transform = 'rotate(90deg)';
          expandIcon.innerHTML = '▼';
        } else {
          sublist.style.display = 'none';
          expandIcon.style.transform = 'rotate(0deg)';
          expandIcon.innerHTML = '▶';
        }
      });
    }
  });
  
  // 为标签添加点击效果
  const tags = document.querySelectorAll('.tag-item');
  tags.forEach(tag => {
    tag.addEventListener('click', function(e) {
      // 添加点击反馈
      this.style.transform = 'scale(0.95)';
      setTimeout(() => {
        this.style.transform = '';
      }, 150);
    });
  });
});
</script>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}