{% extends '_layout.swig' %}
{% block content %}
<div class="post-content">

  <!-- 容器 -->
  <div id="skill-globe" style="width: 100%; height: 600px;"></div>

  <!-- 引入 ECharts 和 3D 扩展 -->
  <script src="https://cdn.jsdelivr.net/npm/echarts@5.4.3/dist/echarts.min.js"></script>
  <script src="https://cdn.jsdelivr.net/npm/echarts-gl@2.0.9/dist/echarts-gl.min.js"></script>

  <!-- 核心代码 -->
  <script>
  document.addEventListener('DOMContentLoaded', function() {
    const chart = echarts.init(document.getElementById('skill-globe'));
    
    // 技能数据配置 (按需修改)
    const skills = [
      { name: '摄影', value: 85, itemStyle: { color: '#FF6B6B' } },
      { name: '读书', value: 90, itemStyle: { color: '#70A1FF' } },
      { name: '设计', value: 75, itemStyle: { color: '#7BED9F' } }
    ];

    // 生成3D坐标
    function getCoords(index, total) {
      const phi = Math.acos(-1 + (2 * index) / total);
      const theta = Math.sqrt(total * Math.PI) * phi;
      return {
        x: Math.cos(theta) * Math.sin(phi),
        y: Math.sin(theta) * Math.sin(phi),
        z: Math.cos(phi)
      };
    }

    // 配置项
    chart.setOption({
      backgroundColor: 'transparent',
      globe: {
        baseTexture: "https://echarts.apache.org/examples/data-gl/asset/world.topo.bathy.200401.jpg",
        environment: "https://echarts.apache.org/examples/data-gl/asset/starfield.jpg",
        displacementScale: 0.04,
        shading: 'realistic',
        light: {
          ambient: { intensity: 0.5 },
          main: { intensity: 1.5 }
        },
        layers: [{
          type: 'blend',
          texture: "https://echarts.apache.org/examples/data-gl/asset/clouds.png",
          shading: 'lambert',
          distance: 5
        }]
      },
      series: [{
        type: 'scatter3D',
        coordinateSystem: 'globe',
        symbolSize: val => val.value / 4,
        data: skills.map((skill, i) => ({
          ...skill,
          ...getCoords(i, skills.length)
        })),
        label: {
          show: true,
          formatter: '{b}',
          position: 'right',
          textStyle: {
            color: '#fff',
            fontSize: 14,
            backgroundColor: 'rgba(0,0,0,0.7)',
            padding: [3, 5],
            borderRadius: 4
          }
        },
        emphasis: {
          label: {
            show: true
          },
          itemStyle: {
            color: '#fff'
          }
        }
      }]
    });

    // 窗口大小变化时重绘
    window.addEventListener('resize', function() {
      chart.resize();
    });
  });
  </script>

</div>
{% endblock %}