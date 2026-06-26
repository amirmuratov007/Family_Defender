const canvas = document.querySelector("#net");
if (canvas) {
  const ctx = canvas.getContext("2d");
  let points = [];
  let frame = 0;

  function resize() {
    const ratio = window.devicePixelRatio || 1;
    canvas.width = innerWidth * ratio;
    canvas.height = innerHeight * ratio;
    canvas.style.width = innerWidth + "px";
    canvas.style.height = innerHeight + "px";
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    const count = Math.min(130, Math.max(56, Math.floor(innerWidth / 12)));
    points = Array.from({ length: count }, () => ({
      x: Math.random() * innerWidth,
      y: Math.random() * innerHeight,
      vx: (Math.random() - 0.5) * 0.32,
      vy: (Math.random() - 0.5) * 0.32
    }));
  }

  function draw() {
    ctx.clearRect(0, 0, innerWidth, innerHeight);
    for (const point of points) {
      point.x += point.vx;
      point.y += point.vy;
      if (point.x < -24) point.x = innerWidth + 24;
      if (point.x > innerWidth + 24) point.x = -24;
      if (point.y < -24) point.y = innerHeight + 24;
      if (point.y > innerHeight + 24) point.y = -24;
    }

    for (let i = 0; i < points.length; i++) {
      for (let j = i + 1; j < points.length; j++) {
        const a = points[i];
        const b = points[j];
        const distance = Math.hypot(a.x - b.x, a.y - b.y);
        if (distance < 145) {
          ctx.strokeStyle = `rgba(216,172,77,${(1 - distance / 145) * 0.2})`;
          ctx.lineWidth = 1;
          ctx.beginPath();
          ctx.moveTo(a.x, a.y);
          ctx.lineTo(b.x, b.y);
          ctx.stroke();
        }
      }
    }

    for (const point of points) {
      const glow = ctx.createRadialGradient(point.x, point.y, 0, point.x, point.y, 12);
      glow.addColorStop(0, "rgba(255,231,163,.85)");
      glow.addColorStop(1, "rgba(216,172,77,0)");
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(point.x, point.y, 12, 0, Math.PI * 2);
      ctx.fill();
    }
    frame = requestAnimationFrame(draw);
  }

  resize();
  draw();
  addEventListener("resize", () => {
    cancelAnimationFrame(frame);
    resize();
    draw();
  });
}

const isRu = document.documentElement.lang === "ru";
const riskCopy = isRu ? {
  low: ["Низкий риск", "Связка пока слабая, но событие сохранено в журнале."],
  mid: ["Средний риск", "Есть признаки давления. Лучше проверить контакт и ограничить действие."],
  high: ["Высокий риск", "Связка событий похожа на вербовку или мошенничество. Родителю нужно остановить действие и позвонить."],
  max: ["Критический риск", "Нужно немедленно остановить код, перевод, установку приложения или удаленный доступ."],
  on: "включено",
  off: "выключено"
} : {
  low: ["Low risk", "The chain is weak so far, but the event is stored in the log."],
  mid: ["Medium risk", "Pressure signals exist. Verify the contact and restrict the action."],
  high: ["High risk", "This event chain resembles grooming or fraud. The parent should stop the action and call."],
  max: ["Critical risk", "Immediately stop the code, transfer, app install or remote access."],
  on: "on",
  off: "off"
};

const riskScore = document.querySelector("#riskScore");
document.querySelectorAll(".profile").forEach(button => {
  button.addEventListener("click", () => {
    document.querySelectorAll(".profile").forEach(item => item.classList.remove("active"));
    button.classList.add("active");
    if (riskScore) riskScore.textContent = button.dataset.risk || "0";
  });
});

document.querySelectorAll(".policy input").forEach(input => {
  const label = input.closest(".policy");
  const state = label ? label.querySelector("em") : null;
  input.addEventListener("change", () => {
    if (state) state.textContent = input.checked ? riskCopy.on : riskCopy.off;
  });
});

const scenarioButtons = [...document.querySelectorAll(".scenario")];
const simRisk = document.querySelector("#simRisk");
const simTitle = document.querySelector("#simTitle");
const simText = document.querySelector("#simText");
const simChips = document.querySelector("#simChips");

function renderScenario() {
  if (!scenarioButtons.length || !simRisk) return;
  const active = scenarioButtons.filter(button => button.classList.contains("active"));
  const score = Math.min(100, active.reduce((sum, button) => sum + Number(button.dataset.risk || 0), 0));
  const level = score >= 90 ? riskCopy.max : score >= 65 ? riskCopy.high : score >= 35 ? riskCopy.mid : riskCopy.low;
  simRisk.textContent = String(score);
  if (simTitle) simTitle.textContent = level[0];
  if (simText) simText.textContent = level[1];
  if (simChips) simChips.innerHTML = active.map(button => `<span class="chip">${button.dataset.label}</span>`).join("");
}

scenarioButtons.forEach(button => {
  button.addEventListener("click", () => {
    button.classList.toggle("active");
    renderScenario();
  });
});
renderScenario();

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("service-worker.js").catch(() => {});
}
