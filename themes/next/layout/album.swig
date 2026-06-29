{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}
  {{ page.window_title or page.title }} | {{ config.title }}
{% endblock %}

{% block head %}
  {{ super() }}
  <!-- basicLightbox -->
  <link rel="stylesheet" href="https://unpkg.com/basiclightbox@5.0.4/dist/basicLightbox.min.css">
  <script src="https://unpkg.com/basiclightbox@5.0.4/dist/basicLightbox.min.js"></script>
  <!-- Font Awesome for icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
{% endblock %}

{% block content %}
<div class="album-page-shell">

  <!-- 拟态日夜模式切换按钮，移到右上角 -->
  <div id="g-btn" title="切换日夜模式" role="button" tabindex="0" aria-label="切换日夜模式"></div>

  <!-- 白色画布整体包裹 -->
  <div class="album-wrapper">

    <!-- 标题在画布顶部居中 -->
    <header class="page-header" style="text-align:center; margin-bottom: 30px;">
      <h1 class="page-title" id="album-title">{{ page.title }}</h1>
      {% if page.subtitle %}
        <p class="page-subtitle" style="color:var(--text-color-secondary); margin-top:5px;">
          {{ page.subtitle }}
        </p>
      {% endif %}
    </header>

    <!-- 相册容器 -->
    <div class="album-container">
      <!-- 两列大卡片 -->
      <div id="photo-wall" class="photo-wall"></div>
      
      <!-- 加载更多按钮 -->
      <div class="load-more-container" id="load-more-container">
        <button id="load-more-btn" class="load-more-btn">
          <i class="fas fa-spinner fa-spin" id="loading-spinner" style="display:none;"></i>
          <span id="load-more-text">加载更多照片</span>
        </button>
        <div class="pagination-info" id="pagination-info">
          第 <span id="current-page">1</span> 页 / 共 <span id="total-pages">0</span> 页
        </div>
      </div>
      
      <!-- 无照片提示 -->
      <div id="no-photos-message" class="no-photos-message" style="display:none;">
        <i class="fas fa-camera"></i>
        <p>暂无照片</p>
      </div>
    </div>

  </div>

</div>

<style>
/* 画布宽度贴近 Next 内容宽度 */
.album-page-shell {
  width: 100%;
}

.album-wrapper {
  background: #fff;
  border-radius: 16px;
  padding: 40px 30px;
  box-shadow: 0 6px 20px rgba(0,0,0,0.05);
  margin-bottom: 40px;
  max-width: 960px;
  margin-left: auto;
  margin-right: auto;
}

/* 页面标题样式 */
.page-header {
  text-align: center;
  margin-bottom: 30px;
}

