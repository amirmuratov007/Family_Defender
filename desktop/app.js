const STORAGE_KEY = "heimdall.desktop.family.state.v1";

const dangerText = "Перейдём в Telegram. Родителям не говори. Срочно открой банк и пришли код из СМС.";
const safeText = "Тренировка завтра в 16:00. Домашнее задание скину в школьный чат.";

const presets = {
  home: { name: "Дом", latitude: 55.7558, longitude: 37.6173 },
  school: { name: "Школа", latitude: 55.759, longitude: 37.6201 },
  unknown: { name: "Незнакомое место", latitude: 55.8012, longitude: 37.4833 },
};

let state = loadState();

function defaultState() {
  return {
    pairingCode: makePairingCode(),
    connected: false,
    child: {
      name: "Артур",
      deviceName: "Windows test device",
      status: "Не подключён",
      lastSeen: null,
    },
    alerts: [],
    safePlaces: [
      { id: crypto.randomUUID(), name: "Дом", latitude: 55.7558, longitude: 37.6173, radiusMeters: 600 },
      { id: crypto.randomUUID(), name: "Школа", latitude: 55.759, longitude: 37.6201, radiusMeters: 500 },
    ],
    latestLocation: null,
  };
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : defaultState();
  } catch {
    return defaultState();
  }
}

function saveState() {
  localStorage.setItem(STORAGE_KEY, JSON.stringify(state));
}

function makePairingCode() {
  const alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789";
  return Array.from({ length: 6 }, () => alphabet[Math.floor(Math.random() * alphabet.length)]).join("");
}

function $(id) {
  return document.getElementById(id);
}

function notify(title, body) {
  if (window.heimdallDesktop?.notify) {
    window.heimdallDesktop.notify({ title, body });
  }
}

function addAlert(type, title, body, level = "high") {
  const alert = {
    id: crypto.randomUUID(),
    type,
    title,
    body,
    level,
    createdAt: new Date().toISOString(),
    acknowledged: false,
  };
  state.alerts.unshift(alert);
  state.alerts = state.alerts.slice(0, 30);
  saveState();
  render();
  notify(title, body);
}

function analyzeRisk(text) {
  const normalized = String(text || "").toLowerCase();
  const triggers = [
    ["private_migration", "Переход в личку", 18, ["telegram", "телеграм", "tg", "тг", "личку", "личка"]],
    ["secrecy", "Секретность", 24, ["секрет", "не говори", "родителям не говори", "никому не говори", "do not tell"]],
    ["urgency", "Срочность", 18, ["срочно", "быстро", "прямо сейчас", "иначе", "urgent"]],
    ["money", "Банк или деньги", 30, ["банк", "карта", "перевод", "кредит", "деньги", "bank", "card"]],
    ["code", "Код или доступ", 30, ["код", "пароль", "смс", "sms", "password"]],
    ["remote_access", "Удалённый доступ", 38, ["anydesk", "rustdesk", "teamviewer", "удалённый доступ", "экран"]],
    ["authority", "Ложный авторитет", 20, ["полиция", "фсб", "служба безопасности", "security service"]],
    ["personal_data", "Личные данные", 18, ["адрес", "фото", "паспорт", "геолокация", "address", "photo"]],
  ];
  const matches = [];
  let score = 0;
  for (const [id, label, weight, words] of triggers) {
    const evidence = words.find((word) => normalized.includes(word));
    if (evidence) {
      score += weight;
      matches.push({ id, label, weight, evidence });
    }
  }
  if (matches.some((m) => m.id === "secrecy") && matches.some((m) => ["money", "code", "remote_access", "personal_data"].includes(m.id))) {
    score += 18;
  }
  if (matches.some((m) => m.id === "private_migration") && matches.some((m) => ["money", "code", "remote_access", "personal_data"].includes(m.id))) {
    score += 10;
  }
  score = Math.min(score, 100);
  const level = score >= 75 ? "critical" : score >= 50 ? "high" : score >= 25 ? "medium" : "low";
  const action = level === "critical" || level === "high"
    ? "Не отвечать. Не отправлять коды, деньги, фото, адрес. Позвать взрослого."
    : level === "medium"
      ? "Сделать паузу и проверить контакт со взрослым."
      : "Явный мошеннический сценарий не найден.";
  return { score, level, matches, action };
}

