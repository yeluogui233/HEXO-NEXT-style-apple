{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}{{ page.title }} | {{ title }}{% endblock %}
{% block class %}bake-page{% endblock %}

{% block content %}
  <!-- 测试用强制样式（发布后可移除） -->
  <div style="position:absolute;top:-999px;color:red;font-size:30px;">STYLE_INJECT_TEST</div>

  <div class="bake-container" style="width:100%;max-width:none;margin:0;padding:40px 5%;box-sizing:border-box;">
    <div class="bake-header" style="text-align:center;margin:0 auto 60px;max-width:1200px;">
      <h1 class="bake-title" style="font-size:3em;margin-bottom:20px;font-weight:300;color:#333;line-height:1.2;">{{ page.title }}</h1>
      {% if page.subtitle %}
        <p class="bake-subtitle" style="color:#999;font-size:1.5em;font-weight:300;">{{ page.subtitle }}</p>
      {% endif %}
    </div>

    <div class="bake-canvas" style="display:flex;flex-direction:column;gap:50px;max-width:1400px;margin:0 auto;">
      {% for post in site.posts.toArray() %}
        {% set post_tags = [] %}
        {% if post.tags %}
          {% if post.tags.data %}
            {% for tag in post.tags.data %}{% set post_tags = post_tags.concat([tag.name]) %}{% endfor %}
          {% else %}
            {% for tag in post.tags %}{% set post_tags = post_tags.concat([tag.name or tag]) %}{% endfor %}
          {% endif %}
        {% endif %}

        {% if '烘焙' in post_tags %}
          <article class="bake-column" style="width:100%;">
            <div class="bake-card" 
                 style="background:#fff;border-radius:20px;overflow:hidden;box-shadow:0 15px 30px -10px rgba(0,0,0,0.1);height:400px;position:relative;transition:all 0.4s ease;">
              <a href="{{ url_for(post.path) }}" class="bake-card-link" style="display:flex;height:100%;width:100%;text-decoration:none;color:inherit;">
                <div class="bake-card-image-wrapper" style="width:45%;height:100%;overflow:hidden;position:relative;flex-shrink:0;">
                  <img src="{{ post.thumbnail or post.banner or theme.default_banner }}" 
                       alt="{{ post.title }}" 
                       class="bake-card-image"
                       style="width:100%;height:100%;object-fit:cover;transition:transform 0.4s ease;"
                       loading="lazy">
                </div>
                <div class="bake-card-content" style="width:55%;padding:50px;display:flex;flex-direction:column;justify-content:center;box-sizing:border-box;">
                  <h2 class="bake-card-title" style="font-size:2.2em;margin-bottom:25px;color:#333;font-weight:400;line-height:1.3;">{{ post.title }}</h2>
                  <div class="bake-card-excerpt" style="color:#666;font-size:1.1em;line-height:1.8;margin-bottom:30px;">{{ post.excerpt or post.description or '' }}</div>
                  <div class="bake-card-meta" style="font-size:0.9em;color:#999;letter-spacing:0.5px;">
                    <time datetime="{{ date_xml(post.date) }}" class="bake-card-date">{{ date(post.date) }}</time>
                  </div>
                </div>
              </a>
            </div>
          </article>
        {% endif %}
      {% endfor %}
    </div>
  </div>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(true) }}
{% endblock %}

{% block head %}
  {{- super() }}
  <style>
    /* 悬浮效果 */
    .bake-canvas:hover {
      transform: translateY(-10px) scale(1.02) !important;
      box-shadow: 0 20px 40px -10px rgba(0,0,0,0.25) !important;
      z-index: 10 !important;
    }
    .bake-canvas:hover .bake-canvas-image {
      transform: scale(1.05) !important;
    }

    /* 响应式 */
    @media (max-width: 992px) {
      .bake-card {
        height: auto !important;
        flex-direction: column !important;
      }
      .bake-card-image-wrapper,
      .bake-card-content {
        width: 100% !important;
      }
      .bake-card-image-wrapper {
        height: 300px !important;
      }
      .bake-card-content {
        padding: 30px !important;
      }
      .bake-card:hover {
        transform: translateY(-5px) !important;
      }
    }
    @media (max-width: 768px) {
      .bake-container {
        padding: 30px 20px !important;
      }
      .bake-title {
        font-size: 2.2em !important;
      }
      .bake-subtitle {
        font-size: 1.2em !important;
      }
      .bake-card-content {
        padding: 25px !important;
      }
    }
  </style>
{% endblock %}
