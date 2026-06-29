{% extends '_layout.swig' %}
{% import '_macro/post-collapse.swig' as post_template with context %}
{% import '_macro/sidebar.swig' as sidebar_template with context %}

{% block title %}{{ __('title.tag') }}: {{ page.tag }} | {{ title }}{% endblock %}

{% block class %}tag{% endblock %}

{% block content %}

  {#################}
  {### TAG BLOCK ###}
  {#################}
  <div class="post-block">
    <div class="posts-collapse">
      <div class="collection-title">
        <h2 class="collection-header">
          {{- page.tag }}
          <small>{{ __('title.tag') }}</small>
        </h2>
      </div>

      {# 引入标签云（包含颜色样式） #}
      {% include 'tag-cloud.swig' %}
      
      {# 引入标签柱状图 #}
      {% include 'tag-chart.swig' %}

      {{ post_template.render(page.posts) }}
    </div>
  </div>
  {#####################}
  {### END TAG BLOCK ###}
  {#####################}

  {% include '_partials/pagination.swig' %}

{% endblock %}

{% block sidebar %}
  {{ sidebar_template.render(false) }}
{% endblock %}