.page-title {
  font-size: 2.8rem;
  font-weight: 800;
  margin-bottom: 8px;
  /* 初始颜色，会被JS动态设置 */
  background: linear-gradient(135deg, #A3D9FF, #7AB8FF);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
  padding: 0 10px;
  letter-spacing: 1px;
}

.page-subtitle {
  color: var(--text-color-secondary);
  margin-top: 5px;
  font-size: 1.1rem;
}

/* 两列更大卡片 */
.photo-wall {
  display: grid;
  grid-template-columns: repeat(2, 1fr);
  gap: 24px;
  opacity: 0;
  animation: fadeIn 0.6s ease forwards;
}

@keyframes fadeIn {
  to { opacity: 1; }
}

.photo-item {
  display: flex;
  flex-direction: column;
  transition: transform 0.3s ease;
}

.photo-frame {
  position: relative;
  cursor: zoom-in;
  overflow: hidden;
  border-radius: 12px;
  background: var(--content-bg-color);
  box-shadow: 0 4px 12px rgba(0,0,0,0.1);
  transition: all 0.3s ease;
  aspect-ratio: 16 / 10;
}
.photo-frame:hover {
  transform: translateY(-3px);
  box-shadow: 0 8px 24px rgba(0,0,0,0.15);
}

.photo-image {
  width: 100%;
  height: 100%;
  object-fit: contain;
  background: #f6f8fc;
  display: block;
  transition: transform 0.4s ease;
}
.photo-frame:hover .photo-image { transform: scale(1.05); }

.photo-zoom-icon {
  position: absolute;
  top: 12px;
  right: 12px;
  background: rgba(0,0,0,0.6);
  color: white;
  width: 30px;
  height: 30px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  opacity: 0;
  transition: opacity 0.3s;
  font-size: 0.85rem;
}
.photo-frame:hover .photo-zoom-icon { opacity: 1; }

/* 照片信息区域 */
.photo-info-overlay {
  position: absolute;
  bottom: 0;
  left: 0;
  right: 0;
  background: linear-gradient(to top, rgba(0,0,0,0.85), transparent);
  padding: 15px 12px 10px;
  color: white;
  opacity: 0;
  transition: opacity 0.3s ease;
  transform: translateY(5px);
  backdrop-filter: blur(2px);
}

.photo-frame:hover .photo-info-overlay {
  opacity: 1;
  transform: translateY(0);
}

.photo-location {
  font-size: 0.8rem;
  margin-bottom: 4px;
  display: flex;
  align-items: center;
  gap: 5px;
}

.photo-location i {
  color: #4ECDC4;
  font-size: 0.7rem;
}

.photo-date {
  font-size: 0.75rem;
  opacity: 0.95;
  display: flex;
  align-items: center;
  gap: 5px;
}

.photo-date i {
  color: #FFD166;
  font-size: 0.7rem;
}

.photo-caption {
  margin-top: 10px;
  font-size: 0.95rem;
  color: var(--text-color);
  text-align: center;
  line-height: 1.4;
}

/* 加载更多按钮 */
.load-more-container {
  text-align: center;
  margin-top: 50px;
  padding-top: 30px;
  border-top: 1px solid rgba(0,0,0,0.08);
}

.load-more-btn {
  background: linear-gradient(135deg, #A3D9FF, #7AB8FF);
  color: white;
  border: none;
  padding: 14px 35px;
  border-radius: 35px;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s ease;
  display: inline-flex;
  align-items: center;
  gap: 12px;
  box-shadow: 0 4px 15px rgba(0,0,0,0.2);
  position: relative;
  overflow: hidden;
}

.load-more-btn::before {
  content: '';
  position: absolute;
  top: 0;
  left: -100%;
  width: 100%;
  height: 100%;
  background: linear-gradient(90deg, transparent, rgba(255,255,255,0.3), transparent);
  transition: 0.5s;
}

.load-more-btn:hover:not(:disabled) {
  transform: translateY(-3px);
  box-shadow: 0 8px 25px rgba(0,0,0,0.3);
}

.load-more-btn:hover:not(:disabled)::before {
  left: 100%;
}

.load-more-btn:disabled {
  opacity: 0.6;
  cursor: not-allowed;
  transform: none !important;
  box-shadow: none !important;
}

.pagination-info {
  margin-top: 15px;
  color: var(--text-color-secondary);
  font-size: 0.9rem;
}

/* 无照片提示 */
.no-photos-message {
  text-align: center;
  padding: 60px 20px;
  color: var(--text-color-secondary);
}

.no-photos-message i {
  font-size: 3rem;
  margin-bottom: 20px;
  opacity: 0.5;
}

.no-photos-message p {
  font-size: 1.1rem;
  margin: 0;
}

/* 灯箱样式覆盖全屏并固定定位 */
.ultimate-lightbox {
  background: rgba(0,0,0,0.95) !important;
  display: flex;
  justify-content: center;
  align-items: center;
  position: fixed !important;
  top: 0; left: 0; width: 100vw; height: 100vh;
  z-index: 99999;
}

.ultimate-lightbox img {
  max-width: 90vw;
  max-height: 90vh;
  transition: transform 0.3s;
  cursor: zoom-in;
  border-radius: 8px;
  box-shadow: 0 15px 50px rgba(0,0,0,0.5);
}

.ultimate-lightbox img.zoomed {
  transform: scale(1.5);
  cursor: zoom-out;
}

/* 灯箱信息 */
.lightbox-info {
  position: fixed;
  bottom: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0,0,0,0.85);
  color: white;
  padding: 12px 20px;
  border-radius: 10px;
  text-align: center;
  min-width: 250px;
  max-width: 500px;
  z-index: 100000;
  backdrop-filter: blur(5px);
  border: 1px solid rgba(255,255,255,0.1);
}

.lightbox-info .lightbox-desc {
  font-size: 0.95rem;
  margin-bottom: 6px;
  font-weight: 500;
}

.lightbox-meta {
  display: flex;
  justify-content: center;
  gap: 15px;
  font-size: 0.8rem;
  opacity: 0.9;
}

.lightbox-meta span {
  display: flex;
  align-items: center;
  gap: 5px;
}

.lightbox-index {
  position: fixed;
  top: 20px;
  left: 50%;
  transform: translateX(-50%);
  background: rgba(0,0,0,0.85);
  color: white;
  padding: 6px 18px;
  border-radius: 20px;
  font-size: 0.85rem;
  z-index: 100000;
  backdrop-filter: blur(5px);
  border: 1px solid rgba(255,255,255,0.1);
}

/* 左右切换箭头 */
.lightbox-arrow {
  position: fixed;
  top: 50%;
  transform: translateY(-50%);
  font-size: 2rem;
  color: white;
  cursor: pointer;
  padding: 0 20px;
  user-select: none;
  opacity: 0.5;
  transition: opacity 0.3s;
  z-index: 100000;
}
.lightbox-arrow:hover { opacity: 1; }
.lightbox-prev { left: 10px; }
.lightbox-next { right: 10px; }

/* 关闭按钮 */
.lightbox-close {
  position: fixed;
  top: 15px;
  right: 15px;
  font-size: 1.2rem;
  color: white;
  cursor: pointer;
  width: 35px;
  height: 35px;
  display: flex;
  align-items: center;
  justify-content: center;
  background: rgba(0,0,0,0.5);
  border-radius: 50%;
  z-index: 100000;
  transition: all 0.3s;
}

.lightbox-close:hover {
  background: rgba(0,0,0,0.7);
  transform: rotate(90deg);
}

/* 响应式 */
@media (max-width: 992px) {
  .photo-wall { grid-template-columns: 1fr; }
  .page-title { font-size: 2.2rem; }
}

/* 拟态日夜切换按钮样式，移到右上角 */
#g-btn {
  position: fixed;
  top: 20px;
  right: 20px;
  width: 220px;
  height: 90px;
  border-radius: 90px;
  background:
    radial-gradient(circle at 18% 20px, #fff, #fff 6px, transparent 7px, transparent),
    radial-gradient(circle at 35% 45px, #fff, #fff 1px, transparent 2px, transparent),
    radial-gradient(circle at 10% 70px, #fff, #fff 2.5px, transparent 3.5px, transparent),
    radial-gradient(circle at 25% 15px, #fff, #fff 3px, transparent 4px, transparent),
    radial-gradient(circle at 15% 50px, #fff, #fff 1.5px, transparent 2.5px, transparent),
    radial-gradient(circle at 30% 75px, #fff, #fff 5px, transparent 6px, transparent),
    radial-gradient(circle at 5% 30px, #fff, #fff 0.5px, transparent 1.5px, transparent),
    radial-gradient(circle at 25% 60px, #fff, #fff 0.5px, transparent 1.5px, transparent),
    radial-gradient(circle at 7% 35px, #fff, #fff 0.5px, transparent 1.5px, transparent),
    linear-gradient(90deg, #2b303e, #2b303e 50%, #5a81b4 50%, #5a81b4);
  background-repeat: no-repeat;
  background-size: 200% 100%;
  background-position: 100% 0;
  box-shadow:
    0 -3px 4px #999,
    inset 0 3px 5px #333,
    0 4px 4px #ffe,
    inset 0 -3px 5px #ddd;
  cursor: pointer;
  overflow: hidden;
  transition: .5s all;
  outline: none; /* 去掉蓝色边框 */
}
#g-btn:focus { outline: none; box-shadow: none; }

/* 保留按钮的伪元素和激活效果 */
#g-btn::before,
#g-btn::after {
  content: "";
  position: absolute;
  transition: .5s all;
}
#g-btn::before {
  width: 75px;
  height: 75px;
  border-radius: 50%;
  background: #e9cb50;
  inset: 7.5px;
  box-shadow:
    0 0 5px #333,
    inset 2px 2px 3px #f8f4e4,
    inset -2px -2px 3px #665613;
  z-index: 1;
}
#g-btn::after {
  width: 70px;
  height: 70px;
  inset: 10px;
  border-radius: 50%;
  box-shadow:
    10px 60px 0 10px #fff,
    65px 60px 0 5px #fff,
    95px 70px 0 10px #fff,
    135px 45px 0 5px #fff,
    170px 35px 0 10px #fff,
    195px -5px 0 10px #fff,
    -10px 0 0 50px rgba(255, 255, 255, .2),
    15px 0 0 50px rgba(255, 255, 255, .15),
    40px 0 0 50px rgba(255, 255, 255, .21),
    10px 40px 0 10px #abc1d9,
    70px 35px 0 10px #abc1d9,
    95px 40px 0 10px #abc1d9,
    135px 20px 0 10px #abc1d9,
    155px 15px 0 10px #abc1d9,
    190px -20px 0 10px #abc1d9;
}
#g-btn.active {
  background-position: 0 0;
}
#g-btn.active::before {
  translate: 130px;
  background:
    radial-gradient(circle at 50% 20px, #939aa5, #939aa5 6.5px, transparent 7px, transparent),
    radial-gradient(circle at 35% 45px, #939aa5, #939aa5 11.5px, transparent 12px, transparent),
    radial-gradient(circle at 72% 50px, #939aa5, #939aa5 8.5px, transparent 9px, transparent),
    radial-gradient(#cbcdda, #cbcdda);
}
#g-btn.active::after {
  transform: translate(130px);
  box-shadow:
    10px 60px 0 10px transparent,
    65px 60px 0 5px transparent,
    95px 70px 0 10px transparent,
    135px 45px 0 5px transparent,
    170px 35px 0 10px transparent,
    195px -5px 0 10px transparent,
    10px 0 0 50px rgba(255, 255, 255, .2),
    -15px 0 0 50px rgba(255, 255, 255, .15),
    -40px 0 0 50px rgba(255, 255, 255, .21),
    10px 40px 0 10px transparent,
    70px 35px 0 10px transparent,
    95px 40px 0 10px transparent,
    135px 20px 0 10px transparent,
    155px 15px 0 10px transparent,
    190px -20px 0 10px transparent;
}

/* Dark Mode 样式 */
body.dark-mode {
  background-color: #121212;
  color: #ddd;
}
body.dark-mode .album-wrapper {
  background: #222;
  box-shadow: 0 6px 20px rgba(0,0,0,0.7);
}
body.dark-mode .photo-frame {
  background: #333;
  box-shadow: 0 4px 12px rgba(0,0,0,0.6);
}
body.dark-mode .photo-frame:hover {
  box-shadow: 0 8px 24px rgba(0,0,0,0.8);
}
body.dark-mode .photo-caption {
  color: #ccc;
}
</style>

<script>
document.addEventListener('DOMContentLoaded', function() {
  // 真正的多巴胺配色 - 同色系、明亮和谐的渐变
  const dopamineGradients = [
    // 蓝色系 - 天空和海洋的渐变
    ['#E3F2FD', '#90CAF9'], // 淡蓝 -> 中蓝
    ['#BBDEFB', '#64B5F6'], // 更淡蓝 -> 亮蓝
    ['#A3D9FF', '#7AB8FF'], // 天蓝 -> 宝蓝
    
    // 绿色系 - 大自然渐变
    ['#E8F5E9', '#A5D6A7'], // 淡绿 -> 薄荷绿
    ['#C8E6C9', '#81C784'], // 浅绿 -> 草绿
    ['#DCEDC8', '#AED581'], // 嫩绿 -> 苹果绿
    
    // 紫色系 - 薰衣草渐变
    ['#F3E5F5', '#CE93D8'], // 淡紫 -> 紫丁香
    ['#E1BEE7', '#BA68C8'], // 浅紫 -> 中紫
    ['#EDE7F6', '#B39DDB'], // 薰衣草 -> 淡紫
    
    // 粉色系 - 柔和甜美渐变
    ['#FCE4EC', '#F48FB1'], // 淡粉 -> 粉红
    ['#F8BBD0', '#F06292'], // 浅粉 -> 玫瑰粉
    ['#FFEBEE', '#E91E63'], // 粉白 -> 玫红
    
    // 橙色系 - 温暖渐变
    ['#FFF3E0', '#FFCC80'], // 淡橙 -> 浅橙
    ['#FFE0B2', '#FFB74D'], // 米白 -> 橙色
    ['#FFECB3', '#FFD54F'], // 淡黄 -> 金黄
    
    // 青色系 - 清新渐变
    ['#E0F7FA', '#80DEEA'], // 淡青 -> 天青
    ['#B2EBF2', '#4DD0E1'], // 浅青 -> 青蓝
    ['#E0F2F1', '#80CBC4'], // 薄荷 -> 青绿
    
    // 黄色系 - 阳光渐变
    ['#FFFDE7', '#FFF176'], // 淡黄 -> 亮黄
    ['#FFF9C4', '#FFEE58'], // 米黄 -> 柠檬黄
    ['#FFF8E1', '#FFE082'], // 象牙白 -> 淡金黄
    
    // 红色系 - 温暖渐变
    ['#FFEBEE', '#EF9A9A'], // 淡红 -> 粉红
    ['#FFCDD2', '#E57373'], // 浅红 -> 珊瑚红
    ['#FCE4EC', '#F48FB1']  // 粉白 -> 桃红
  ];

  // 从多巴胺数组中选择颜色组合
  function getRandomDopamineGradient() {
    const randomIndex = Math.floor(Math.random() * dopamineGradients.length);
    return dopamineGradients[randomIndex];
  }

  // 设置标题颜色
  function setTitleColor() {
    const title = document.getElementById('album-title');
    if (title) {
      const [color1, color2] = getRandomDopamineGradient();
      title.style.background = `linear-gradient(135deg, ${color1}, ${color2})`;
      title.style.webkitBackgroundClip = 'text';
      title.style.webkitTextFillColor = 'transparent';
      // 添加更明显的阴影让文字更突出
      title.style.textShadow = `none`;
    }
  }

  // 设置加载按钮颜色
  function setLoadButtonColor() {
    const button = document.getElementById('load-more-btn');
    if (button) {
      const [color1, color2] = getRandomDopamineGradient();
      button.style.background = `linear-gradient(135deg, ${color1}, ${color2})`;
      
      // 对于这些柔和的颜色，总是使用深色文字确保清晰可见
      button.style.color = '#FFFFFF';
      button.style.fontWeight = '700';
      button.style.textShadow = '0 1px 3px rgba(0,0,0,0.3)';
    }
  }

  // 相册数据 - 从页面模板传递
  const allPhotos = [
    {% for photo in page.photos %}
      {
        url: "{{ photo.url }}",
        desc: "{{ photo.desc | default('') }}",
        location: "{{ photo.location | default('') }}",
        date: "{{ photo.date | default('') }}",
        index: {{ loop.index0 }}
      }{% if not loop.last %},{% endif %}
    {% endfor %}
  ];

  // 分页配置
  const photosPerPage = 12;
  let currentPage = 1;
  let totalPages = Math.ceil(allPhotos.length / photosPerPage);
  let isLoading = false;
  let lightboxInstance = null;
  let currentLightboxIndex = 0;

  // DOM 元素
  const photoWall = document.getElementById('photo-wall');
  const loadMoreBtn = document.getElementById('load-more-btn');
  const loadMoreText = document.getElementById('load-more-text');
  const loadingSpinner = document.getElementById('loading-spinner');
  const currentPageEl = document.getElementById('current-page');
  const totalPagesEl = document.getElementById('total-pages');
  const noPhotosMessage = document.getElementById('no-photos-message');
  const paginationInfo = document.getElementById('pagination-info');

  // 初始化
  function init() {
    // 设置颜色
    setTitleColor();
    setLoadButtonColor();
    
    // 更新分页信息
    currentPageEl.textContent = currentPage;
    totalPagesEl.textContent = totalPages;
    
    // 如果没有照片
    if (allPhotos.length === 0) {
      noPhotosMessage.style.display = 'block';
      loadMoreBtn.style.display = 'none';
      paginationInfo.style.display = 'none';
      return;
    }
    
    // 加载第一页
    loadPhotos();
    
    // 如果只有一页，隐藏加载更多按钮
    if (currentPage >= totalPages) {
      loadMoreBtn.style.display = 'none';
    }
    
    // 加载更多按钮点击事件
    loadMoreBtn.addEventListener('click', loadMore);
  }

  // 加载照片
  function loadPhotos() {
    const startIndex = (currentPage - 1) * photosPerPage;
    const endIndex = Math.min(startIndex + photosPerPage, allPhotos.length);
    const pagePhotos = allPhotos.slice(startIndex, endIndex);
    
    const fragment = document.createDocumentFragment();
    
    pagePhotos.forEach(photo => {
      const photoItem = createPhotoElement(photo);
      fragment.appendChild(photoItem);
    });
    
    photoWall.appendChild(fragment);
  }

  // 创建照片元素（添加位置和时间信息）
  function createPhotoElement(photo) {
    const photoItem = document.createElement('div');
    photoItem.className = 'photo-item';
    photoItem.innerHTML = `
      <div class="photo-frame" 
           data-src="${photo.url}" 
           data-index="${photo.index}" 
           data-desc="${photo.desc || ''}"
           data-location="${photo.location || ''}"
           data-date="${photo.date || ''}">
        <img src="${photo.url}" alt="${photo.desc || '照片'}" loading="lazy" class="photo-image">
        <div class="photo-zoom-icon">⤡</div>
        ${(photo.location || photo.date) ? `
        <div class="photo-info-overlay">
          ${photo.location ? `
          <div class="photo-location">
            <i class="fas fa-map-marker-alt"></i>
            <span>${photo.location}</span>
          </div>
          ` : ''}
          ${photo.date ? `
          <div class="photo-date">
            <i class="far fa-clock"></i>
            <span>${photo.date}</span>
          </div>
          ` : ''}
        </div>
        ` : ''}
      </div>
      ${photo.desc ? `<p class="photo-caption">${photo.desc}</p>` : ''}
    `;
    
    // 添加点击事件
    const photoFrame = photoItem.querySelector('.photo-frame');
    photoFrame.addEventListener('click', () => showLightbox(photo.index));
    
    return photoItem;
  }

  // 加载更多照片
  function loadMore() {
    if (isLoading || currentPage >= totalPages) return;
    
    isLoading = true;
    loadMoreBtn.disabled = true;
    loadingSpinner.style.display = 'inline-block';
    loadMoreText.textContent = '加载中...';
    
    // 模拟加载延迟
    setTimeout(() => {
      currentPage++;
      loadPhotos();
      
      // 更新分页信息
      currentPageEl.textContent = currentPage;
      
      // 如果已加载所有照片，隐藏按钮
      if (currentPage >= totalPages) {
        loadMoreBtn.style.display = 'none';
      }
      
      // 重置按钮状态
      isLoading = false;
      loadMoreBtn.disabled = false;
      loadingSpinner.style.display = 'none';
      loadMoreText.textContent = '加载更多照片';
      
      // 重新设置按钮颜色（每次点击都换颜色）
      setLoadButtonColor();
    }, 600);
  }

  // 灯箱功能（带位置和时间信息）
  function showLightbox(index) {
    const photo = allPhotos[index];
    currentLightboxIndex = index;
    
    const html = `
      <div class="lightbox-close">
        <i class="fas fa-times"></i>
      </div>
      <img src="${photo.url}" alt="${photo.desc || '照片'}" id="lightbox-img">
      <div class="lightbox-arrow lightbox-prev">&#10094;</div>
      <div class="lightbox-arrow lightbox-next">&#10095;</div>
      ${(photo.desc || photo.location || photo.date) ? `
      <div class="lightbox-info">
        ${photo.desc ? `<div class="lightbox-desc">${photo.desc}</div>` : ''}
        ${(photo.location || photo.date) ? `
        <div class="lightbox-meta">
          ${photo.location ? `<span><i class="fas fa-map-marker-alt"></i> ${photo.location}</span>` : ''}
          ${photo.date ? `<span><i class="far fa-clock"></i> ${photo.date}</span>` : ''}
        </div>
        ` : ''}
      </div>
      ` : ''}
      <div class="lightbox-index">${index + 1} / ${allPhotos.length}</div>
    `;

    lightboxInstance = basicLightbox.create(html, { 
      className: 'ultimate-lightbox',
      onShow: () => {
        document.body.style.overflow = 'hidden';
      },
      onClose: () => {
        document.body.style.overflow = '';
      }
    });
    
    lightboxInstance.show();
    
    // 添加事件监听器
    setupLightboxEvents();
  }

  // 设置灯箱事件
  function setupLightboxEvents() {
    // 关闭按钮
    document.querySelector('.lightbox-close').onclick = () => lightboxInstance.close();
    
    // 左右箭头
    document.querySelector('.lightbox-prev').onclick = () => navigateLightbox(-1);
    document.querySelector('.lightbox-next').onclick = () => navigateLightbox(1);
    
    // 键盘控制
    document.onkeydown = (e) => {
      if (e.key === 'Escape') lightboxInstance.close();
      if (e.key === 'ArrowLeft') navigateLightbox(-1);
      if (e.key === 'ArrowRight') navigateLightbox(1);
    };
    
    // 图片双击缩放
    const img = document.getElementById('lightbox-img');
    img.onclick = function() {
      this.classList.toggle('zoomed');
    };
  }

  // 灯箱导航
  function navigateLightbox(step) {
    let newIndex = (currentLightboxIndex + step + allPhotos.length) % allPhotos.length;
    
    // 关闭当前灯箱
    lightboxInstance.close();
    
    // 短暂延迟后打开新的
    setTimeout(() => {
      showLightbox(newIndex);
    }, 100);
  }

  // 拟态按钮日夜模式切换
  const btn = document.getElementById('g-btn');
  btn.addEventListener('click', () => {
    btn.classList.toggle('active');
    document.body.classList.toggle('dark-mode');
  });

  btn.addEventListener('keydown', (e) => {
    if (e.key === 'Enter' || e.key === ' ') {
      e.preventDefault();
      btn.click();
    }
  });

  // 初始化相册
  init();
});
</script>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
