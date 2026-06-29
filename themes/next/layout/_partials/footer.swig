{%- set current_year = date(null, 'YYYY') -%}

<!-- Footer -->
<div class="footer-wrapper" style="text-align:center; font-size:14px; color:#222; max-width:900px; margin:auto; padding:20px 0;">

  <!-- 第一行：版权 + 总字数 + 阅读时间 -->
  <div class="footer-line footer-line-1" style="display:flex; justify-content:center; align-items:center; gap:12px; flex-wrap:wrap;">
    <span>© {{ current_year }} <span style="color:#e25555;">&#10084;</span> {{ config.author }}</span>

    <i class="fa-solid fa-file-lines" style="color:#000;"></i>
    <span>总字数: <span id="local_word_count">0</span></span>

    <i class="fa-regular fa-clock" style="color:#000;"></i>
    <span>预计阅读时间: <span id="local_read_time">0</span> 分钟</span>
  </div>

  <!-- 第二行：驱动信息 -->
  <div class="footer-line footer-line-2" style="margin-top:10px; color:#555; font-size:13px;">
    由 
    <a href="https://hexo.io" target="_blank" rel="noopener" style="color:#555; text-decoration:none; font-weight:600;">Hexo</a>
    &amp;
    <a href="https://theme-next.org/" target="_blank" rel="noopener" style="color:#555; text-decoration:none; font-weight:600;">NexT.Gemini</a>
    强力驱动
  </div>

  <!-- 第三行：访客数 | 浏览量 -->
  <div class="footer-line footer-line-3" style="margin-top:15px; display:flex; justify-content:center; gap:30px; font-size:14px; color:#222;">
    <div style="display:flex; align-items:center; gap:6px;">
      <i class="fa-regular fa-eye" style="color:#000; font-size:18px;"></i>
      <span>访客数 <span id="local_uv_count">0</span></span>
    </div>
    <div style="display:flex; align-items:center; gap:6px;">
      <i class="fa-solid fa-user" style="color:#000; font-size:18px;"></i>
      <span>浏览量 <span id="local_pv_count">0</span></span>
    </div>
  </div>

</div>

<!-- 本地统计脚本 -->
<script>
(function() {
  const pvKey = 'local_pv_count';
  const uvKey = 'local_uv_count';
  const uvFlagKey = 'local_uv_flag';

  let pvCount = parseInt(localStorage.getItem(pvKey)) || 0;
  let uvCount = parseInt(localStorage.getItem(uvKey)) || 0;

  // PV 每次访问+1
  pvCount++;
  localStorage.setItem(pvKey, pvCount);

  // UV 仅第一次访问+1
  if (!localStorage.getItem(uvFlagKey)) {
    uvCount++;
    localStorage.setItem(uvKey, uvCount);
    localStorage.setItem(uvFlagKey, 'true');
  }

  document.addEventListener('DOMContentLoaded', () => {
    document.getElementById('local_pv_count').textContent = pvCount.toLocaleString();
    document.getElementById('local_uv_count').textContent = uvCount.toLocaleString();

    const content = document.querySelector('.main-inner');
    const text = content ? (content.innerText || content.textContent) : '';
    const length = text.trim().length;

    document.getElementById('local_word_count').textContent = length.toLocaleString();
    document.getElementById('local_read_time').textContent = Math.ceil(length / 200);
  });
})();
</script>

<!-- 确保在 head 里引入 Font Awesome -->
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.2/css/all.min.css">
