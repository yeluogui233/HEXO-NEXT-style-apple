(function () {
  'use strict';

  function normalize(value) {
    return (value || '')
      .replace(/^\s+|\s+$/g, '')
      .replace(/[\u00A0\u2000-\u200D\uFEFF]/g, '')
      .replace(/[０-９]/g, function (ch) {
        return String.fromCharCode(ch.charCodeAt(0) - 0xFEE0);
      });
  }

  function showError(wrapper, message) {
    var error = wrapper.querySelector('[role="alert"]');
    if (error) error.textContent = message || '瀵嗙爜涓嶅锛屽啀璇曡瘯';
  }

  function clearError(wrapper) {
    var error = wrapper.querySelector('[role="alert"]');
    if (error) error.textContent = '';
  }

  function reveal(wrapper) {
    var template = wrapper.querySelector('template.password-gate-content');
    if (!template) return;
    var parent = wrapper.parentNode;
    if (!parent) return;
    var container = document.createElement('div');
    container.id = 'password-gate-unlocked';
    container.appendChild(template.content.cloneNode(true));
    parent.replaceChild(container, wrapper);
    try {
      window.dispatchEvent(new Event('hexo-blog-decrypt'));
    } catch (e) {}
  }

  function bind(wrapper) {
    if (wrapper.dataset.bound === 'true') return;
    wrapper.dataset.bound = 'true';

    var form = wrapper.querySelector('#hbeForm');
    var input = wrapper.querySelector('#hbePass');
    var wrongMessage = wrapper.dataset.wrongMessage || '瀵嗙爜涓嶅锛屽啀璇曡瘯';
    var password = normalize(wrapper.dataset.password || '');

    if (!form || !input || !password) return;

    input.focus();

    form.addEventListener('submit', function (event) {
      event.preventDefault();
      clearError(wrapper);
      var value = normalize(input.value);
      if (!value) {
        showError(wrapper, wrongMessage);
        return;
      }
      if (value === password) {
        reveal(wrapper);
      } else {
        showError(wrapper, wrongMessage);
        input.value = '';
        input.focus();
      }
    });
  }

  function boot() {
    document.querySelectorAll('#hexo-blog-password-gate').forEach(bind);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
  window.addEventListener('pjax:success', boot);
})();