function distanceMeters(a, b) {
  const radius = 6371000;
  const lat1 = a.latitude * Math.PI / 180;
  const lat2 = b.latitude * Math.PI / 180;
  const dLat = (b.latitude - a.latitude) * Math.PI / 180;
  const dLng = (b.longitude - a.longitude) * Math.PI / 180;
  const h = Math.sin(dLat / 2) ** 2 + Math.cos(lat1) * Math.cos(lat2) * Math.sin(dLng / 2) ** 2;
  return 2 * radius * Math.atan2(Math.sqrt(h), Math.sqrt(1 - h));
}

function simulateLocation(placeKey) {
  const point = presets[placeKey];
  const nearest = state.safePlaces
    .map((zone) => ({ zone, distance: distanceMeters(point, zone) }))
    .sort((a, b) => a.distance - b.distance)[0];

  const inside = nearest && nearest.distance <= nearest.zone.radiusMeters;
  state.latestLocation = { ...point, at: new Date().toISOString(), inside, nearestName: nearest?.zone.name || "нет зон" };
  state.child.status = inside ? `В зоне: ${nearest.zone.name}` : "Вне безопасной зоны";
  state.child.lastSeen = new Date().toISOString();
  saveState();

  if (!inside) {
    addAlert(
      "location",
      `Heimdall: геолокация ${state.child.name}`,
      `${state.child.name} в незнакомом месте. Ближайшая безопасная зона: ${nearest ? `${Math.round(nearest.distance)} м` : "не задана"}.`,
      "high"
    );
  } else {
    render();
  }
}

function render() {
  $("pairingCode").textContent = state.pairingCode;
  $("childCode").value ||= state.pairingCode;
  $("childrenCount").textContent = state.connected ? "1" : "0";
  $("alertCount").textContent = String(state.alerts.length);
  $("unreadCount").textContent = String(state.alerts.filter((alert) => !alert.acknowledged).length);
  $("zoneCount").textContent = String(state.safePlaces.length);
  $("familyStatus").textContent = state.connected ? `${state.child.name}: ${state.child.status}` : "Ожидаю подключение ребёнка";
  $("childStatus").textContent = state.connected ? state.child.status : "Не подключён";

  $("zones").innerHTML = state.safePlaces.map((zone) => `
    <div class="item">
      <strong>${escapeHtml(zone.name)} · ${Math.round(zone.radiusMeters)} м</strong>
      <span>${zone.latitude.toFixed(5)}, ${zone.longitude.toFixed(5)}</span>
    </div>
  `).join("");

  $("children").innerHTML = state.connected
    ? `<div class="item"><strong>${escapeHtml(state.child.name)}</strong><span>${escapeHtml(state.child.deviceName)} · ${escapeHtml(state.child.status)}${state.child.lastSeen ? ` · ${new Date(state.child.lastSeen).toLocaleTimeString("ru-RU")}` : ""}</span></div>`
    : "Пока нет подключённых детей.";

  $("alerts").innerHTML = state.alerts.length
    ? state.alerts.map((alert) => `
      <div class="alert ${alert.level}">
        <strong>${escapeHtml(alert.title)}</strong>
        <span>${escapeHtml(alert.body)}</span>
        <span>${new Date(alert.createdAt).toLocaleTimeString("ru-RU")}${alert.acknowledged ? " · просмотрено" : ""}</span>
        <div class="alert-actions">
          <button class="small" data-ack="${alert.id}">Просмотрено</button>
        </div>
      </div>
    `).join("")
    : `<div class="muted-line">Тревог пока нет.</div>`;

  if (state.latestLocation) {
    $("locationResult").innerHTML = `
      <strong>${escapeHtml(state.latestLocation.name)}</strong>
      <span>${state.latestLocation.latitude.toFixed(5)}, ${state.latestLocation.longitude.toFixed(5)} · ${state.latestLocation.inside ? "в безопасной зоне" : "вне зоны"}</span>
    `;
  }
}

