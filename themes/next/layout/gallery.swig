{% extends '_layout.swig' %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}
  {{ page.window_title or page.title }} | {{ config.title }}
{% endblock %}

{% block content %}
  <header class="page-header" style="text-align:center; margin-bottom: 40px;">
    <h1 class="page-title">{{ page.title }}</h1>
    {% if page.subtitle %}
      <p class="page-subtitle" style="color:var(--text-color-secondary); margin-top:8px;">
        {{ page.subtitle }}
      </p>
    {% endif %}
  </header>

  <div class="album-wrapper">
    <div class="album-grid">
      {% for album in page.albums %}
        <div class="album-card">
          <a href="{{ url_for(album.path) }}">
            <div class="album-thumb">
              <img src="{{ album.cover }}" alt="{{ album.name }}" loading="lazy">
              <div class="album-info">
                <h3 class="album-title">{{ album.name }}</h3>
                {% if album.desc %}
                  <p class="album-desc">{{ album.desc }}</p>
                {% endif %}
              </div>
            </div>
          </a>
        </div>
      {% endfor %}
    </div>
  </div>

  <style>
    .album-wrapper {
      background: #fff;
      border-radius: 14px;
      padding: 30px 20px;
      box-shadow: 0 4px 16px rgba(0,0,0,0.05);
      margin-bottom: 40px;
    }
    .album-grid {
      display: grid;
      grid-template-columns: repeat(3, 220px);
      justify-content: center;
      gap: 20px;
    }
    .album-card {
      width: 220px;
      height: 160px;
      border-radius: 14px;
      overflow: hidden;
      box-shadow: 0 4px 12px rgba(0,0,0,0.1);
      transition: transform 0.25s ease, box-shadow 0.25s ease;
    }
    .album-card:hover {
      transform: translateY(-4px);
      box-shadow: 0 8px 20px rgba(0,0,0,0.15);
    }
    .album-thumb {
      position: relative;
      width: 100%;
      height: 100%;
    }
    .album-thumb img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
    }
    .album-info {
      position: absolute;
      bottom: 0;
      width: 100%;
      padding: 6px 10px;
      background: rgba(255,255,255,0.25);
      backdrop-filter: blur(8px);
      color: #fff;
      text-align: center;
      box-sizing: border-box;
    }
    .album-title {
      font-weight: 600;
      font-size: 0.9rem;
      margin: 0;
      line-height: 1.2;
    }
    .album-desc {
      font-size: 0.75rem;
      margin: 2px 0 0;
      line-height: 1.2;
      color: #f0f0f0;
      overflow: hidden;
      text-overflow: ellipsis;
      white-space: nowrap;
    }
    @media (max-width: 992px) {
      .album-grid {
        grid-template-columns: repeat(2, 220px);
      }
    }
    @media (max-width: 640px) {
      .album-grid {
        grid-template-columns: repeat(1, 220px);
      }
    }
  </style>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}
