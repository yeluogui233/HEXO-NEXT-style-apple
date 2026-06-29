{% extends '_layout.swig' %}
{% block title %}{{ page.title }} | {{ title }}{% endblock %}
{% block class %}quiz-page{% endblock %}

{% block content %}
<div class="quiz-wrapper">

  <!-- 顶部标题 -->
  <h1 class="quiz-heading">{{ page.title }}</h1>

  <!-- 进度条 -->
  <div class="quiz-progress">
    {% for item in page.questions %}
      <span class="dot"></span>
    {% endfor %}
  </div>

  <!-- 主卡片 -->
  <div id="quiz-card" class="quiz-card fade-in">

    <div class="quiz-stem"></div>

    <div class="quiz-options"></div>

    <!-- 答案反馈 -->
    <div class="quiz-answer" style="display:none;">
      <p class="quiz-correct"></p>
      <p class="quiz-explanation"></p>
    </div>

    <!-- 导航按钮 -->
    <div class="quiz-nav">
      <button class="btn gray-btn prev-btn">上一题</button>
      <button class="btn next-btn">下一题</button>
      <button class="btn submit-btn">提交</button>
    </div>
  </div>

  <!-- 成绩报告 -->
  <div id="quiz-result" class="quiz-result" style="display:none;">
    <h2>🎉 测验完成！</h2>

    <!-- 圆形进度条 -->
    <div class="score-circle">
      <svg viewBox="0 0 100 100">
        <circle cx="50" cy="50" r="45" class="bg"></circle>
        <circle cx="50" cy="50" r="45" class="progress"></circle>
      </svg>
      <div class="score-text">0</div>
    </div>

    <p class="result-acc"></p>

    <button class="btn restart-btn">再做一次</button>
  </div>

</div>
{% endblock %}

{% block head %}
{{ super() }}

<style>

/* ------- 页面容器 ------- */
.quiz-wrapper {
  max-width: 850px;
  margin: 0 auto;
  padding: 40px 20px;
}

