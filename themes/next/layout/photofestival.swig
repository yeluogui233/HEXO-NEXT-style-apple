{# 动态电子相册布局文件 #}
{# 文件名: photofestival.swig #}
{# 路径: themes/next/layout/ #}

{% extends '_layout.swig' %}

{% block title %}
  {{ page.title }} | {{ config.title }}
{% endblock %}

{% block head %}
  {{ super() }}
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/viewerjs/1.11.6/viewer.min.css">
  <style>
    /* 动态电子相册样式 */
    :root {
      --primary-color: #3498db;
      --secondary-color: #e74c3c;
      --accent-color: #9b59b6;
      --dark-bg: #0f172a;
      --light-bg: rgba(255, 255, 255, 0.1);
      --text-color: #ffffff;
      --shadow-color: rgba(0, 0, 0, 0.3);
    }
    
    .photofestival-container {
      min-height: 100vh;
      background: linear-gradient(135deg, #0f2027, #203a43, #2c5364);
      padding: 20px 0;
      position: relative;
      overflow: hidden;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
    }
    
    /* 背景装饰元素 */
    .photo-bg-decorations {
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      pointer-events: none;
      z-index: 0;
    }
    
    .photo-bg-circle {
      position: absolute;
      border-radius: 50%;
      background: radial-gradient(circle, var(--accent-color), transparent);
      opacity: 0.1;
      filter: blur(20px);
    }
    
    /* 相册标题区域 */
    .photo-header {
      text-align: center;
      margin-bottom: 40px;
      padding: 20px;
      position: relative;
      z-index: 2;
    }
    
    .photo-header h1 {
      font-size: 2.8rem;
      font-weight: 800;
      background: linear-gradient(45deg, #ff7e5f, #feb47b, #86a8e7, #91eae4);
      -webkit-background-clip: text;
      -webkit-text-fill-color: transparent;
      background-clip: text;
      margin-bottom: 10px;
      text-shadow: 0 4px 6px var(--shadow-color);
    }
    
    .photo-subtitle {
      font-size: 1.2rem;
      color: rgba(255, 255, 255, 0.8);
      max-width: 600px;
      margin: 0 auto 20px;
    }
    
    /* 控制栏 */
    .photo-controls {
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 15px;
      margin-bottom: 30px;
      flex-wrap: wrap;
      position: relative;
      z-index: 3;
    }
    
    .photo-control-btn {
      background: var(--light-bg);
      border: 1px solid rgba(255, 255, 255, 0.2);
      color: var(--text-color);
      padding: 10px 20px;
      border-radius: 50px;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      gap: 8px;
      backdrop-filter: blur(10px);
    }
    
    .photo-control-btn:hover {
      background: rgba(255, 255, 255, 0.2);
      transform: translateY(-2px);
      box-shadow: 0 6px 12px var(--shadow-color);
    }
    
    .photo-control-btn.active {
      background: var(--primary-color);
      color: white;
    }
    
    /* 照片数量指示器 */
    .photo-count {
      background: var(--light-bg);
      padding: 8px 16px;
      border-radius: 20px;
      font-size: 0.9rem;
      backdrop-filter: blur(10px);
    }
    
    /* 相册容器 - 可拖动区域 */
    .photo-gallery-stage {
      width: 100%;
      height: 65vh;
      position: relative;
      overflow: hidden;
      border-radius: 20px;
      margin: 0 auto 40px;
      background: rgba(0, 0, 0, 0.2);
      backdrop-filter: blur(5px);
      border: 1px solid rgba(255, 255, 255, 0.1);
      box-shadow: 0 20px 40px rgba(0, 0, 0, 0.3);
      cursor: grab;
      user-select: none;
      touch-action: none;
    }
    
    .photo-gallery-stage:active {
      cursor: grabbing;
    }
    
    /* 单张照片样式 */
    .photo-item {
      position: absolute;
      width: 200px;
      height: 200px;
      border-radius: 10px;
      overflow: hidden;
      cursor: pointer;
      transition: transform 0.3s ease, box-shadow 0.3s ease;
      box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
      z-index: 1;
    }
    
    .photo-item:hover {
      z-index: 10;
      transform: scale(1.05);
      box-shadow: 0 15px 30px rgba(0, 0, 0, 0.4);
    }
    
    .photo-item img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      transition: transform 0.5s ease;
    }
    
    .photo-item:hover img {
      transform: scale(1.1);
    }
    
    .photo-item::after {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: linear-gradient(to bottom, transparent 60%, rgba(0, 0, 0, 0.7) 100%);
      opacity: 0;
      transition: opacity 0.3s ease;
    }
    
    .photo-item:hover::after {
      opacity: 1;
    }
    
    /* 照片标签 */
    .photo-caption {
      position: absolute;
      bottom: 10px;
      left: 0;
      width: 100%;
      text-align: center;
      color: white;
      font-size: 0.9rem;
      padding: 0 10px;
      z-index: 2;
      opacity: 0;
      transform: translateY(10px);
      transition: all 0.3s ease;
    }
    
    .photo-item:hover .photo-caption {
      opacity: 1;
      transform: translateY(0);
    }
    
    /* 操作提示 */
    .photo-instructions {
      text-align: center;
      margin-top: 20px;
      color: rgba(255, 255, 255, 0.7);
      font-size: 0.9rem;
      position: relative;
      z-index: 2;
    }
    
    .photo-instructions i {
      margin: 0 5px;
      color: var(--primary-color);
    }
    
    /* 灯箱样式 */
    .photo-lightbox {
      position: fixed;
      top: 0;
      left: 0;
      width: 100%;
      height: 100%;
      background: rgba(0, 0, 0, 0.95);
      display: none;
      justify-content: center;
      align-items: center;
      z-index: 1000;
      opacity: 0;
      transition: opacity 0.3s ease;
    }
    
    .photo-lightbox.active {
      display: flex;
      opacity: 1;
    }
    
    .lightbox-content {
      max-width: 90%;
      max-height: 90%;
      position: relative;
    }
    
    .lightbox-img {
      max-width: 100%;
      max-height: 90vh;
      border-radius: 10px;
      box-shadow: 0 20px 50px rgba(0, 0, 0, 0.5);
    }
    
    .lightbox-caption {
      color: white;
      text-align: center;
      margin-top: 20px;
      font-size: 1.2rem;
    }
    
    .lightbox-close {
      position: absolute;
      top: 20px;
      right: 20px;
      background: rgba(255, 255, 255, 0.1);
      border: none;
      color: white;
      width: 50px;
      height: 50px;
      border-radius: 50%;
      font-size: 1.5rem;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    
    .lightbox-close:hover {
      background: rgba(255, 255, 255, 0.2);
      transform: rotate(90deg);
    }
    
    .lightbox-nav {
      position: absolute;
      top: 50%;
      transform: translateY(-50%);
      background: rgba(255, 255, 255, 0.1);
      border: none;
      color: white;
      width: 60px;
      height: 60px;
      border-radius: 50%;
      font-size: 1.5rem;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      justify-content: center;
      align-items: center;
    }
    
    .lightbox-nav:hover {
      background: rgba(255, 255, 255, 0.2);
    }
    
    .lightbox-prev {
      left: 20px;
    }
    
    .lightbox-next {
      right: 20px;
    }
    
    /* 响应式设计 */
    @media (max-width: 768px) {
      .photo-header h1 {
        font-size: 2rem;
      }
      
      .photo-subtitle {
        font-size: 1rem;
      }
      
      .photo-controls {
        gap: 10px;
      }
      
      .photo-control-btn {
        padding: 8px 15px;
        font-size: 0.9rem;
      }
      
      .photo-item {
        width: 150px;
        height: 150px;
      }
      
      .lightbox-nav {
        width: 50px;
        height: 50px;
        font-size: 1.2rem;
      }
    }
    
    @media (max-width: 480px) {
      .photo-header h1 {
        font-size: 1.8rem;
      }
      
      .photo-controls {
        flex-direction: column;
      }
      
      .photo-item {
        width: 130px;
        height: 130px;
      }
    }
    
    /* 动画效果 */
    @keyframes float {
      0%, 100% { transform: translateY(0) rotate(0deg); }
      50% { transform: translateY(-10px) rotate(2deg); }
    }
    
    .photo-item {
      animation: float 6s ease-in-out infinite;
    }
    
    .photo-item:nth-child(2n) {
      animation-delay: 1s;
    }
    
    .photo-item:nth-child(3n) {
      animation-delay: 2s;
    }
    
    .photo-item:nth-child(4n) {
      animation-delay: 3s;
    }
    
    /* 加载动画 */
    .photo-loading {
      display: flex;
      justify-content: center;
      align-items: center;
      height: 200px;
      color: white;
      font-size: 1.2rem;
    }
    
    .spinner {
      width: 40px;
      height: 40px;
      border: 4px solid rgba(255, 255, 255, 0.3);
      border-top-color: var(--primary-color);
      border-radius: 50%;
      animation: spin 1s linear infinite;
      margin-right: 15px;
    }
    
    @keyframes spin {
      0% { transform: rotate(0deg); }
      100% { transform: rotate(360deg); }
    }
  </style>
{% endblock %}

{% block content %}
  <div class="photofestival-container">
    <!-- 背景装饰 -->
    <div class="photo-bg-decorations">
      {% for i in range(1, 10) %}
        <div class="photo-bg-circle" style="width: {{ 50 + i * 30 }}px; height: {{ 50 + i * 30 }}px; top: {{ i * 10 }}%; left: {{ i * 8 }}%;"></div>
      {% endfor %}
    </div>
    
    <!-- 相册标题 -->
    <div class="photo-header">
      <h1>{{ page.title }}</h1>
      {% if page.subtitle %}
        <div class="photo-subtitle">{{ page.subtitle }}</div>
      {% endif %}
    </div>
    
    <!-- 控制栏 -->
    <div class="photo-controls">
      <button class="photo-control-btn active" id="shuffleBtn">
        <i class="fas fa-random"></i> 随机排列
      </button>
      <button class="photo-control-btn" id="sortBtn">
        <i class="fas fa-sort-amount-down"></i> 按时间排序
      </button>
      <button class="photo-control-btn" id="gridBtn">
        <i class="fas fa-th-large"></i> 网格视图
      </button>
      <div class="photo-count" id="photoCount">加载照片中...</div>
    </div>
    
    <!-- 相册舞台 -->
    <div class="photo-gallery-stage" id="galleryStage">
      <div class="photo-loading" id="loadingIndicator">
        <div class="spinner"></div>
        <span>正在加载照片...</span>
      </div>
      <!-- 照片将动态插入到这里 -->
    </div>
    
    <!-- 操作提示 -->
    <div class="photo-instructions">
      <p><i class="fas fa-mouse-pointer"></i> 点击照片查看大图 | 
      <i class="fas fa-hand-point-up"></i> 触摸滑动浏览 | 
      <i class="fas fa-hand-rock"></i> 拖动拨开照片</p>
    </div>
    
    <!-- 灯箱 -->
    <div class="photo-lightbox" id="lightbox">
      <button class="lightbox-close" id="closeLightbox">
        <i class="fas fa-times"></i>
      </button>
      <button class="lightbox-nav lightbox-prev" id="prevBtn">
        <i class="fas fa-chevron-left"></i>
      </button>
      <button class="lightbox-nav lightbox-next" id="nextBtn">
        <i class="fas fa-chevron-right"></i>
      </button>
      <div class="lightbox-content">
        <img class="lightbox-img" id="lightboxImg" src="" alt="">
        <div class="lightbox-caption" id="lightboxCaption"></div>
      </div>
    </div>
  </div>
{% endblock %}

{% block scripts %}
  {{ super() }}
  <script src="https://cdnjs.cloudflare.com/ajax/libs/viewerjs/1.11.6/viewer.min.js"></script>
  <script>
    // 照片数据 - 可以通过页面变量动态注入
    const photoData = [
      {% for photo in page.photos %}
        {
          url: "{{ photo.url }}",
          caption: "{{ photo.caption or '' }}",
          date: "{{ photo.date or '' }}",
          width: {{ photo.width or 800 }},
          height: {{ photo.height or 600 }}
        },
      {% endfor %}
    ];
    
    // 如果没有照片数据，使用示例数据
    const samplePhotos = [
      { url: "https://images.unsplash.com/photo-1501854140801-50d01698950b", caption: "山间日出", date: "2023-05-10", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1441974231531-c6227db76b6e", caption: "森林小径", date: "2023-05-12", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1470071459604-3b5ec3a7fe05", caption: "山间云雾", date: "2023-05-15", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1465146344425-f00d5f5c8f07", caption: "秋日森林", date: "2023-05-18", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1439066615861-d1af74d74000", caption: "湖边日落", date: "2023-05-20", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1475924156734-496f6cac6ec1", caption: "海浪拍岸", date: "2023-05-22", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1507525428034-b723cf961d3e", caption: "热带海滩", date: "2023-05-25", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1518837695005-2083093ee35b", caption: "城市夜景", date: "2023-05-28", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1493246507139-91e8fad9978e", caption: "雪山之巅", date: "2023-06-01", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1418065460487-3e41a6c84dc5", caption: "热带雨林", date: "2023-06-05", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1476820865390-c52aeebb9891", caption: "沙漠日落", date: "2023-06-10", width: 800, height: 600 },
      { url: "https://images.unsplash.com/photo-1519681393784-d120267933ba", caption: "星空银河", date: "2023-06-15", width: 800, height: 600 }
    ];
    
    // 使用页面数据或示例数据
    const photos = photoData.length > 0 ? photoData : samplePhotos;
    
    // 全局变量
    let currentPhotos = [];
    let currentIndex = 0;
    let isDragging = false;
    let startX, startY;
    let offsetX = 0, offsetY = 0;
    let zoom = 1;
    let currentMode = 'shuffle';
    
    // DOM元素
    const galleryStage = document.getElementById('galleryStage');
    const loadingIndicator = document.getElementById('loadingIndicator');
    const photoCount = document.getElementById('photoCount');
    const lightbox = document.getElementById('lightbox');
    const lightboxImg = document.getElementById('lightboxImg');
    const lightboxCaption = document.getElementById('lightboxCaption');
    const closeLightbox = document.getElementById('closeLightbox');
    const prevBtn = document.getElementById('prevBtn');
    const nextBtn = document.getElementById('nextBtn');
    const shuffleBtn = document.getElementById('shuffleBtn');
    const sortBtn = document.getElementById('sortBtn');
    const gridBtn = document.getElementById('gridBtn');
    
    // 初始化相册
    function initGallery() {
      loadingIndicator.style.display = 'flex';
      photoCount.textContent = `共 ${photos.length} 张照片`;
      
      // 清空舞台
      galleryStage.innerHTML = '';
      galleryStage.appendChild(loadingIndicator);
      
      // 创建照片元素
      currentPhotos = [...photos];
      
      // 根据当前模式排列照片
      if (currentMode === 'sort') {
        currentPhotos.sort((a, b) => new Date(b.date) - new Date(a.date));
      } else if (currentMode === 'grid') {
        arrangeGrid();
        return;
      }
      
      // 随机排列
      if (currentMode === 'shuffle') {
        shuffleArray(currentPhotos);
      }
      
      // 添加照片到舞台
      setTimeout(() => {
        loadingIndicator.style.display = 'none';
        
        currentPhotos.forEach((photo, index) => {
          const photoItem = createPhotoElement(photo, index);
          galleryStage.appendChild(photoItem);
        });
        
        // 随机位置
        arrangeRandom();
        
        // 添加拖拽事件
        initDragAndDrop();
      }, 800);
    }
    
    // 创建照片元素
    function createPhotoElement(photo, index) {
      const div = document.createElement('div');
      div.className = 'photo-item';
      div.dataset.index = index;
      
      // 随机初始旋转
      const rotation = (Math.random() * 20) - 10;
      div.style.transform = `rotate(${rotation}deg)`;
      
      // 图片
      const img = document.createElement('img');
      img.src = photo.url;
      img.alt = photo.caption;
      img.loading = 'lazy';
      
      // 图片加载完成时添加动画
      img.onload = function() {
        div.style.opacity = '1';
      };
      
      // 标题
      const caption = document.createElement('div');
      caption.className = 'photo-caption';
      caption.textContent = photo.caption;
      
      div.appendChild(img);
      div.appendChild(caption);
      
      // 点击事件 - 打开灯箱
      div.addEventListener('click', (e) => {
        e.stopPropagation();
        openLightbox(index);
      });
      
      return div;
    }
    
    // 随机排列照片
    function arrangeRandom() {
      const items = document.querySelectorAll('.photo-item');
      const stageWidth = galleryStage.offsetWidth;
      const stageHeight = galleryStage.offsetHeight;
      
      items.forEach((item, index) => {
        // 随机位置
        const x = Math.random() * (stageWidth - 250);
        const y = Math.random() * (stageHeight - 250);
        
        // 随机旋转
        const rotation = (Math.random() * 20) - 10;
        
        // 随机缩放
        const scale = 0.8 + Math.random() * 0.4;
        
        item.style.left = `${x}px`;
        item.style.top = `${y}px`;
        item.style.transform = `rotate(${rotation}deg) scale(${scale})`;
        item.style.opacity = '0';
        
        // 延迟显示，创建交错效果
        setTimeout(() => {
          item.style.transition = 'opacity 0.5s ease, transform 0.5s ease';
          item.style.opacity = '1';
        }, index * 100);
      });
    }
    
    // 网格排列
    function arrangeGrid() {
      loadingIndicator.style.display = 'none';
      
      const items = document.querySelectorAll('.photo-item');
      const stageWidth = galleryStage.offsetWidth;
      
      // 计算每行可以放多少照片
      const itemWidth = 200;
      const gap = 20;
      const itemsPerRow = Math.floor((stageWidth - gap) / (itemWidth + gap));
      
      items.forEach((item, index) => {
        const row = Math.floor(index / itemsPerRow);
        const col = index % itemsPerRow;
        
        const x = col * (itemWidth + gap);
        const y = row * (itemWidth + gap);
        
        item.style.left = `${x}px`;
        item.style.top = `${y}px`;
        item.style.transform = 'rotate(0deg) scale(1)';
        item.style.transition = 'all 0.5s ease';
        item.style.opacity = '1';
      });
      
      // 更新舞台高度以适应网格
      const rows = Math.ceil(items.length / itemsPerRow);
      galleryStage.style.height = `${rows * (itemWidth + gap) + 100}px`;
    }
    
    // 初始化拖拽功能
    function initDragAndDrop() {
      galleryStage.addEventListener('mousedown', startDrag);
      galleryStage.addEventListener('touchstart', startDragTouch);
      galleryStage.addEventListener('wheel', handleZoom);
      
      // 鼠标事件
      document.addEventListener('mousemove', drag);
      document.addEventListener('mouseup', endDrag);
      
      // 触摸事件
      document.addEventListener('touchmove', dragTouch);
      document.addEventListener('touchend', endDrag);
    }
    
    function startDrag(e) {
      isDragging = true;
      startX = e.clientX - offsetX;
      startY = e.clientY - offsetY;
      galleryStage.style.cursor = 'grabbing';
    }
    
    function startDragTouch(e) {
      if (e.touches.length === 1) {
        isDragging = true;
        startX = e.touches[0].clientX - offsetX;
        startY = e.touches[0].clientY - offsetY;
        e.preventDefault();
      }
    }
    
    function drag(e) {
      if (!isDragging) return;
      
      offsetX = e.clientX - startX;
      offsetY = e.clientY - startY;
      
      updatePhotoPositions();
    }
    
    function dragTouch(e) {
      if (!isDragging || e.touches.length !== 1) return;
      
      offsetX = e.touches[0].clientX - startX;
      offsetY = e.touches[0].clientY - startY;
      
      updatePhotoPositions();
      e.preventDefault();
    }
    
    function endDrag() {
      isDragging = false;
      galleryStage.style.cursor = 'grab';
    }
    
    function updatePhotoPositions() {
      const items = document.querySelectorAll('.photo-item');
      items.forEach(item => {
        const originalX = parseFloat(item.style.left || 0);
        const originalY = parseFloat(item.style.top || 0);
        
        item.style.left = `${originalX + offsetX * 0.02}px`;
        item.style.top = `${originalY + offsetY * 0.02}px`;
      });
      
      // 重置偏移量
      offsetX = 0;
      offsetY = 0;
    }
    
    function handleZoom(e) {
      e.preventDefault();
      
      // 根据滚轮方向调整缩放
      const delta = e.deltaY > 0 ? -0.1 : 0.1;
      zoom = Math.max(0.5, Math.min(2, zoom + delta));
      
      // 应用缩放
      const items = document.querySelectorAll('.photo-item');
      items.forEach(item => {
        const currentTransform = item.style.transform;
        const scaleMatch = currentTransform.match(/scale\(([^)]+)\)/);
        const currentScale = scaleMatch ? parseFloat(scaleMatch[1]) : 1;
        
        // 保持旋转角度，只改变缩放
        const rotationMatch = currentTransform.match(/rotate\(([^)]+)\)/);
        const rotation = rotationMatch ? rotationMatch[1] : '0deg';
        
        item.style.transform = `rotate(${rotation}) scale(${currentScale * (1 + delta * 0.5)})`;
      });
    }
    
    // 灯箱功能
    function openLightbox(index) {
      currentIndex = parseInt(index);
      updateLightbox();
      lightbox.classList.add('active');
      document.body.style.overflow = 'hidden';
    }
    
    function closeLightboxFunc() {
      lightbox.classList.remove('active');
      document.body.style.overflow = 'auto';
    }
    
    function updateLightbox() {
      const photo = currentPhotos[currentIndex];
      lightboxImg.src = photo.url;
      lightboxCaption.textContent = photo.caption || `照片 ${currentIndex + 1}`;
    }
    
    function prevPhoto() {
      currentIndex = (currentIndex - 1 + currentPhotos.length) % currentPhotos.length;
      updateLightbox();
    }
    
    function nextPhoto() {
      currentIndex = (currentIndex + 1) % currentPhotos.length;
      updateLightbox();
    }
    
    // 工具函数
    function shuffleArray(array) {
      for (let i = array.length - 1; i > 0; i--) {
        const j = Math.floor(Math.random() * (i + 1));
        [array[i], array[j]] = [array[j], array[i]];
      }
      return array;
    }
    
    // 切换模式
    function setMode(mode) {
      currentMode = mode;
      
      // 更新按钮状态
      [shuffleBtn, sortBtn, gridBtn].forEach(btn => btn.classList.remove('active'));
      
      if (mode === 'shuffle') {
        shuffleBtn.classList.add('active');
      } else if (mode === 'sort') {
        sortBtn.classList.add('active');
      } else if (mode === 'grid') {
        gridBtn.classList.add('active');
      }
      
      initGallery();
    }
    
    // 事件监听
    shuffleBtn.addEventListener('click', () => setMode('shuffle'));
    sortBtn.addEventListener('click', () => setMode('sort'));
    gridBtn.addEventListener('click', () => setMode('grid'));
    
    closeLightbox.addEventListener('click', closeLightboxFunc);
    prevBtn.addEventListener('click', prevPhoto);
    nextBtn.addEventListener('click', nextPhoto);
    
    // 键盘导航
    document.addEventListener('keydown', (e) => {
      if (!lightbox.classList.contains('active')) return;
      
      if (e.key === 'Escape') {
        closeLightboxFunc();
      } else if (e.key === 'ArrowLeft') {
        prevPhoto();
      } else if (e.key === 'ArrowRight') {
        nextPhoto();
      }
    });
    
    // 点击灯箱背景关闭
    lightbox.addEventListener('click', (e) => {
      if (e.target === lightbox) {
        closeLightboxFunc();
      }
    });
    
    // 初始化
    document.addEventListener('DOMContentLoaded', () => {
      initGallery();
      
      // 创建背景装饰
      const bgContainer = document.querySelector('.photo-bg-decorations');
      for (let i = 0; i < 15; i++) {
        const circle = document.createElement('div');
        circle.className = 'photo-bg-circle';
        const size = 30 + Math.random() * 100;
        circle.style.width = `${size}px`;
        circle.style.height = `${size}px`;
        circle.style.top = `${Math.random() * 100}%`;
        circle.style.left = `${Math.random() * 100}%`;
        circle.style.animationDelay = `${Math.random() * 5}s`;
        bgContainer.appendChild(circle);
      }
    });
    
    // 窗口大小变化时重新排列
    window.addEventListener('resize', () => {
      if (currentMode === 'grid') {
        arrangeGrid();
      }
    });
  </script>
{% endblock %}