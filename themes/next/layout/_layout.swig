<!DOCTYPE html>
<html lang="{{ config.language }}">
<head>
  <script src="https://cdn.jsdelivr.net/npm/cardlink"></script>
  <link rel="stylesheet" href="{{ url_for(theme.css) }}/_common/codeblock.css">
  {{ partial('_partials/head/head.swig', {}, {cache: theme.cache.enable}) }}
  {% include '_partials/head/head-unique.swig' %}
  {{- next_inject('head') }}
  <link rel="stylesheet" href="{{ url_for('/css/apple-final-fix.css') }}?v=20260628-apple-4">
  <link rel="stylesheet" href="{{ url_for('/css/makima-pet.css') }}">
  <link rel="stylesheet" href="{{ url_for('/css/visual-hotfix.css') }}?v=20260628-visual-4">
  <link rel="stylesheet" href="{{ url_for('/css/mobile-fix.css') }}?v=20260629-mobile-1">
  
  <title>{% block title %}{% endblock %}</title>
  {{ partial('_third-party/analytics/index.swig', {}, {cache: theme.cache.enable}) }}
  {{ partial('_scripts/noscript.swig', {}, {cache: theme.cache.enable}) }}
</head>


<body itemscope itemtype="http://schema.org/WebPage">
  <div class="container{%- if theme.motion.enable %} use-motion{%- endif %}">
    <div class="headband"></div>

    <header class="header" itemscope itemtype="http://schema.org/WPHeader">
      <div class="header-inner">{% include '_partials/header/index.swig' %}</div>
    </header>

    {{ partial('_partials/widgets.swig', {}, {cache: theme.cache.enable}) }}

    <main class="main">
      <div class="main-inner">
        <div class="content-wrap">
          {% include '_partials/header/sub-menu.swig' %}
          <div class="content {% block class %}{% endblock %}">
            {% block content %}{% endblock %}
          </div>
          {% include '_partials/comments.swig' %}
        </div>
        {%- if theme.sidebar.display !== 'remove' %}
          {% block sidebar %}{% endblock %}
        {%- endif %}
      </div>
    </main>

    <footer class="footer">
      <div class="footer-inner">
        {% include '_partials/languages.swig' %}
        {{ partial('_partials/footer.swig', {}, {cache: theme.cache.enable}) }}
        {{ partial('_third-party/statistics/index.swig', {}, {cache: theme.cache.enable}) }}
      </div>
    </footer>
  </div>

  {{ partial('_scripts/index.swig', {}, {cache: theme.cache.enable}) }}
  {{ partial('_third-party/index.swig', {}, {cache: theme.cache.enable}) }}

  {%- if theme.pjax %}
    <div id="pjax">
  {%- endif %}
  {% include '_third-party/math/index.swig' %}
  {% include '_third-party/quicklink.swig' %}

  {{- next_inject('bodyEnd') }}
  {%- if theme.pjax %}
    </div>
  {%- endif %}
<!-- 缃戞槗浜戞挱鏀惧櫒 -->
<div id="netease-player">
  <iframe frameborder="no" border="0" marginwidth="0" marginheight="0"
    width="330" height="86"
    src="//music.163.com/outchain/player?type=2&id=1886731595&auto=0&height=66">
  </iframe>
</div>

<style>
  #netease-player {
    position: fixed;
    left: 20px;
    bottom: 20px;
    z-index: 99998;
  }
</style>

<style>
code[class*="language-"], pre[class*="language-"] { white-space: pre !important; }
</style>
<canvas class="fireworks" style="position: fixed;left: 0;top: 0;z-index: 1; pointer-events: none;" ></canvas> 
<script type="text/javascript" src="//cdn.bootcss.com/animejs/2.2.0/anime.min.js"></script> 
<script type="text/javascript" src="/js/firework.js"></script>
<script src="/libs/codeBlock/codeBlockFuction.js"></script>
<script src="/libs/codeBlock/codeLang.js"></script>
<script src="/libs/codeBlock/codeCopy.js"></script>
<script src="/libs/codeBlock/clipboard.min.js"></script>
<script src="/libs/codeBlock/codeShrink.js"></script>
<script src="{{ url_for('/js/touch-menu.js') }}?v=20260629-touch-1"></script>
<script src="{{ url_for('/js/makima-pet.js') }}"></script>
<script>
// 涓烘枃绔犲唴瀹逛腑鐨勬墍鏈夊閮ㄩ摼鎺ョ敓鎴愬崱鐗?
document.addEventListener('DOMContentLoaded', function() {
  var postContent = document.querySelector('.post-body') || 
                    document.querySelector('.post-block') ||
                    document.querySelector('.entry-content');
  if (postContent) {
    var externalLinks = postContent.querySelectorAll('a[target="_blank"]');
    if (externalLinks.length > 0) {
      cardLink(externalLinks);
    }
  }
});
</script>
</body>
</html>