/* ------- 标题 ------- */
.quiz-heading {
  text-align: center;
  font-size: 2.2em;
  margin-bottom: 30px;
  font-weight: 700;
  background: linear-gradient(90deg, #4facfe, #00f2fe);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}

/* ------- 进度条 ------- */
.quiz-progress {
  text-align: center;
  margin-bottom: 25px;
}
.quiz-progress .dot {
  display: inline-block;
  width: 12px;
  height: 12px;
  background: #d0d4d8;
  border-radius: 50%;
  margin: 0 6px;
  transition: .3s;
}
.quiz-progress .dot.active {
  background: #4facfe;
  transform: scale(1.3);
}

/* ------- 卡片 (玻璃拟态) ------- */
.quiz-card {
  background: rgba(255,255,255,0.35);
  backdrop-filter: blur(10px);
  border-radius: 20px;
  padding: 30px;
  box-shadow: 0 10px 25px rgba(0,0,0,.12);
  border: 1px solid rgba(255,255,255,0.4);
  transition: opacity .3s;
}

/* 淡入动画 */
.fade-in { animation: fadeIn .35s ease; }
@keyframes fadeIn {
  from {opacity:0; transform: translateY(10px);}
  to {opacity:1; transform: translateY(0);}
}

/* ------- 题目 ------- */
.quiz-stem {
  font-size: 1.35em;
  font-weight: 600;
  margin-bottom: 20px;
}

/* ------- 选项卡 Material 风格 ------- */
.quiz-option {
  background: white;
  padding: 14px 16px;
  border-radius: 14px;
  margin-bottom: 12px;
  border: 2px solid transparent;
  cursor: pointer;
  transition: .2s;
  position: relative;
  overflow: hidden;
}

/* 点击涟漪 */
.quiz-option::after {
  content:"";
  position:absolute;
  background:rgba(0,0,0,.08);
  border-radius:50%;
  transform:scale(0);
  width:120px; height:120px;
  opacity:0;
  transition:all .4s;
}
.quiz-option:active::after {
  transform:scale(1.8);
  opacity:1;
  left:var(--x); top:var(--y);
}

/* 选中效果 */
.quiz-option.selected {
  border-color: #4facfe;
  background: #f0f8ff;
  transform: scale(1.01);
}

/* ------- 答案框 ------- */
.quiz-answer {
  margin-top: 20px;
  background: #eef7ff;
  padding: 15px 20px;
  border-left: 4px solid #4facfe;
  border-radius: 10px;
}

/* ------- 按钮 ------- */
.btn {
  padding: 10px 20px;
  background: linear-gradient(90deg, #4facfe, #00f2fe);
  border: none;
  border-radius: 10px;
  color: white;
  font-size: 1em;
  cursor: pointer;
  transition: .2s;
}
.btn:hover { opacity: .85; }

.gray-btn {
  background: #bfc5ca;
}
.gray-btn:hover { opacity: .9; }

/* ------- 导航按钮区域 ------- */
.quiz-nav {
  display:flex;
  justify-content:space-between;
  margin-top:20px;
}

/* ------- 结果页卡片 ------- */
.quiz-result {
  text-align:center;
  padding:35px;
  background:white;
  border-radius:20px;
  margin-top:20px;
}

/* ------- 圆形进度条 ------- */
.score-circle {
  width:160px;
  height:160px;
  margin:20px auto;
  position:relative;
}
.score-circle svg {
  transform:rotate(-90deg);
}
.score-circle circle {
  fill:none;
  stroke-width:10;
}
.score-circle .bg {
  stroke:#eee;
}
.score-circle .progress {
  stroke:#4facfe;
  stroke-linecap:round;
  stroke-dasharray:283;
  stroke-dashoffset:283;
  transition:1s ease;
}
.score-text {
  position:absolute;
  top:50%; left:50%;
  transform:translate(-50%,-50%);
  font-size:2em;
  font-weight:600;
}

</style>

{% endblock %}

{% block script %}
<script>
const data = {{ page.questions | json }};
let index = 0;
let answers = data.map(()=>[]);

const card = document.querySelector("#quiz-card");
const stemEl = document.querySelector(".quiz-stem");
const optionBox = document.querySelector(".quiz-options");
const answerBox = document.querySelector(".quiz-answer");
const correctEl = document.querySelector(".quiz-correct");
const explainEl = document.querySelector(".quiz-explanation");
const dots = document.querySelectorAll(".quiz-progress .dot");

/* -------- 渲染题目 -------- */
function render() {
  const q = data[index];
  
  // 更新进度条
  dots.forEach((d,i)=>d.classList.toggle("active", i===index));

  stemEl.textContent = (index+1)+". "+q.stem;

  optionBox.innerHTML = "";
  answerBox.style.display = "none";

  q.options.forEach((opt,i)=>{
    const div = document.createElement("div");
    div.className = "quiz-option";
    div.innerText = String.fromCharCode(65+i)+". "+opt;

    // 涟漪位置捕获
    div.onmousedown = (e)=>{
      div.style.setProperty("--x", e.offsetX+"px");
      div.style.setProperty("--y", e.offsetY+"px");
    };

    if (answers[index].includes(i)) div.classList.add("selected");

    div.onclick = ()=>selectOption(i);
    optionBox.appendChild(div);
  });

  updateButtons();
}

/* -------- 选项选择 -------- */
function selectOption(i){
  const q = data[index];

  if (q.type === "single") {
    answers[index] = [i];
  } else {
    if (answers[index].includes(i))
      answers[index] = answers[index].filter(x=>x!==i)
    else
      answers[index].push(i);
  }

  render();
  showAnswer();
}

function arraysEq(a,b){
  return a.length === b.length && a.every(v=>b.includes(v));
}

/* -------- 显示答案框 -------- */
function showAnswer(){
  const q = data[index];
  answerBox.style.display = "block";

  correctEl.innerHTML =
    "<strong>正确答案：</strong> " +
    q.answer.map(i=>String.fromCharCode(65+i)).join(", ");

  explainEl.innerHTML = "<strong>解析：</strong> "+q.explanation;
}

/* -------- 切换题 -------- */
document.querySelector(".next-btn").onclick = ()=>{
  if (index < data.length-1){
    index++;
    card.classList.remove("fade-in");
    void card.offsetWidth; // 强制重绘
    card.classList.add("fade-in");
    render();
  }
};

document.querySelector(".prev-btn").onclick = ()=>{
  if (index > 0){
    index--;
    card.classList.remove("fade-in");
    void card.offsetWidth;
    card.classList.add("fade-in");
    render();
  }
};

/* -------- 提交 -------- */
document.querySelector(".submit-btn").onclick = ()=>{
  let score = 0;
  let correct = 0;

  data.forEach((q,i)=>{
    if (arraysEq(answers[i], q.answer)){
      score += q.score || 1;
      correct++;
    }
  });

  document.querySelector("#quiz-card").style.display="none";
  const result = document.querySelector("#quiz-result");
  result.style.display="block";

  // 圆环动画
  const circle = document.querySelector(".progress");
  const percent = score / data.reduce((s,q)=>s+(q.score||1),0);
  const offset = 283 * (1 - percent);
  circle.style.strokeDashoffset = offset;

  document.querySelector(".score-text").textContent = score;
  document.querySelector(".result-acc").textContent = 
    "正确率：" + Math.round(correct/data.length*100)+"%";
};

/* -------- 重做 -------- */
document.querySelector(".restart-btn").onclick = ()=>{
  answers = data.map(()=>[]);
  index=0;

  document.querySelector("#quiz-result").style.display="none";
  document.querySelector("#quiz-card").style.display="block";
  render();
};

function updateButtons(){
  document.querySelector(".prev-btn").style.display = index===0 ? "none" : "inline-block";
  document.querySelector(".next-btn").style.display = index===data.length-1 ? "none" : "inline-block";
  document.querySelector(".submit-btn").style.display = index===data.length-1 ? "inline-block" : "none";
}

render();

</script>
{% endblock %}
