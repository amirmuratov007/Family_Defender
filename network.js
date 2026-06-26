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
const copy = isRu ? { on: "включено", off: "выключено" } : { on: "on", off: "off" };
const riskScore = document.querySelector("#riskScore");

document.querySelectorAll(".profile").forEach(button => {
  button.addEventListener("click", () => {
    document.querySelectorAll(".profile").forEach(item => item.classList.remove("active"));
    button.classList.add("active");
    if (riskScore) riskScore.textContent = button.dataset.risk || "";
  });
});

document.querySelectorAll(".policy input").forEach(input => {
  const label = input.closest(".policy");
  const state = label ? label.querySelector("em") : null;
  input.addEventListener("change", () => {
    if (state) state.textContent = input.checked ? copy.on : copy.off;
  });
});

if ("serviceWorker" in navigator) {
  navigator.serviceWorker.register("service-worker.js").catch(() => {});
}
