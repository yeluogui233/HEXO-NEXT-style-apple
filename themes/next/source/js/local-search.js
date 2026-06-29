/* global CONFIG */

document.addEventListener('DOMContentLoaded', () => {
  // Popup Window
  let isfetched = false;
  let isFetching = false;
  let datas;
  let isXml = true;
  // Search DB path
  let searchPath = CONFIG.path;
  if (searchPath.length === 0) {
    searchPath = 'search.xml';
  } else if (searchPath.endsWith('json')) {
    isXml = false;
  }
  const input = document.querySelector('.search-input');
  const resultContent = document.getElementById('search-result');
  if (!input || !resultContent) return;
  const pageAliases = {
    '/about/index.html': '\u5173\u4e8e \u5173\u4e8e\u6211 \u535a\u5ba2 \u4e2a\u4eba\u4ecb\u7ecd \u9605\u8bfb \u6444\u5f71 \u70d8\u7119 \u6e38\u620f',
    '/books/index.html': '\u4e66\u5355 \u4e2a\u4eba\u4e66\u5355 \u4e66\u8bc4 \u6458\u8981 \u9605\u8bfb \u8bfb\u4e66 \u85cf\u4e66 books',
    '/gallery/index.html': '\u753b\u5eca \u76f8\u518c \u6444\u5f71 \u7167\u7247 \u98ce\u5149 \u7f8e\u98df \u52a8\u7269 \u8857\u62cd \u535a\u7269\u9986 \u624b\u673a\u6444\u5f71 \u5c71\u4e1c \u5c71\u897f \u6c5f\u82cf \u6e56\u5317 \u6e56\u5357 \u4e91\u5357 gallery',
    '/gallery/scenery/index.html': '\u98ce\u5149 \u98ce\u666f \u5c71\u6c34 \u65c5\u884c \u6444\u5f71 \u76f8\u518c \u753b\u5eca scenery',
    '/gallery/food/index.html': '\u7f8e\u98df \u98df\u7269 \u9910\u684c \u6444\u5f71 \u76f8\u518c \u753b\u5eca food',
    '/gallery/animals/index.html': '\u52a8\u7269 \u732b \u6444\u5f71 \u76f8\u518c \u753b\u5eca animals',
    '/gallery/street/index.html': '\u8857\u62cd \u57ce\u5e02 \u8857\u9053 \u6444\u5f71 \u76f8\u518c \u753b\u5eca street',
    '/gallery/museum/index.html': '\u535a\u7269\u9986 \u5c55\u89c8 \u6587\u7269 \u6444\u5f71 \u76f8\u518c \u753b\u5eca museum',
    '/gallery/phone/index.html': '\u624b\u673a\u6444\u5f71 \u624b\u673a \u6444\u5f71 \u76f8\u518c \u753b\u5eca phone',
    '/gallery/shandong/index.html': '\u5c71\u4e1c \u65c5\u884c \u6444\u5f71 \u76f8\u518c \u753b\u5eca shandong',
    '/gallery/shanxi/index.html': '\u5c71\u897f \u65c5\u884c \u6444\u5f71 \u76f8\u518c \u753b\u5eca shanxi',
    '/gallery/jiangsu/index.html': '\u6c5f\u82cf \u65c5\u884c \u6444\u5f71 \u76f8\u518c \u753b\u5eca jiangsu',
    '/gallery/hubei/index.html': '\u6e56\u5317 \u65c5\u884c \u6444\u5f71 \u76f8\u518c \u753b\u5eca hubei',
    '/gallery/hunan/index.html': '\u6e56\u5357 \u65c5\u884c \u6444\u5f71 \u76f8\u518c \u753b\u5eca hunan',
    '/gallery/yunnan/index.html': '\u4e91\u5357 \u65c5\u884c \u6444\u5f71 \u76f8\u518c \u753b\u5eca yunnan',
    '/diary/index.html': '\u65e5\u8bb0 \u65e5\u5e38 \u751f\u6d3b \u8bb0\u5f55 \u968f\u7b14 diary',
    '/movies/index.html': '\u5f71\u89c6 \u5f71\u5355 \u7535\u5f71 \u5267\u96c6 \u52a8\u753b \u89c2\u5f71 movies',
    '/bake/index.html': '\u70d8\u7119 \u70d8\u57f9 \u86cb\u7cd5 \u751c\u70b9 baking bake',
    '/steamgames/index.html': '\u6e38\u620f Steam steam \u6e38\u620f\u5e93 steamgames',
    '/lab/index.html': '\u5b9e\u9a8c\u5ba4 \u5b9e\u9a8c \u9879\u76ee \u5de5\u5177 lab',
    '/schedule/index.html': '\u65e5\u7a0b\u8868 \u65e5\u7a0b \u8ba1\u5212 \u5b89\u6392 schedule',
    '/archives/index.html': '\u5f52\u6863 \u6587\u7ae0 \u65e5\u5fd7 \u65f6\u95f4\u7ebf archives',
    '/tags/index.html': '\u6807\u7b7e \u6807\u7b7e\u4e91 tags',
    '/categories/index.html': '\u5206\u7c7b \u6587\u7ae0\u5206\u7c7b categories',
    '/404/index.html': '\u516c\u76ca404 \u516c\u76ca 404'
  };

  const getIndexByWord = (word, text, caseSensitive) => {
    if (CONFIG.localsearch.unescape) {
      let div = document.createElement('div');
      div.innerText = word;
      word = div.innerHTML;
    }
    let wordLen = word.length;
    if (wordLen === 0) return [];
    let startPosition = 0;
    let position = [];
    let index = [];
    if (!caseSensitive) {
      text = text.toLowerCase();
      word = word.toLowerCase();
    }
    while ((position = text.indexOf(word, startPosition)) > -1) {
      index.push({ position, word });
      startPosition = position + wordLen;
    }
    return index;
  };

  // Merge hits into slices
  const mergeIntoSlice = (start, end, index, searchText) => {
    let item = index[index.length - 1];
    let { position, word } = item;
    let hits = [];
    let searchTextCountInSlice = 0;
    while (position + word.length <= end && index.length !== 0) {
      if (word === searchText) {
        searchTextCountInSlice++;
      }
      hits.push({
        position,
        length: word.length
      });
      let wordEnd = position + word.length;

      // Move to next position of hit
      index.pop();
      while (index.length !== 0) {
        item = index[index.length - 1];
        position = item.position;
        word = item.word;
        if (wordEnd > position) {
          index.pop();
        } else {
          break;
        }
      }
    }
    return {
      hits,
      start,
      end,
      searchTextCount: searchTextCountInSlice
    };
  };

  // Highlight title and content
  const highlightKeyword = (text, slice) => {
    let result = '';
    let prevEnd = slice.start;
    slice.hits.forEach(hit => {
      result += text.substring(prevEnd, hit.position);
      let end = hit.position + hit.length;
      result += `<b class="search-keyword">${text.substring(hit.position, end)}</b>`;
      prevEnd = end;
    });
    result += text.substring(prevEnd, slice.end);
    return result;
  };

  const inputEventFunction = () => {
    if (!isfetched) return;
    let searchText = input.value.trim().toLowerCase();
    let keywords = searchText.split(/[-\s]+/);
    if (keywords.length > 1) {
      keywords.push(searchText);
    }
    let resultItems = [];
    if (searchText.length > 0) {
      // Perform local searching
      datas.forEach(({ title, content, url }) => {
        let titleInLowerCase = title.toLowerCase();
        let contentInLowerCase = content.toLowerCase();
        let indexOfTitle = [];
        let indexOfContent = [];
        let searchTextCount = 0;
        keywords.forEach(keyword => {
          indexOfTitle = indexOfTitle.concat(getIndexByWord(keyword, titleInLowerCase, false));
          indexOfContent = indexOfContent.concat(getIndexByWord(keyword, contentInLowerCase, false));
        });

        // Show search results
        if (indexOfTitle.length > 0 || indexOfContent.length > 0) {
          let hitCount = indexOfTitle.length + indexOfContent.length;
          // Sort index by position of keyword
          [indexOfTitle, indexOfContent].forEach(index => {
            index.sort((itemLeft, itemRight) => {
              if (itemRight.position !== itemLeft.position) {
                return itemRight.position - itemLeft.position;
              }
              return itemLeft.word.length - itemRight.word.length;
            });
          });

          let slicesOfTitle = [];
          if (indexOfTitle.length !== 0) {
            let tmp = mergeIntoSlice(0, title.length, indexOfTitle, searchText);
            searchTextCount += tmp.searchTextCount;
            slicesOfTitle.push(tmp);
          }

          let slicesOfContent = [];
          while (indexOfContent.length !== 0) {
            let item = indexOfContent[indexOfContent.length - 1];
            let { position, word } = item;
            // Cut out 100 characters
            let start = position - 20;
            let end = position + 80;
            if (start < 0) {
              start = 0;
            }
            if (end < position + word.length) {
              end = position + word.length;
            }
            if (end > content.length) {
              end = content.length;
            }
            let tmp = mergeIntoSlice(start, end, indexOfContent, searchText);
            searchTextCount += tmp.searchTextCount;
            slicesOfContent.push(tmp);
          }

          // Sort slices in content by search text's count and hits' count
          slicesOfContent.sort((sliceLeft, sliceRight) => {
            if (sliceLeft.searchTextCount !== sliceRight.searchTextCount) {
              return sliceRight.searchTextCount - sliceLeft.searchTextCount;
            } else if (sliceLeft.hits.length !== sliceRight.hits.length) {
              return sliceRight.hits.length - sliceLeft.hits.length;
            }
            return sliceLeft.start - sliceRight.start;
          });

          // Select top N slices in content
          let upperBound = parseInt(CONFIG.localsearch.top_n_per_article, 10);
          if (upperBound >= 0) {
            slicesOfContent = slicesOfContent.slice(0, upperBound);
          }

          let resultItem = '';

          if (slicesOfTitle.length !== 0) {
            resultItem += `<li><a href="${url}" class="search-result-title">${highlightKeyword(title, slicesOfTitle[0])}</a>`;
          } else {
            resultItem += `<li><a href="${url}" class="search-result-title">${title}</a>`;
          }

          slicesOfContent.forEach(slice => {
            resultItem += `<a href="${url}"><p class="search-result">${highlightKeyword(content, slice)}...</p></a>`;
          });

          resultItem += '</li>';
          resultItems.push({
            item: resultItem,
            id  : resultItems.length,
            hitCount,
            searchTextCount
          });
        }
      });
    }
    if (keywords.length === 1 && keywords[0] === '') {
      resultContent.innerHTML = '<div id="no-result"><i class="fa fa-search fa-5x"></i></div>';
    } else if (resultItems.length === 0) {
      resultContent.innerHTML = '<div id="no-result"><i class="far fa-frown fa-5x"></i></div>';
    } else {
      resultItems.sort((resultLeft, resultRight) => {
        if (resultLeft.searchTextCount !== resultRight.searchTextCount) {
          return resultRight.searchTextCount - resultLeft.searchTextCount;
        } else if (resultLeft.hitCount !== resultRight.hitCount) {
          return resultRight.hitCount - resultLeft.hitCount;
        }
        return resultRight.id - resultLeft.id;
      });
      resultContent.innerHTML = `<ul class="search-result-list">${resultItems.map(result => result.item).join('')}</ul>`;
      window.pjax && window.pjax.refresh(resultContent);
    }
  };

  const fetchData = () => {
    if (isfetched || isFetching) return;
    isFetching = true;
    const noResult = document.getElementById('no-result');
    if (noResult) {
      noResult.innerHTML = '<i class="fa fa-spinner fa-pulse fa-3x fa-fw"></i><p class="search-status">正在加载搜索索引...</p>';
    }
    fetch(CONFIG.root + searchPath)
      .then(response => {
        if (!response.ok) {
          throw new Error(`Search index request failed: ${response.status}`);
        }
        return response.text();
      })
      .then(res => {
        // Get the contents from search data
        isfetched = true;
        datas = isXml ? [...new DOMParser().parseFromString(res, 'text/xml').querySelectorAll('entry')].map(element => {
          return {
            title  : element.querySelector('title').textContent,
            content: element.querySelector('content').textContent,
            url    : element.querySelector('url').textContent
          };
        }) : JSON.parse(res);
        // Only match articles with not empty titles
        datas = datas.filter(data => data.title).map(data => {
          data.title = data.title.trim();
          data.content = data.content ? data.content.trim().replace(/<[^>]+>/g, '') : '';
          data.url = decodeURIComponent(data.url).replace(/\/{2,}/g, '/');
          if (pageAliases[data.url]) {
            data.content = `${data.content} ${pageAliases[data.url]}`.trim();
          }
          return data;
        });
        // Remove loading animation
        isFetching = false;
        const noResult = document.getElementById('no-result');
        if (noResult) {
          noResult.innerHTML = '<i class="fa fa-search fa-5x"></i>';
        }
        inputEventFunction();
      })
      .catch(() => {
        isFetching = false;
        const noResult = document.getElementById('no-result');
        if (noResult) {
          noResult.innerHTML = '<i class="far fa-frown fa-3x"></i><p class="search-status">搜索索引加载失败，请确认 search.xml 已生成。</p>';
        }
      });
  };

  if (CONFIG.localsearch.preload) {
    fetchData();
  }

  if (CONFIG.localsearch.trigger === 'auto') {
    input.addEventListener('input', inputEventFunction);
  } else {
    document.querySelector('.search-icon').addEventListener('click', inputEventFunction);
    input.addEventListener('keypress', event => {
      if (event.key === 'Enter') {
        inputEventFunction();
      }
    });
  }

  // Handle and trigger popup window
  const openPopup = () => {
    const overlay = document.querySelector('.search-pop-overlay');
    if (!overlay || !input) return;
    document.body.style.overflow = 'hidden';
    overlay.classList.add('search-active');
    window.setTimeout(() => input.focus(), 80);
    if (!isfetched) fetchData();
    if (isfetched) inputEventFunction();
  };

  document.querySelectorAll('.popup-trigger').forEach(element => {
    element.addEventListener('click', event => {
      event.preventDefault();
      openPopup();
    });
  });

  document.addEventListener('click', event => {
    const trigger = event.target.closest('.popup-trigger, .menu-item-search a');
    if (!trigger) return;
    event.preventDefault();
    openPopup();
  });

  // Monitor main search box
  const onPopupClose = () => {
    document.body.style.overflow = '';
    const overlay = document.querySelector('.search-pop-overlay');
    if (overlay) overlay.classList.remove('search-active');
  };

  const overlay = document.querySelector('.search-pop-overlay');
  if (overlay) {
    overlay.addEventListener('click', event => {
      if (event.target === overlay) {
        onPopupClose();
      }
    });
  }
  const closeButton = document.querySelector('.popup-btn-close');
  if (closeButton) {
    closeButton.addEventListener('click', onPopupClose);
  }
  window.addEventListener('pjax:success', onPopupClose);
  window.addEventListener('keyup', event => {
    if (event.key === 'Escape') {
      onPopupClose();
    }
  });
});
