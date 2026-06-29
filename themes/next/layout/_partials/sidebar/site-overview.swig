<div class="sidebar-profile-card motion-element">
  <div class="site-author" itemprop="author" itemscope itemtype="http://schema.org/Person">
    {%- if theme.avatar.url %}
      <img class="site-author-image" itemprop="image" alt="{{ author }}"
        src="{{ url_for(theme.avatar.url) }}">
    {%- endif %}
    <p class="site-author-name" itemprop="name">{{ author }}</p>
    <div class="site-description" itemprop="description">{{ description }}</div>
  </div>

  {%- if theme.site_state %}
    <div class="site-state-wrap">
      <nav class="site-state">
        {%- if config.archive_dir != '/' and site.posts.length > 0 %}
          <div class="site-state-item site-state-posts">
            <a href="{{ url_for(config.archive_dir) }}">
              <span class="site-state-item-count">{{ site.posts.length }}</span>
              <span class="site-state-item-name">{{ __('state.posts') }}</span>
            </a>
          </div>
        {%- endif %}

        {%- if site.categories.length > 0 %}
          {%- set categoriesPageQuery = site.pages.find({type: 'categories'}, {lean: true}) %}
          {%- set hasCategoriesPage = categoriesPageQuery.length > 0 %}
          <div class="site-state-item site-state-categories">
            {%- if hasCategoriesPage %}
              <a href="{{ url_for(config.category_dir) + '/' }}">
            {%- endif %}
            <span class="site-state-item-count">{{ site.categories.length }}</span>
            <span class="site-state-item-name">{{ __('state.categories') }}</span>
            {%- if hasCategoriesPage %}</a>{%- endif %}
          </div>
        {%- endif %}

        {%- if site.tags.length > 0 %}
          {%- set tagsPageQuery = site.pages.find({type: 'tags'}, {lean: true}) %}
          {%- set hasTagsPage = tagsPageQuery.length > 0 %}
          <div class="site-state-item site-state-tags">
            {%- if hasTagsPage %}
              <a href="{{ url_for(config.tag_dir) + '/' }}">
            {%- endif %}
            <span class="site-state-item-count">{{ site.tags.length }}</span>
            <span class="site-state-item-name">{{ __('state.tags') }}</span>
            {%- if hasTagsPage %}</a>{%- endif %}
          </div>
        {%- endif %}
      </nav>
    </div>
  {%- endif %}

  {%- if theme.social %}
    <div class="links-of-author">
      {%- for name, link in theme.social %}
        <span class="links-of-author-item">
        {%- set sidebarURL = link.split('||')[0] | trim %}
        {%- if theme.social_icons.enable %}
          {%- set sidebarIcon = '<i class="' + link.split('||')[1] | trim + ' fa-fw"></i>' %}
        {%- else %}
          {%- set sidebarIcon = '' %}
        {%- endif %}
        {%- if theme.social_icons.enable and theme.social_icons.icons_only %}
          {%- set sidebarText = '' %}
        {%- else %}
          {%- set sidebarText = name %}
        {%- endif %}
          {{ next_url(sidebarURL, sidebarIcon + sidebarText, {title: name + ' -> ' + sidebarURL}) }}
        </span>
      {%- endfor %}
    </div>
  {%- endif %}
</div>

{%- if theme.chat.enable and theme.chat.service !== '' %}
  <div class="sidebar-button motion-element">
  {%- if theme.chat.service == 'chatra' and theme.chatra.enable %}
    <a onclick="Chatra('openChat', true);">
  {%- endif %}
  {%- if theme.chat.service == 'tidio' and theme.tidio.enable %}
    <a onclick="tidioChatApi.open();">
  {%- endif %}
  {%- if theme.chat.icon %}<i class="{{ theme.chat.icon }}"></i>{%- endif %}
    {{ theme.chat.text }}
  </a>
  </div>
{%- endif %}

{%- if theme.creative_commons.license and theme.creative_commons.sidebar %}
  <div class="cc-license motion-element" itemprop="license">
  {%- set ccImage = '<img src="' + url_for(theme.images + '/cc-' + theme.creative_commons.license + '.svg') + '" alt="Creative Commons">' %}
    {{ next_url(ccURL, ccImage, {class: 'cc-opacity'}) }}
  </div>
{%- endif %}

{%- if site.posts.length > 0 %}
  <div class="sidebar-card sidebar-popular motion-element">
    <div class="sidebar-card-title">
      <i class="fa fa-fire fa-fw"></i>热门文章
    </div>
    <ol class="sidebar-popular-list">
      {%- for post in site.posts.sort('-date').limit(5).toArray() %}
        <li class="sidebar-popular-item">
          <a href="{{ url_for(post.path) }}" title="{{ post.title or __('post.untitled') }}">
            <span>{{ post.title or __('post.untitled') }}</span>
            <time datetime="{{ moment(post.date).format() }}">{{ date(post.date, 'MM-DD') }}</time>
          </a>
        </li>
      {%- endfor %}
    </ol>
  </div>
{%- endif %}

{%- if site.tags.length > 0 %}
  <div class="sidebar-card sidebar-tag-cloud motion-element">
    <div class="sidebar-card-title">
      <i class="fa fa-tags fa-fw"></i>标签
    </div>
    <div class="sidebar-tag-cloud-list">
      {{ tagcloud({
        min_font   : 12,
        max_font   : 18,
        amount     : 32,
        color      : false})
      }}
    </div>
  </div>
{%- endif %}

{# Blogroll #}
{%- if theme.links %}
  <div class="links-of-blogroll motion-element">
    <div class="links-of-blogroll-title">
      {%- if theme.links_settings.icon %}<i class="{{ theme.links_settings.icon }} fa-fw"></i>{%- endif %}
      {{ theme.links_settings.title }}
    </div>
    <ul class="links-of-blogroll-list">
      {%- for blogrollText, blogrollURL in theme.links %}
        <li class="links-of-blogroll-item">
          {{ next_url(blogrollURL, blogrollText, {title: blogrollURL}) }}
        </li>
      {%- endfor %}
    </ul>
  </div>
{%- endif %}
