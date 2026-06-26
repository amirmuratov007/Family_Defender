const canvas = document.querySelector("#net");

if (canvas) {
  const ctx = canvas.getContext("2d");
  let points = [];
  let frame;

  function resize() {
    const ratio = window.devicePixelRatio || 1;
    canvas.width = Math.floor(innerWidth * ratio);
    canvas.height = Math.floor(innerHeight * ratio);
    canvas.style.width = `${innerWidth}px`;
    canvas.style.height = `${innerHeight}px`;
    ctx.setTransform(ratio, 0, 0, ratio, 0, 0);
    const count = Math.min(120, Math.max(52, Math.floor(innerWidth / 12)));
    points = Array.from({ length: count }, () => ({
      x: Math.random() * innerWidth,
      y: Math.random() * innerHeight,
      vx: (Math.random() - 0.5) * 0.28,
      vy: (Math.random() - 0.5) * 0.28
    }));
  }

  function draw() {
    ctx.clearRect(0, 0, innerWidth, innerHeight);

    for (const point of points) {
      point.x += point.vx;
      point.y += point.vy;
      if (point.x < -20) point.x = innerWidth + 20;
      if (point.x > innerWidth + 20) point.x = -20;
      if (point.y < -20) point.y = innerHeight + 20;
      if (point.y > innerHeight + 20) point.y = -20;
    }

    for (let i = 0; i < points.length; i += 1) {
      for (let j = i + 1; j < points.length; j += 1) {
        const a = points[i];
        const b = points[j];
        const distance = Math.hypot(a.x - b.x, a.y - b.y);
        if (distance < 150) {
          ctx.strokeStyle = `rgba(212,164,66,${(1 - distance / 150) * 0.18})`;
          ctx.beginPath();
          ctx.moveTo(a.x, a.y);
          ctx.lineTo(b.x, b.y);
          ctx.stroke();
        }
      }
    }

    for (const point of points) {
      const glow = ctx.createRadialGradient(point.x, point.y, 0, point.x, point.y, 10);
      glow.addColorStop(0, "rgba(244,217,138,.9)");
      glow.addColorStop(1, "rgba(212,164,66,0)");
      ctx.fillStyle = glow;
      ctx.beginPath();
      ctx.arc(point.x, point.y, 10, 0, Math.PI * 2);
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
