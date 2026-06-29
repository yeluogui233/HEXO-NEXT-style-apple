(function () {
  'use strict';

  function isTouchMenuMode() {
    return window.matchMedia('(hover: none), (pointer: coarse), (max-width: 760px)').matches;
  }

  function closeAll(except) {
    document.querySelectorAll('.main-menu .menu-item-has-children.is-touch-open').forEach(function (item) {
      if (item !== except) item.classList.remove('is-touch-open');
    });
  }

  function bind() {
    document.querySelectorAll('.main-menu .menu-item-has-children > a').forEach(function (link) {
      if (link.dataset.touchMenuBound === 'true') return;
      link.dataset.touchMenuBound = 'true';

      link.addEventListener('click', function (event) {
        if (!isTouchMenuMode()) return;

        var item = link.closest('.menu-item-has-children');
        if (!item) return;

        if (!item.classList.contains('is-touch-open')) {
          event.preventDefault();
          closeAll(item);
          item.classList.add('is-touch-open');
        }
      });
    });

    document.addEventListener('click', function (event) {
      if (!isTouchMenuMode()) return;
      if (!event.target.closest('.main-menu .menu-item-has-children')) {
        closeAll();
      }
    });
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', bind);
  } else {
    bind();
  }

  window.addEventListener('pjax:success', bind);
})();
