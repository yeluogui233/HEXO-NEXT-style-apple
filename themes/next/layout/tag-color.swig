<script type="text/javascript">
    // 保持原有颜色生成逻辑
    var alltags = document.getElementsByClassName('tag-cloud-tags');
    var tags = alltags[0].getElementsByTagName('a');
    for (var i = tags.length - 1; i >= 0; i--) {
        var r=Math.floor(Math.random()*100 + 156);
        var g=Math.floor(Math.random()*100 + 156);
        var b=Math.floor(Math.random()*100 + 156);
        tags[i].style.background = "rgb("+r+","+g+","+b+")";
        tags[i].style.color = getContrastColor(r, g, b);
    }
    
    function getContrastColor(r, g, b) {
        var yiq = ((r * 299) + (g * 587) + (b * 114)) / 1000;
        return yiq >= 150 ? '#222' : '#fff';
    }
</script>

<style>
    .tag-cloud-tags {
        text-align: center;
        position: relative; /* 为子元素定位提供基准 */
    }

    .tag-cloud-tags a {
        position: relative; /* 为阴影伪元素定位 */
        border-radius: 6px;
        padding: 4px 12px;
        margin: 10px 8px;
        display: inline-block;
        font-weight: 600;
        text-shadow: 0 1px 1px rgba(0,0,0,0.1);
        border: 1px solid rgba(0,0,0,0.05);
        transition: all 0.3s ease;
        background: inherit; /* 继承JS设置的背景色 */
    }

    /* 模糊阴影伪元素 */
    .tag-cloud-tags a::after {
        content: '';
        position: absolute;
        top: 10px;
        left: 0;
        right: 0;
        height: 100%;
        background: inherit;
        filter: blur(8px);
        opacity: 0.7;
        z-index: -1;
        transition: all 0.3s ease;
    }

    /* 悬停时放大阴影 */
    .tag-cloud-tags a:hover {
        transform: translateY(-2px) scale(1.05);
    }
    
    .tag-cloud-tags a:hover::after {
        transform: scale(0.95);
        opacity: 0.9;
        filter: blur(12px);
    }
</style>