function escapeHtml(value) {
  return String(value).replace(/[&<>"']/g, (char) => ({
    "&": "&amp;",
    "<": "&lt;",
    ">": "&gt;",
    '"': "&quot;",
    "'": "&#39;",
  }[char]));
}

document.addEventListener("click", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;

  if (target.id === "enableNotifications") {
    notify("Heimdall", "Уведомления рабочего стола включены.");
  }
  if (target.id === "newCode") {
    state.pairingCode = makePairingCode();
    saveState();
    render();
  }
  if (target.id === "copyCode") {
    navigator.clipboard.writeText(state.pairingCode);
  }
  if (target.id === "addZone") {
    const latitude = Number($("zoneLat").value.replace(",", "."));
    const longitude = Number($("zoneLng").value.replace(",", "."));
    const radiusMeters = Number($("zoneRadius").value.replace(",", ".")) || 600;
    if (Number.isFinite(latitude) && Number.isFinite(longitude)) {
      state.safePlaces.unshift({ id: crypto.randomUUID(), name: $("zoneName").value || "Безопасная зона", latitude, longitude, radiusMeters });
      saveState();
      render();
    }
  }
  if (target.id === "connectChild") {
    if ($("childCode").value.trim().toUpperCase() !== state.pairingCode) {
      $("connectMessage").textContent = "Код не совпадает.";
      return;
    }
    state.connected = true;
    state.child.name = $("childName").value || "Ребёнок";
    state.child.deviceName = $("deviceName").value || "Windows test device";
    state.child.status = "В безопасности";
    state.child.lastSeen = new Date().toISOString();
    $("connectMessage").textContent = "Подключено к родительскому профилю.";
    saveState();
    render();
  }
  if (target.id === "markSafe") {
    state.child.status = "В безопасности";
    state.child.lastSeen = new Date().toISOString();
    addAlert("safe", `Heimdall: ${state.child.name} в безопасности`, "Ребёнок нажал кнопку безопасности.", "safe");
  }
  if (target.id === "dangerExample") {
    $("messageText").value = dangerText;
  }
  if (target.id === "safeExample") {
    $("messageText").value = safeText;
  }
  if (target.id === "clearMessage") {
    $("messageText").value = "";
    $("riskResult").innerHTML = "";
  }
  if (target.id === "analyzeMessage") {
    const result = analyzeRisk($("messageText").value);
    $("riskResult").innerHTML = `
      <div class="risk-score"><b>${result.score}</b><strong>${result.level}</strong></div>
      <p>${escapeHtml(result.action)}</p>
      <div class="match-list">${result.matches.map((match) => `${escapeHtml(match.label)} +${match.weight}`).join("<br>") || "Совпадений нет"}</div>
    `;
    if (result.score >= 50) {
      state.child.status = `${result.level} ${result.score}/100`;
      state.child.lastSeen = new Date().toISOString();
      addAlert("risk", `Heimdall: тревога ${state.child.name}`, `${result.level} ${result.score}/100. ${result.matches.map((m) => m.label).join(", ")}`, result.level);
    }
  }
  if (target.dataset.place) {
    simulateLocation(target.dataset.place);
  }
  if (target.dataset.ack) {
    state.alerts = state.alerts.map((alert) => alert.id === target.dataset.ack ? { ...alert, acknowledged: true } : alert);
    saveState();
    render();
  }
  if (target.id === "clearAlerts") {
    state.alerts = [];
    saveState();
    render();
  }
  if (target.id === "resetDemo") {
    state = defaultState();
    localStorage.removeItem(STORAGE_KEY);
    $("riskResult").innerHTML = "";
    $("locationResult").innerHTML = "";
    $("connectMessage").textContent = "";
    render();
  }
});

$("messageText").value = dangerText;
render();
