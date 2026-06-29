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

  <div class="lab-wrapper">
    <div class="lab-grid">
      {% for project in page.projects %}
        <div class="project-card">
          <a href="{{ url_for(project.path) }}">
            <div class="project-thumb">
              {% if project.cover %}
                <img src="{{ project.cover }}" alt="{{ project.name }}" loading="lazy">
              {% else %}
                <div class="project-default-cover" style="background: {{ project.bg_color or '#4f6df5' }};">
                  <i class="fa {{ project.icon or 'fa-flask' }}"></i>
                </div>
              {% endif %}
              <div class="project-overlay">
                <div class="project-info">
                  <h3 class="project-title">{{ project.name }}</h3>
                  {% if project.desc %}
                    <p class="project-desc">{{ project.desc }}</p>
                  {% endif %}
                  <div class="project-meta">
                    <span class="project-date">{{ project.date }}</span>
                    <span class="project-tags">
                      {% for tag in project.tags %}
                        <span class="project-tag">{{ tag }}</span>
                      {% endfor %}
                    </span>
                  </div>
                </div>
              </div>
            </div>
          </a>
        </div>
      {% endfor %}
    </div>
  </div>

  <style>
    .lab-wrapper {
      background: #fff;
      border-radius: 16px;
      padding: 30px 25px;
      box-shadow: 0 2px 12px rgba(0,0,0,0.06);
      margin-bottom: 40px;
      transition: box-shadow 0.3s ease;
    }

    .lab-wrapper:hover {
      box-shadow: 0 4px 20px rgba(0,0,0,0.1);
    }

    .lab-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
      gap: 25px;
      justify-content: center;
    }

    .project-card {
      border-radius: 16px;
      overflow: hidden;
      box-shadow: 0 3px 15px rgba(0,0,0,0.08);
      transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
      background: #fff;
      position: relative;
    }

    .project-card:hover {
      transform: translateY(-6px);
      box-shadow: 0 12px 28px rgba(0,0,0,0.15);
    }

    .project-card::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      height: 3px;
      background: linear-gradient(90deg, #ff6b6b, #4ecdc4, #45b7d1, #96ceb4);
      opacity: 0;
      transition: opacity 0.3s ease;
    }

    .project-card:hover::before {
      opacity: 1;
    }

    .project-thumb {
      position: relative;
      width: 100%;
      height: 200px;
      overflow: hidden;
    }

    .project-thumb img {
      width: 100%;
      height: 100%;
      object-fit: cover;
      display: block;
      transition: transform 0.5s ease;
    }

    .project-card:hover .project-thumb img {
      transform: scale(1.05);
    }

    .project-default-cover {
      width: 100%;
      height: 100%;
      display: flex;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    }

    .project-default-cover i {
      font-size: 3rem;
      color: rgba(255,255,255,0.9);
    }

    .project-overlay {
      position: absolute;
      bottom: 0;
      left: 0;
      right: 0;
      background: linear-gradient(transparent, rgba(0,0,0,0.8));
      padding: 20px 15px 15px;
      color: #fff;
      transform: translateY(10px);
      opacity: 0;
      transition: all 0.3s ease;
    }

    .project-card:hover .project-overlay {
      transform: translateY(0);
      opacity: 1;
    }

    .project-info {
      text-align: left;
    }

    .project-title {
      font-weight: 700;
      font-size: 1.1rem;
      margin: 0 0 8px 0;
      line-height: 1.3;
      color: #fff;
    }

    .project-desc {
      font-size: 0.85rem;
      margin: 0 0 10px 0;
      line-height: 1.4;
      color: rgba(255,255,255,0.9);
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }

    .project-meta {
      display: flex;
      justify-content: space-between;
      align-items: center;
      font-size: 0.75rem;
    }

    .project-date {
      color: rgba(255,255,255,0.7);
    }

    .project-tags {
      display: flex;
      gap: 4px;
      flex-wrap: wrap;
    }

    .project-tag {
      background: rgba(255,255,255,0.2);
      padding: 2px 6px;
      border-radius: 10px;
      color: #fff;
      font-size: 0.7rem;
    }

    /* 响应式设计 */
    @media (max-width: 992px) {
      .lab-grid {
        grid-template-columns: repeat(2, 1fr);
      }
    }

    @media (max-width: 768px) {
      .lab-grid {
        grid-template-columns: 1fr;
        gap: 20px;
      }
      
      .lab-wrapper {
        padding: 20px 15px;
        border-radius: 12px;
      }
      
      .project-thumb {
        height: 180px;
      }
    }

    /* 加载动画 */
    @keyframes fadeInUp {
      from {
        opacity: 0;
        transform: translateY(20px);
      }
      to {
        opacity: 1;
        transform: translateY(0);
      }
    }

    .project-card {
      animation: fadeInUp 0.5s ease forwards;
      opacity: 0;
    }

    .project-card:nth-child(1) { animation-delay: 0.1s; }
    .project-card:nth-child(2) { animation-delay: 0.2s; }
    .project-card:nth-child(3) { animation-delay: 0.3s; }
    .project-card:nth-child(4) { animation-delay: 0.4s; }
    .project-card:nth-child(5) { animation-delay: 0.5s; }
    .project-card:nth-child(6) { animation-delay: 0.6s; }
  </style>
{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}