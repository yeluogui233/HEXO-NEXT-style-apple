(function() {
  const spriteColumns = 8;
  const spriteRows = 9;
  const states = {
    idle: { row: 0, frames: 6, interval: 180 },
    runRight: { row: 1, frames: 8, interval: 90 },
    runLeft: { row: 2, frames: 8, interval: 90 },
    point: { row: 3, frames: 4, interval: 150, hold: 520 },
    wave: { row: 4, frames: 5, interval: 135, hold: 620 },
    sad: { row: 5, frames: 8, interval: 170, hold: 1200 },
    calm: { row: 6, frames: 5, interval: 190, hold: 1250 },
    shy: { row: 7, frames: 8, interval: 160, hold: 1100 },
    smug: { row: 8, frames: 8, interval: 150, hold: 900 }
  };

  const savedPositionKey = 'makima-pet-position';
  let frame = 0;
  let stateName = 'idle';
  let pointerOffset = { x: 0, y: 0 };
  let isDragging = false;
  let lastX = 0;
  let autoTimer = null;
  let actionTimer = null;
  let autoMoveFrame = 0;
  let lastPointerDown = 0;
  let clickSuppressUntil = 0;

  function setFrame(element, state, frameIndex) {
    const x = spriteColumns === 1 ? 0 : (frameIndex / (spriteColumns - 1)) * 100;
    const y = spriteRows === 1 ? 0 : (state.row / (spriteRows - 1)) * 100;
    element.style.backgroundPosition = `${x}% ${y}%`;
  }

  function setState(element, nextState) {
    if (stateName === nextState) return;
    stateName = nextState;
    frame = 0;
    setFrame(element, states[stateName], frame);
  }

  function playState(element, nextState, duration) {
    window.clearTimeout(actionTimer);
    setState(element, nextState);
    const state = states[nextState] || states.idle;
    actionTimer = window.setTimeout(() => {
      if (!isDragging && stateName === nextState) setState(element, 'idle');
      scheduleAutoAction(element);
    }, duration || state.hold || 900);
  }

  function clampPosition(x, y, element) {
    const margin = 8;
    const rect = element.getBoundingClientRect();
    const maxX = window.innerWidth - rect.width - margin;
    const maxY = window.innerHeight - rect.height - margin;
    return {
      x: Math.min(Math.max(margin, x), Math.max(margin, maxX)),
      y: Math.min(Math.max(margin, y), Math.max(margin, maxY))
    };
  }

  function getPosition(element) {
    const rect = element.getBoundingClientRect();
    return { x: rect.left, y: rect.top };
  }

  function setPosition(element, x, y) {
    const position = clampPosition(x, y, element);
    element.style.left = `${position.x}px`;
    element.style.top = `${position.y}px`;
    element.style.right = 'auto';
    element.style.bottom = 'auto';
    return position;
  }

  function savePosition(element) {
    localStorage.setItem(savedPositionKey, JSON.stringify(getPosition(element)));
  }

  function restorePosition(element) {
    try {
      const saved = JSON.parse(localStorage.getItem(savedPositionKey) || 'null');
      if (saved) setPosition(element, saved.x, saved.y);
    } catch {}
  }

  function hop(element) {
    element.classList.remove('is-jumping');
    void element.offsetWidth;
    element.classList.add('is-jumping');
    playState(element, 'smug', 760);
  }

  function scheduleAutoAction(element) {
    window.clearTimeout(autoTimer);
    autoTimer = window.setTimeout(() => runAutoAction(element), 850 + Math.random() * 1700);
  }

  function clearMotion() {
    window.clearTimeout(autoTimer);
    window.clearTimeout(actionTimer);
    if (autoMoveFrame) window.cancelAnimationFrame(autoMoveFrame);
    autoMoveFrame = 0;
  }

  function walk(element) {
    if (isDragging) return scheduleAutoAction(element);

    const start = getPosition(element);
    const direction = Math.random() > 0.5 ? 1 : -1;
    const distance = 70 + Math.random() * 150;
    const target = clampPosition(start.x + direction * distance, start.y, element);
    const duration = 760 + Math.random() * 520;
    const startedAt = performance.now();
    setState(element, direction > 0 ? 'runRight' : 'runLeft');

    function step(now) {
      if (isDragging) {
        autoMoveFrame = 0;
        return;
      }

      const progress = Math.min((now - startedAt) / duration, 1);
      const eased = 1 - Math.pow(1 - progress, 3);
      const x = start.x + (target.x - start.x) * eased;
      setPosition(element, x, target.y);

      if (progress < 1) {
        autoMoveFrame = window.requestAnimationFrame(step);
      } else {
        autoMoveFrame = 0;
        setState(element, 'idle');
        savePosition(element);
        scheduleAutoAction(element);
      }
    }

    autoMoveFrame = window.requestAnimationFrame(step);
  }

  function pace(element) {
    if (isDragging) return scheduleAutoAction(element);

    const start = getPosition(element);
    const direction = Math.random() > 0.5 ? 1 : -1;
    const firstTarget = clampPosition(start.x + direction * 34, start.y, element);
    const secondTarget = clampPosition(start.x - direction * 22, start.y, element);
    const startedAt = performance.now();
    const duration = 820;

    function step(now) {
      if (isDragging) {
        autoMoveFrame = 0;
        return;
      }

      const progress = Math.min((now - startedAt) / duration, 1);
      const returning = progress > 0.55;
      const localProgress = returning ? (progress - 0.55) / 0.45 : progress / 0.55;
      const from = returning ? firstTarget : start;
      const to = returning ? secondTarget : firstTarget;
      const eased = 1 - Math.pow(1 - localProgress, 2);
      setState(element, to.x >= from.x ? 'runRight' : 'runLeft');
      setPosition(element, from.x + (to.x - from.x) * eased, start.y);

      if (progress < 1) {
        autoMoveFrame = window.requestAnimationFrame(step);
      } else {
        autoMoveFrame = 0;
        playState(element, 'wave', 620);
        savePosition(element);
      }
    }

    autoMoveFrame = window.requestAnimationFrame(step);
  }

  function runAutoAction(element) {
    if (isDragging) return scheduleAutoAction(element);

    const action = Math.random();
    if (action < 0.38) {
      walk(element);
    } else if (action < 0.52) {
      pace(element);
    } else if (action < 0.64) {
      playState(element, 'wave');
    } else if (action < 0.76) {
      playState(element, 'sad');
    } else if (action < 0.86) {
      playState(element, 'calm');
    } else if (action < 0.94) {
      playState(element, 'shy');
    } else {
      playState(element, 'point');
    }
  }

  function mount() {
    if (document.getElementById('makima-pet')) return;

    const pet = document.createElement('div');
    pet.id = 'makima-pet';
    pet.setAttribute('role', 'img');
    pet.setAttribute('aria-label', 'Makima pixel pet, draggable');
    pet.title = 'Makima';
    document.body.appendChild(pet);

    restorePosition(pet);
    setFrame(pet, states.idle, 0);

    window.setInterval(() => {
      const state = states[stateName] || states.idle;
      frame = (frame + 1) % state.frames;
      setFrame(pet, state, frame);
    }, 95);

    pet.addEventListener('pointerdown', event => {
      isDragging = true;
      clearMotion();
      lastX = event.clientX;
      lastPointerDown = Date.now();
      pet.classList.add('is-dragging');
      const rect = pet.getBoundingClientRect();
      pointerOffset = {
        x: event.clientX - rect.left,
        y: event.clientY - rect.top
      };
      pet.setPointerCapture(event.pointerId);
      event.preventDefault();
    });

    pet.addEventListener('pointermove', event => {
      if (!isDragging) return;
      setPosition(pet, event.clientX - pointerOffset.x, event.clientY - pointerOffset.y);
      setState(pet, event.clientX >= lastX ? 'runRight' : 'runLeft');
      lastX = event.clientX;
      event.preventDefault();
    });

    pet.addEventListener('pointerup', event => {
      if (!isDragging) return;
      isDragging = false;
      pet.classList.remove('is-dragging');
      savePosition(pet);

      const wasClick = Date.now() - lastPointerDown < 220;
      if (wasClick && Date.now() > clickSuppressUntil) {
        playState(pet, Math.random() > 0.45 ? 'point' : 'shy');
      } else {
        setState(pet, 'idle');
        scheduleAutoAction(pet);
      }

      try {
        pet.releasePointerCapture(event.pointerId);
      } catch {}
    });

    pet.addEventListener('pointercancel', () => {
      isDragging = false;
      pet.classList.remove('is-dragging');
      setState(pet, 'idle');
      savePosition(pet);
      scheduleAutoAction(pet);
    });

    pet.addEventListener('dblclick', () => {
      clickSuppressUntil = Date.now() + 350;
      hop(pet);
      savePosition(pet);
    });

    pet.addEventListener('mouseenter', () => {
      if (!isDragging) playState(pet, Math.random() > 0.3 ? 'wave' : 'calm', 760);
    });

    pet.addEventListener('contextmenu', event => {
      event.preventDefault();
      playState(pet, 'sad', 1500);
    });

    window.addEventListener('resize', () => {
      const position = getPosition(pet);
      setPosition(pet, position.x, position.y);
      savePosition(pet);
    });

    scheduleAutoAction(pet);
  }

  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', mount);
  } else {
    mount();
  }
})();
