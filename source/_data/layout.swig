hexo.extend.generator.register('gallery', function(locals) {
  return {
    path: 'gallery/index.html',
    layout: ['gallery']
  };
});

hexo.extend.generator.register('album', function(locals) {
  return {
    path: 'gallery/*/index.html',
    layout: ['album']
  };
});