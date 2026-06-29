  {##################}
  {### POST BLOCK ###}
  {##################}
  <article itemscope itemtype="http://schema.org/Article" class="post-block{%- if is_index %} post-card-preview{%- endif %}" lang="{{ post.lang or config.language }}">
    <link itemprop="mainEntityOfPage" href="{{ post.permalink }}">

    <span hidden itemprop="author" itemscope itemtype="http://schema.org/Person">
      <meta itemprop="image" content="{{ url_for(theme.avatar.url or theme.images + '/avatar.gif') }}">
      <meta itemprop="name" content="{{ author }}">
      <meta itemprop="description" content="{{ description }}">
    </span>

    <span hidden itemprop="publisher" itemscope itemtype="http://schema.org/Organization">
      <meta itemprop="name" content="{{ title }}">
    </span>

    {%- if is_index %}
      <a class="post-card-cover" href="{{ url_for(post.path) }}" aria-label="{{ post.title or __('post.untitled') }}">
        <img src="{{ post_cover(post) }}" alt="{{ post.title or __('post.untitled') }}" loading="lazy">
      </a>
    {%- endif %}

    {%- if is_index %}<div class="post-card-info">{%- endif %}

    {%- if post.header !== false %}
      <header class="post-header">
        <{%- if is_index %}h2{% else %}h1{%- endif %} class="post-title{%- if post.direction and post.direction.toLowerCase() === 'rtl' %} rtl{%- endif %}" itemprop="name headline">
          {# Link posts #}
          {%- if post.link %}
            {%- if post.sticky > 0 %}
              <span class="post-sticky-flag" title="{{ __('post.sticky') }}">
                <i class="fa fa-thumbtack"></i>
              </span>
            {%- endif %}
            {%- set postTitleIcon = '<i class="fa fa-external-link-alt"></i>' %}
            {%- set postText = post.title or post.link %}
            {{ next_url(post.link, postText + postTitleIcon, {class: 'post-title-link post-title-link-external', itemprop: 'url'}) }}
          {% elif is_index %}
            {%- if post.sticky > 0 %}
              <span class="post-sticky-flag" title="{{ __('post.sticky') }}">
                <i class="fa fa-thumbtack"></i>
              </span>
            {%- endif %}
            {{ next_url(post.path, post.title or __('post.untitled'), {class: 'post-title-link', itemprop: 'url'}) }}
          {%- else %}
            {{- post.title }}
            {{- post_edit(post.source) }}
          {%- endif %}
        </{%- if is_index %}h2{% else %}h1{%- endif %}>

        <div class="post-meta">
		  {% if post.top %}
           <i class="fa fa-thumb-tack"></i>
           <font color=7D26CD>缃《</font>
           <span class="post-meta-divider">|</span>
          {% endif %}

          {%- set date_diff = date(post.date) != date(post.updated) %}
          {%- set time_diff = time(post.date) != time(post.updated) %}
          {%- set datetime_diff = date_diff or time_diff %}

          {%- if theme.post_meta.created_at %}
            <span class="post-meta-item">
              <span class="post-meta-item-icon">
                <i class="far fa-calendar"></i>
              </span>
              <span class="post-meta-item-text">{{ __('post.posted') }}</span>

              {%- if not date_diff and time_diff and theme.post_meta.updated_at.enable and theme.post_meta.updated_at.another_day %}
                {%- set create_title = __('post.created') + __('symbol.colon') + full_date(post.date) + ' / ' + __('post.modified') + __('symbol.colon') + time(post.updated) %}
              {% else %}
                {%- set create_title = __('post.created') + __('symbol.colon') + full_date(post.date) %}
              {%- endif %}

              <time title="{{ create_title }}" itemprop="dateCreated datePublished" datetime="{{ moment(post.date).format() }}">{{ date(post.date) }}</time>
            </span>
          {%- endif %}

          {%- if theme.post_meta.updated_at.enable and datetime_diff %}
            {%- set display_updated = not theme.post_meta.updated_at.another_day or theme.post_meta.updated_at.another_day and date_diff %}

            {%- if display_updated or not theme.post_meta.created_at %}
              <span class="post-meta-item">
                <span class="post-meta-item-icon">
                  <i class="far fa-calendar-check"></i>
                </span>
                <span class="post-meta-item-text">{{ __('post.edited') }}</span>
                <time title="{{ __('post.modified') + __('symbol.colon') + full_date(post.updated) }}" itemprop="dateModified" datetime="{{ moment(post.updated).format() }}">{{ date(post.updated) }}</time>
              </span>
            {%- endif %}
          {%- endif %}

          {%- if post.categories and post.categories.length and theme.post_meta.categories %}
            <span class="post-meta-item">
              <span class="post-meta-item-icon">
                <i class="far fa-folder"></i>
              </span>
              <span class="post-meta-item-text">{{ __('post.in') }}</span>
              {%- for cat in post.categories.toArray() %}
                <span itemprop="about" itemscope itemtype="http://schema.org/Thing">
                  <a href="{{ url_for(cat.path) }}" itemprop="url" rel="index"><span itemprop="name">{{ cat.name }}</span></a>
                </span>

                {%- set cat_length = post.categories.length %}
                {%- if cat_length > 1 and loop.index !== cat_length %}
                  {{ __('symbol.comma') }}
                {%- endif %}
              {%- endfor %}
            </span>
          {%- endif %}

          {# LeanCloud PageView #}
          {%- if theme.leancloud_visitors.enable or (theme.valine.enable and theme.valine.appid and theme.valine.appkey and theme.valine.visitor) %}
            <span id="{{ url_for(post.path) }}" class="post-meta-item leancloud_visitors" data-flag-title="{{ post.title }}" title="{{ __('post.views') }}">
              <span class="post-meta-item-icon">
                <i class="fa fa-eye"></i>
              </span>
              <span class="post-meta-item-text">{{ __('post.views') + __('symbol.colon') }}</span>
              <span class="leancloud-visitors-count"></span>
            </span>
          {%- endif %}

          {%- if theme.firestore.enable %}
            <span class="post-meta-item" title="{{ __('post.views') }}">
              <span class="post-meta-item-icon">
                <i class="fa fa-users"></i>
              </span>
              <span class="post-meta-item-text">{{ __('post.views') + __('symbol.colon') }}</span>
              <span class="firestore-visitors-count"></span>
            </span>
          {%- endif %}

          {%- if not is_index and theme.busuanzi_count.enable and theme.busuanzi_count.post_views %}
            <span class="post-meta-item" title="{{ __('post.views') }}" id="busuanzi_container_page_pv" style="display: none;">
              <span class="post-meta-item-icon">
                <i class="{{ theme.busuanzi_count.post_views_icon }}"></i>
              </span>
              <span class="post-meta-item-text">{{ __('post.views') + __('symbol.colon') }}</span>
              <span id="busuanzi_value_page_pv"></span>
            </span>
          {%- endif %}

          {{- next_inject('postMeta') }}

          {%- if config.symbols_count_time.symbols %}
          {%- if theme.symbols_count_time.separated_meta %}<br>{%- endif %}
            <span class="post-meta-item" title="{{ __('symbols_count_time.count') }}">
              <span class="post-meta-item-icon">
                <i class="far fa-file-word"></i>
              </span>
              {%- if theme.symbols_count_time.item_text_post %}
                <span class="post-meta-item-text">{{ __('symbols_count_time.count') + __('symbol.colon') }}</span>
              {%- endif %}
              <span>{{ symbolsCount(post) }}</span>
            </span>
          {%- endif %}

          {%- if config.symbols_count_time.time %}
            <span class="post-meta-item" title="{{ __('symbols_count_time.time') }}">
              <span class="post-meta-item-icon">
                <i class="far fa-clock"></i>
              </span>
              {%- if theme.symbols_count_time.item_text_post %}
                <span class="post-meta-item-text">{{ __('symbols_count_time.time') }} &asymp;</span>
              {%- endif %}
              <span>{{ symbolsTime(post, config.symbols_count_time.awl, config.symbols_count_time.wpm, __('symbols_count_time.time_minutes')) }}</span>
            </span>
          {%- endif %}

          {%- if post.description and (not theme.excerpt_description or not is_index) %}
            <div class="post-description">{{ post.description }}</div>
          {%- endif %}

        </div>
      </header>
    {%- endif %}

    {#################}
    {### POST BODY ###}
    {#################}
    <div class="post-body{%- if post.direction and post.direction.toLowerCase() === 'rtl' %} rtl{%- endif %}" itemprop="articleBody">

      {# Gallery support #}
      {%- if post.photos and post.photos.length %}
        <div class="post-gallery" itemscope itemtype="http://schema.org/ImageGallery">
          {%- for photo in post.photos %}
            <img src="{{ url_for(photo) }}" itemprop="contentUrl">
          {%- endfor %}
        </div>
      {%- endif %}

      {%- if is_index %}
        {%- if post.password %}
          <p class="encrypted-post-excerpt">这是加密文章，请进入后输入密码阅读。</p>
        {%- else %}
          <p>{{ post_plain_excerpt(post, 96) }}</p>
        {%- endif %}
        <!--noindex-->
        {%- if theme.read_more_btn %}
          <div class="post-button">
            <a class="btn" href="{{ url_for(post.path) }}" rel="contents">
              {{ __('post.read_more') }} &raquo;
            </a>
          </div>
        {%- endif %}
        <!--/noindex-->
      {% else %}
        {%- if post.password %}
          <div class="hbe hbe-container password-gate" id="hexo-blog-password-gate"
            data-password="{{ post.password }}"
            data-wrong-message="密码不正确，请再试一次。">
            <div class="hbe hbe-content">
              <form id="hbeForm" class="hbe hbe-form" onsubmit="return window.unlockPasswordGate ? window.unlockPasswordGate(this) : false">
                <div class="hbe hbe-input hbe-input-default">
                  <input class="hbe hbe-input-field hbe-input-field-default" type="password" id="hbePass" autocomplete="current-password" inputmode="numeric">
                  <label class="hbe hbe-input-label hbe-input-label-default" for="hbePass">
                    <span class="hbe hbe-input-label-content hbe-input-label-content-default">{{ post.message or '请输入密码继续阅读。' }}</span>
                  </label>
                </div>
                <button class="hbe hbe-button" type="submit">解锁文章</button>
                <div class="hbe hbe-error" role="alert" aria-live="polite"></div>
              </form>
            </div>
            <template class="password-gate-content">
              {{ post.content | safe }}
            </template>
            <script>
            window.unlockPasswordGate = window.unlockPasswordGate || function(form) {
              function normalize(value) {
                return (value || '').trim().replace(/[\u00A0\u2000-\u200D\uFEFF]/g, '').replace(/[０-９]/g, function(ch) {
                  return String.fromCharCode(ch.charCodeAt(0) - 0xFEE0);
                });
              }
              var wrapper = form && form.closest ? form.closest('.password-gate') : document.getElementById('hexo-blog-password-gate');
              if (!wrapper) return false;
              var input = wrapper.querySelector('#hbePass');
              var error = wrapper.querySelector('[role="alert"]');
              var template = wrapper.querySelector('template.password-gate-content');
              var password = normalize(wrapper.getAttribute('data-password') || '');
              var value = normalize(input ? input.value : '');
              if (error) error.textContent = '';
              if (password && value === password && template && wrapper.parentNode) {
                var container = document.createElement('div');
                container.id = 'password-gate-unlocked';
                container.appendChild(template.content.cloneNode(true));
                wrapper.parentNode.replaceChild(container, wrapper);
                try { window.dispatchEvent(new Event('hexo-blog-decrypt')); } catch (e) {}
              } else {
                if (error) error.textContent = wrapper.getAttribute('data-wrong-message') || '密码不正确，请再试一次。';
                if (input) {
                  input.value = '';
                  input.focus();
                }
              }
              return false;
            };
            </script>
          </div>
        {%- else %}
          {{ post.content }}
        {%- endif %}
      {%- endif %}
    </div>

    {%- if is_index %}</div>{%- endif %}

    {#####################}
    {### END POST BODY ###}
    {#####################}

    {%- if theme.related_posts.enable and (theme.related_posts.display_in_home or not is_index) %}
      {{ partial('_partials/post/post-related.swig') }}
    {%- endif %}

    {%- if not is_index %}
      {{- next_inject('postBodyEnd') }}

      {%- if post.reward_settings.enable %}
        {{ partial('_partials/post/post-reward.swig') }}
      {%- endif %}

      {%- if theme.creative_commons.license and theme.creative_commons.post %}
        {{ partial('_partials/post/post-copyright.swig') }}
      {%- endif %}

      {%- if theme.follow_me %}
        {{ partial('_partials/post/post-followme.swig', {}, {cache: theme.cache.enable}) }}
      {%- endif %}

      <footer class="post-footer">
        {%- if post.tags and post.tags.length %}
          {%- if theme.tag_icon %}
            {%- set tag_indicate = '<i class="fa fa-tag"></i>' %}
          {% else %}
            {%- set tag_indicate = '#' %}
          {%- endif %}
          <div class="post-tags">
            {%- for tag in post.tags.toArray() %}
              <a href="{{ url_for(tag.path) }}" rel="tag">{{ tag_indicate }} {{ tag.name }}</a>
            {%- endfor %}
          </div>
        {%- endif %}

        {{ partial('_partials/post/post-footer.swig', {}, {cache: theme.cache.enable}) }}

        {{ post_nav(post) }}
      </footer>
    {% else %}
      <footer class="post-footer">
        <div class="post-eof"></div>
      </footer>
    {%- endif %}
  </article>
  {######################}
  {### END POST BLOCK ###}
  {######################}

