<!-- 标签云 -->
<div class="tag-cloud-section">
  <div class="tag-cloud-tags">
    {% for tag in site.tags.toArray() %}
      <a href="{{ url_for(tag.path) }}" class="tag-cloud-link">
        {{ tag.name }}
        <span class="tag-link-count">({{ tag.length }})</span>
      </a>
    {% endfor %}
  </div>
</div>

<style>
  .tag-cloud-section {
    background: rgba(255, 255, 255, 0.8);
    backdrop-filter: blur(15px);
    border-radius: 16px;
    padding: 25px;
    margin: 30px 0;
    box-shadow: 0 8px 25px rgba(0, 0, 0, 0.08);
    border: 1px solid rgba(255, 255, 255, 0.6);
  }

  .tag-cloud-tags {
    text-align: center;
    position: relative;
  }

  .tag-cloud-link {
    position: relative;
    border-radius: 6px;
    padding: 4px 12px;
    margin: 10px 8px;
    display: inline-block;
    font-weight: 600;
    text-shadow: 0 1px 1px rgba(0,0,0,0.1);
    border: 1px solid rgba(0,0,0,0.05);
    transition: all 0.3s ease;
    text-decoration: none;
    color: inherit;
  }

  /* 模糊阴影伪元素 */
  .tag-cloud-link::after {
    content: '';
    position: absolute;
    top: 10px;
    left: 0;
    right: 0;
    height: 100%;
    background: inherit;
    filter: blur(8px);
    opacity: 0.7;
    z-index: -1;
    transition: all 0.3s ease;
  }

  /* 悬停时放大阴影 */
  .tag-cloud-link:hover {
    transform: translateY(-2px) scale(1.05);
    text-decoration: none;
    color: inherit;
  }
  
  .tag-cloud-link:hover::after {
    transform: scale(0.95);
    opacity: 0.9;
    filter: blur(12px);
  }

  .tag-link-count {
    font-size: 0.85em;
    opacity: 0.8;
    margin-left: 2px;
  }
</style>