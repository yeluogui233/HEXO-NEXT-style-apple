{% macro render(name, itemName, value) %}

  {%- set itemURL = value.split('||')[0] | trim %}
  {%- if not itemURL.startsWith('http') %}
    {%- set itemURL = itemURL | replace('//', '/') %}
  {%- endif %}
  <li class="menu-item menu-item-{{ itemName | replace(' ', '-') }}">

    {%- set menuIcon = '' %}
    {%- if theme.menu_settings.icons %}
      {%- set menuIcon = '<i class="' + value.split('||')[1] | trim + ' fa-fw"></i>' %}
    {%- endif %}
    {%- set menuText = __('menu.' + name) | replace('menu.', '') %}

    {%- set menuBadge = '' %}
    {%- if theme.menu_settings.badges %}
      {%- set badges = {
        archives  : site.posts.length,
        categories: site.categories.length,
        tags      : site.tags.length
        }
      %}
      {%- for menu, count in badges %}
        {%- if name == menu %}
          {%- set menuBadge = '<span class="badge">' + count + '</span>' %}
        {%- endif %}
      {%- endfor %}
    {%- endif %}

    {{ next_url(itemURL, menuIcon + menuText + menuBadge, {rel: 'section'}) }}

  </li>

{% endmacro %}

{% macro render_parent(name, itemName, value) %}

  {%- set parentValue = value.default %}
  {%- set itemURL = parentValue.split('||')[0] | trim %}
  {%- if not itemURL.startsWith('http') %}
    {%- set itemURL = itemURL | replace('//', '/') %}
  {%- endif %}
  <li class="menu-item menu-item-{{ itemName | replace(' ', '-') }} menu-item-has-children">

    {%- set menuIcon = '' %}
    {%- if theme.menu_settings.icons %}
      {%- set menuIcon = '<i class="' + parentValue.split('||')[1] | trim + ' fa-fw"></i>' %}
    {%- endif %}
    {%- set menuText = __('menu.' + name) | replace('menu.', '') %}

    {{ next_url(itemURL, menuIcon + menuText, {rel: 'section'}) }}

    <ul class="menu-child">
      {%- for subname, subvalue in value %}
        {%- set subItemName = subname | lower %}
        {%- if subItemName != 'default' and subvalue != '[object Object]' %}
          {{ render(subname, subItemName, subvalue) }}
        {%- endif %}
      {%- endfor %}
    </ul>

  </li>

{% endmacro %}
