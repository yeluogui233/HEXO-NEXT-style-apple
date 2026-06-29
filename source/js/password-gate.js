(function () {
  'use strict';

  function normalize(value) {
    return (value || '')
      .trim()
      .replace(/[\u00A0\u2000-\u200D\uFEFF]/g, '')
      .replace(/[０-９]/g, function (ch) {
        return String.fromCharCode(ch.charCodeAt(0) - 0xFEE0);
      });
  }

  function showError(wrapper, message) {
    var error = wrapper.querySelector('[role="alert"]');
    if (error) error.textContent = message || '密码不正确，请再试一次。';
  }

  function clearError(wrapper) {
    var error = wrapper.querySelector('[role="alert"]');
    if (error) error.textContent = '';
  }

  function reveal(wrapper) {
    var template = wrapper.querySelector('template.password-gate-content');
    var parent = wrapper.parentNode;
    if (!template || !parent) return false;

    var container = document.createElement('div');
    container.id = 'password-gate-unlocked';
    container.appendChild(template.content.cloneNode(true));
    parent.replaceChild(container, wrapper);

    try {
      window.dispatchEvent(new Event('hexo-blog-decrypt'));
    } catch (e) {}
    return true;
  }

  window.unlockPasswordGate = function (form) {
    var wrapper = form && form.closest ? form.closest('.password-gate') : document.getElementById('hexo-blog-password-gate');
    if (!wrapper) return false;

    var input = wrapper.querySelector('#hbePass');
    var password = normalize(wrapper.dataset.password || '');
    var value = normalize(input ? input.value : '');

    clearError(wrapper);
    if (value && password && value === password) {
      reveal(wrapper);
    } else {
      showError(wrapper, wrapper.dataset.wrongMessage);
      if (input) {
        input.value = '';
        input.focus();
      }
    }
    return false;
  };

  function bind(wrapper) {
    if (wrapper.dataset.bound === 'true') return;
    wrapper.dataset.bound = 'true';

    var form = wrapper.querySelector('#hbeForm');
    var input = wrapper.querySelector('#hbePass');
    if (!form || !input) return;

    form.addEventListener('submit', function (event) {
      event.preventDefault();
      window.unlockPasswordGate(form);
    });
  }

  function boot() {
    document.querySelectorAll('.password-gate').forEach(bind);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', boot);
  } else {
    boot();
  }
  window.addEventListener('pjax:success', boot);
})();
