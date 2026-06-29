<!-- 标签柱状图组件 -->
<div class="tag-chart-container">
  <div class="tag-chart-header">
    <h3 class="tag-chart-title">标签分布统计</h3>
    <p class="tag-chart-subtitle">按文章数量排序</p>
  </div>
  <div class="tag-chart-wrapper">
    <div class="tag-chart-bars" id="tagChartBars"></div>
    <div class="tag-chart-legend" id="tagChartLegend"></div>
  </div>
</div>

<style>
.tag-chart-container {
  background: rgba(255,255,255,0.85);
  backdrop-filter: blur(15px);
  border-radius:16px;
  padding:25px;
  margin:30px 0;
  box-shadow:0 8px 25px rgba(0,0,0,0.08);
  border:1px solid rgba(255,255,255,0.6);
}
.tag-chart-header { text-align:center; margin-bottom:25px; }
.tag-chart-title { font-size:1.4em; font-weight:600; color:#2c3e50; margin-bottom:5px; }
.tag-chart-subtitle { font-size:0.9em; color:#7f8c8d; margin:0; }
.tag-chart-wrapper { display:flex; flex-direction:column; gap:20px; }

/* 修改容器布局 */
.tag-chart-bars {
  display:flex;
  align-items:flex-end;
  justify-content: space-around; /* 关键：让柱子均匀分布 */
  padding:20px 10px;
  border-bottom:1px solid #eaeaea;
  position:relative;
  min-height: 220px; /* 确保足够高度 */
  width: 100%;
  box-sizing: border-box;
}

.tag-bar-item {
  display:flex;
  flex-direction:column;
  align-items:center;
  width: 60px; /* 增加宽度 */
  flex: 1; /* 关键：让每个项目弹性扩展 */
  min-width: 45px;
  max-width: 80px;
  position:relative;
  cursor:pointer;
  transition:all 0.3s ease;
  -webkit-tap-highlight-color: transparent; /* 移除点击高亮 */
  user-select: none; /* 禁止文字选择 */
}

.tag-bar {
  width: 40px; /* 固定柱子宽度 */
  min-height: 10px;
  border-radius:8px 8px 0 0;
  position:relative;
  box-shadow:0 2px 8px rgba(0,0,0,0.15);
  transition:all 0.4s cubic-bezier(0.25,0.46,0.45,0.94);
  display:flex;
  justify-content:center;
  align-items:flex-start;
  animation: barGrowth 0.6s ease-out forwards;
}

.tag-bar:hover {
  transform:translateY(-5px);
  box-shadow:0 6px 20px rgba(0,0,0,0.25);
  filter: brightness(1.15);
}

.tag-bar-value {
  position:absolute;
  top:-28px;
  left:50%;
  transform:translateX(-50%);
  background: rgba(0,0,0,0.8);
  color:white;
  padding:3px 8px;
  border-radius:12px;
  font-size:0.75em;
  font-weight:600;
  opacity:0;
  transition:opacity 0.3s ease;
  white-space:nowrap;
  z-index: 10;
}
.tag-bar:hover .tag-bar-value { opacity:1; }

.tag-bar-label {
  margin-top:8px;
  font-size:0.8em;
  font-weight:500;
  color:#2c3e50;
  text-align:center;
  line-height:1.2;
  max-width:100%;
  overflow:hidden;
  text-overflow:ellipsis;
  white-space:nowrap;
  padding: 2px 0;
}

.tag-chart-legend {
  display:flex;
  flex-wrap:wrap;
  gap:10px;
  justify-content:center;
  padding:15px;
  background: rgba(248,249,250,0.7);
  border-radius:12px;
}
.tag-legend-item {
  display:flex;
  align-items:center;
  gap:6px;
  padding:5px 10px;
  background:white;
  border-radius:20px;
  box-shadow:0 2px 6px rgba(0,0,0,0.08);
  font-size:0.8em;
  cursor:pointer;
  transition:all 0.3s ease;
  text-decoration:none;
  color:inherit;
}
.tag-legend-item:hover {
  transform:translateY(-2px);
  box-shadow:0 4px 10px rgba(0,0,0,0.12);
}
.tag-legend-color { width:12px; height:12px; border-radius:50%; flex-shrink:0; }
.tag-legend-name { font-weight:500; color:#2c3e50; }
.tag-legend-count { color:#7f8c8d; font-size:0.85em; }

/* 新的动画 - 不使用自定义属性 */
@keyframes barGrowth { 
  from { 
    height: 10px; 
    opacity: 0.3; 
  } 
  to { 
    opacity: 1; 
  } 
}

/* 滑动提示动画 */
@keyframes slideHint {
  0%, 100% { opacity: 0.6; }
  50% { opacity: 1; }
}

/* 平板设备 */
@media(max-width: 768px){
  .tag-chart-container {
    padding: 20px;
    margin: 25px 0;
  }
  
  /* 手机端改为水平滚动布局 */
  .tag-chart-bars {
    display: flex;
    align-items: flex-end;
    overflow-x: auto; /* 允许水平滚动 */
    overflow-y: hidden;
    justify-content: flex-start; /* 从左开始排列 */
    padding: 20px 15px 25px;
    min-height: 200px;
    width: 100%;
    scroll-behavior: smooth;
    -webkit-overflow-scrolling: touch; /* iOS平滑滚动 */
    
    /* 隐藏滚动条但保持可滚动 */
    scrollbar-width: none;
    -ms-overflow-style: none;
  }
  
  .tag-chart-bars::-webkit-scrollbar {
    display: none; /* Chrome/Safari隐藏滚动条 */
  }
  
  /* 添加右侧渐变遮罩，提示可滑动 */
  .tag-chart-bars:after {
    content: '';
    position: absolute;
    right: 0;
    top: 0;
    width: 40px;
    height: 100%;
    background: linear-gradient(to right, transparent, rgba(255,255,255,0.9));
    pointer-events: none;
  }
  
  .tag-bar-item {
    flex: 0 0 auto; /* 禁止伸缩，保持原始宽度 */
    width: 65px; /* 保持足够宽度便于触摸 */
    margin-right: 12px; /* 柱子间距 */
    min-width: 55px;
    max-width: none; /* 移除最大宽度限制 */
  }
  
  .tag-bar {
    width: 50px; /* 保持较宽易点击 */
    touch-action: pan-y; /* 优化触摸滚动 */
  }
  
  /* 最后一个柱子右边距 */
  .tag-bar-item:last-child {
    margin-right: 50px; /* 给滚动留出空间 */
  }
  
  .tag-bar-label {
    font-size: 0.75em;
    max-width: 65px;
  }
  
  /* 添加滑动提示 */
  .tag-chart-wrapper {
    position: relative;
  }
  
  .tag-chart-wrapper:before {
    content: '← 滑动查看 →';
    position: absolute;
    bottom: 8px;
    left: 50%;
    transform: translateX(-50%);
    font-size: 0.75em;
    color: #7f8c8d;
    background: rgba(255,255,255,0.9);
    padding: 5px 15px;
    border-radius: 20px;
    box-shadow: 0 2px 10px rgba(0,0,0,0.1);
    white-space: nowrap;
    z-index: 5;
    animation: slideHint 2s ease-in-out infinite;
    pointer-events: none;
  }
}

/* 手机设备 */
@media(max-width: 480px){
  .tag-chart-container {
    padding: 15px;
    margin: 20px 0;
    border-radius: 12px;
  }
  
  .tag-chart-header {
    margin-bottom: 20px;
  }
  
  .tag-chart-title {
    font-size: 1.2em;
  }
  
  .tag-chart-bars {
    min-height: 180px;
    padding: 15px 15px 30px;
  }
  
  /* 移除平板端的渐变遮罩 */
  .tag-chart-bars:after {
    display: none;
  }
  
  .tag-bar-item {
    width: 55px;
    margin-right: 10px;
    min-width: 50px;
  }
  
  .tag-bar {
    width: 42px;
  }
  
  .tag-bar-item:last-child {
    margin-right: 40px;
  }
  
  .tag-bar-label {
    font-size: 0.7em;
    max-width: 55px;
  }
  
  /* 调整滑动提示位置 */
  .tag-chart-wrapper:before {
    bottom: 5px;
    font-size: 0.7em;
    padding: 4px 12px;
  }
  
  /* 图例优化 */
  .tag-chart-legend {
    gap: 8px;
    padding: 12px;
  }
  
  .tag-legend-item {
    font-size: 0.75em;
    padding: 4px 8px;
  }
}

/* 小屏手机 */
@media(max-width: 360px){
  .tag-chart-bars {
    min-height: 160px;
    padding: 12px 12px 28px;
  }
  
  .tag-bar-item {
    width: 50px;
    margin-right: 8px;
    min-width: 45px;
  }
  
  .tag-bar {
    width: 38px;
  }
  
  .tag-bar-item:last-child {
    margin-right: 30px;
  }
  
  .tag-chart-wrapper:before {
    font-size: 0.65em;
    padding: 3px 10px;
    bottom: 3px;
  }
}

/* 隐藏 Hexo标签页文章数 (1) */
.post-meta .post-tag-count { display:none !important; }
</style>

<script>
document.addEventListener('DOMContentLoaded', function(){
    const tagLinks = document.querySelectorAll('.tag-cloud-tags a');
    if(!tagLinks.length) {
        console.log('未找到标签链接');
        return;
    }

    const tagData = Array.from(tagLinks).map((link,index)=>{
        const text = link.textContent.trim();
        
        console.log('原始文本:', text);
        
        // 解析标签文本，处理格式如 "JavaScript (10)" 或 "JavaScript"
        const match = text.match(/^(.*?)\s*\((\d+)\)$/);
        
        let tagName, tagCount;
        if (match) {
            tagName = match[1].trim();
            tagCount = parseInt(match[2]);
            console.log('解析成功:', tagName, tagCount);
        } else {
            tagName = text;
            tagCount = 1;
            console.log('未找到数字，使用默认:', tagName, tagCount);
        }
        
        const tagColor = randomColor(index);
        const tagUrl = link.href;
        return {name:tagName, count:tagCount, color:tagColor, url:tagUrl};
    });

    console.log('所有标签数据:', tagData);
    
    // 按文章数排序
    tagData.sort((a,b)=>b.count-a.count);
    const displayTags = tagData.slice(0, Math.min(tagData.length, 12)); // 最多显示12个
    
    console.log('显示的前12个标签:', displayTags);

    const chartBars = document.getElementById('tagChartBars');
    const chartLegend = document.getElementById('tagChartLegend');
    chartBars.innerHTML=''; 
    chartLegend.innerHTML='';

    if(displayTags.length === 0) {
        chartBars.innerHTML = '<div style="text-align:center;color:#666;padding:40px;">暂无标签数据</div>';
        return;
    }

    const maxCount = Math.max(...displayTags.map(t=>t.count));
    const maxHeight = 180; // 最大高度
    
    console.log('最大文章数:', maxCount);
    console.log('最大高度:', maxHeight);

    displayTags.forEach((tag,index)=>{
        // 计算高度比例，确保最小高度为20px
        const barHeight = Math.max(20, (tag.count/maxCount)*maxHeight);
        
        console.log(`标签"${tag.name}": 数量=${tag.count}, 计算高度=${barHeight}px`);
        
        const barItem = document.createElement('div');
        barItem.className='tag-bar-item';
        
        // 创建柱子并直接设置高度
        const barDiv = document.createElement('div');
        barDiv.className = 'tag-bar';
        barDiv.style.background = `linear-gradient(135deg, ${tag.color}, ${lightenColor(tag.color,30)})`;
        barDiv.style.height = barHeight + 'px';
        
        // 添加数值显示
        const barValue = document.createElement('span');
        barValue.className = 'tag-bar-value';
        barValue.textContent = tag.count;
        barDiv.appendChild(barValue);
        
        // 创建标签文本
        const barLabel = document.createElement('div');
        barLabel.className = 'tag-bar-label';
        barLabel.textContent = tag.name;
        
        // 组装
        barItem.appendChild(barDiv);
        barItem.appendChild(barLabel);
        
        barItem.addEventListener('click',()=>{ 
            window.location.href=tag.url; 
        });
        chartBars.appendChild(barItem);

        // 创建图例
        const legendItem = document.createElement('a');
        legendItem.className='tag-legend-item';
        legendItem.href=tag.url;
        legendItem.innerHTML=`
            <div class="tag-legend-color" style="background-color:${tag.color}"></div>
            <span class="tag-legend-name">${tag.name}</span>
            <span class="tag-legend-count">${tag.count}</span>
        `;
        chartLegend.appendChild(legendItem);
    });
    
    // 添加移动端触摸滚动优化
    if (window.innerWidth <= 768) {
        const chartBarsElement = document.getElementById('tagChartBars');
        
        // 添加自动滚动（只滚到中间，让用户自己决定看哪边）
        setTimeout(() => {
            if (chartBarsElement.scrollWidth > chartBarsElement.clientWidth) {
                // 有滚动空间，滚动到1/4位置
                chartBarsElement.scrollLeft = chartBarsElement.scrollWidth * 0.25;
            }
        }, 500);
        
        // 添加触摸拖动指示
        let isDragging = false;
        let startX, scrollLeft;
        
        const startDrag = (e) => {
            isDragging = true;
            chartBarsElement.classList.add('dragging');
            startX = e.pageX || e.touches[0].pageX;
            scrollLeft = chartBarsElement.scrollLeft;
        };
        
        const endDrag = () => {
            isDragging = false;
            chartBarsElement.classList.remove('dragging');
        };
        
        const drag = (e) => {
            if (!isDragging) return;
            e.preventDefault();
            const x = e.pageX || e.touches[0].pageX;
            const walk = (x - startX) * 1.5; // 增加拖动灵敏度
            chartBarsElement.scrollLeft = scrollLeft - walk;
        };
        
        // 鼠标事件
        chartBarsElement.addEventListener('mousedown', startDrag);
        document.addEventListener('mouseup', endDrag);
        document.addEventListener('mousemove', drag);
        
        // 触摸事件
        chartBarsElement.addEventListener('touchstart', startDrag);
        document.addEventListener('touchend', endDrag);
        document.addEventListener('touchmove', drag);
    }

    function randomColor(index){
        const colors = ['#FF6B6B','#FFD93D','#6BCB77','#4D96FF','#FF6EC7','#FFA500','#9D4EDD','#00D2FF'];
        return colors[index%colors.length];
    }
    
    function lightenColor(color,percent){
        const f=color.replace('#','');
        const t=percent/100;
        const R=parseInt(f.substring(0,2),16), 
              G=parseInt(f.substring(2,4),16), 
              B=parseInt(f.substring(4,6),16);
        const r=Math.min(255,Math.round(R+(255-R)*t));
        const g=Math.min(255,Math.round(G+(255-G)*t));
        const b=Math.min(255,Math.round(B+(255-B)*t));
        return `rgb(${r},${g},${b})`;
    }
});
</script>