const STORAGE_KEY = "heimdall.desktop.family.state.v1";
const DEFAULT_LANGUAGE = "ru";
const SUPPORTED_LANGUAGES = new Set(["ru", "en"]);

const I18N = {
  ru: {
    resetDemo: "Сбросить тест",
    notifications: "Уведомления",
    metricChildren: "детей",
    metricAlerts: "тревог",
    metricUnread: "новых",
    metricZones: "геозон",
    parentRole: "Родитель",
    pairingCode: "Код подключения",
    newCode: "Новый код",
    copyCode: "Копировать",
    safeZones: "Безопасные геозоны",
    zoneName: "Название",
    latitude: "Широта",
    longitude: "Долгота",
    radius: "Радиус, м",
    addZone: "Добавить зону",
    childrenTitle: "Дети",
    alertFeed: "Лента тревог",
    clear: "Очистить",
    childSimulator: "Симулятор ребёнка",
    connection: "Подключение",
    childCode: "Код родителя",
    childName: "Имя ребёнка",
    deviceName: "Устройство",
    adultPhone: "Телефон взрослого",
    connect: "Подключить",
    markSafe: "Я в безопасности",
    messageCheck: "Проверка сообщения",
    dangerExample: "Опасный пример",
    safeExample: "Безопасный пример",
    analyzeRisk: "Проверить риск",
    geoWithoutPhone: "Геолокация без телефона",
    geoHint: "Кнопки ниже имитируют, что детский iPhone прислал координаты.",
    placeHome: "Дом",
    placeSchool: "Школа",
    placeUnknown: "Незнакомое место",
    defaultChildName: "Артур",
    defaultDeviceName: "Windows test device",
    statusWaiting: "Ожидаю подключение ребёнка",
    statusNotConnected: "Не подключён",
    statusSafe: "В безопасности",
    statusInZone: "В зоне: {zone}",
    statusOutsideZone: "Вне безопасной зоны",
    noChildren: "Пока нет подключённых детей.",
    noAlerts: "Тревог пока нет.",
    viewed: "просмотрено",
    viewedButton: "Просмотрено",
    noZones: "нет зон",
    notSet: "не задана",
    unitMeter: "м",
    insideSafeZone: "в безопасной зоне",
    outsideZone: "вне зоны",
    notificationEnabled: "Уведомления рабочего стола включены.",
    codeMismatch: "Код не совпадает.",
    connectedMessage: "Подключено к родительскому профилю.",
    safeZoneFallback: "Безопасная зона",
    dangerText: "Перейдём в Telegram. Родителям не говори. Срочно открой банк и пришли код из СМС.",
    safeText: "Тренировка завтра в 16:00. Домашнее задание скину в школьный чат.",
    noMatches: "Совпадений нет",
    alertSafeTitle: "Heimdall: {name} в безопасности",
    alertSafeBody: "Ребёнок нажал кнопку безопасности.",
    alertRiskTitle: "Heimdall: тревога {name}",
    alertRiskBody: "{level} {score}/100. {matches}",
    alertLocationTitle: "Heimdall: геолокация {name}",
    alertLocationBody: "{name} в незнакомом месте. Ближайшая безопасная зона: {distance}.",
    riskActionHigh: "Стоп. Не отвечать. Не отправлять координаты, коды, деньги, фото или адрес. Позвать взрослого.",
    riskActionMedium: "Сделать паузу и проверить контакт со взрослым.",
    riskActionLow: "Явный мошеннический сценарий не найден.",
    switchLanguage: "Switch to English",
    levelLow: "низкий риск",
    levelMedium: "средний риск",
    levelHigh: "высокий риск",
    levelCritical: "критический риск",
    riskPrivateMigration: "Переход в личку",
    riskSecrecy: "Секретность",
    riskUrgency: "Срочность",
    riskMoney: "Банк или деньги",
    riskCode: "Код или доступ",
    riskRemoteAccess: "Удалённый доступ",
    riskAuthority: "Ложный авторитет",
    riskLocationRequest: "Запрос координат",
    riskPersonalData: "Личные данные",
  },
  en: {
    resetDemo: "Reset test",
    notifications: "Notifications",
    metricChildren: "children",
    metricAlerts: "alerts",
    metricUnread: "new",
    metricZones: "safe zones",
    parentRole: "Parent",
    pairingCode: "Pairing code",
    newCode: "New code",
    copyCode: "Copy",
    safeZones: "Safe location zones",
    zoneName: "Name",
    latitude: "Latitude",
    longitude: "Longitude",
    radius: "Radius, m",
    addZone: "Add zone",
    childrenTitle: "Children",
    alertFeed: "Alert feed",
    clear: "Clear",
    childSimulator: "Child simulator",
    connection: "Connection",
    childCode: "Parent code",
    childName: "Child name",
    deviceName: "Device",
    adultPhone: "Adult phone",
    connect: "Connect",
    markSafe: "I am safe",
    messageCheck: "Message check",
    dangerExample: "Danger example",
    safeExample: "Safe example",
    analyzeRisk: "Check risk",
    geoWithoutPhone: "Location without phones",
    geoHint: "These buttons simulate a child's iPhone sending coordinates.",
    placeHome: "Home",
    placeSchool: "School",
    placeUnknown: "Unknown place",
    defaultChildName: "Artur",
    defaultDeviceName: "Windows test device",
    statusWaiting: "Waiting for a child device",
    statusNotConnected: "Not connected",
    statusSafe: "Safe",
    statusInZone: "In zone: {zone}",
    statusOutsideZone: "Outside a safe zone",
    noChildren: "No connected children yet.",
    noAlerts: "No alerts yet.",
    viewed: "viewed",
    viewedButton: "Viewed",
    noZones: "no zones",
    notSet: "not set",
    unitMeter: "m",
    insideSafeZone: "inside a safe zone",
    outsideZone: "outside zone",
    notificationEnabled: "Desktop notifications are enabled.",
    codeMismatch: "The code does not match.",
    connectedMessage: "Connected to the parent profile.",
    safeZoneFallback: "Safe zone",
    dangerText: "Let's move to Telegram. Do not tell your parents. Open the bank app urgently and send the SMS code.",
    safeText: "Practice is tomorrow at 16:00. I will send homework to the school chat.",
    noMatches: "No matches",
    alertSafeTitle: "Heimdall: {name} is safe",
    alertSafeBody: "The child pressed the safety button.",
    alertRiskTitle: "Heimdall: alert for {name}",
    alertRiskBody: "{level} {score}/100. {matches}",
    alertLocationTitle: "Heimdall: {name} location",
    alertLocationBody: "{name} is in an unknown place. Nearest safe zone: {distance}.",
    riskActionHigh: "Stop. Do not reply. Do not send coordinates, codes, money, photos, or an address. Call a trusted adult.",
    riskActionMedium: "Pause and verify this contact with a trusted adult.",
    riskActionLow: "No clear scam pattern was detected.",
    switchLanguage: "Переключить на русский",
    levelLow: "low risk",
    levelMedium: "medium risk",
    levelHigh: "high risk",
    levelCritical: "critical risk",
    riskPrivateMigration: "Private chat migration",
    riskSecrecy: "Secrecy",
    riskUrgency: "Urgency",
    riskMoney: "Bank or money",
    riskCode: "Code or access",
    riskRemoteAccess: "Remote access",
    riskAuthority: "False authority",
    riskLocationRequest: "Location request",
    riskPersonalData: "Personal data",
  },
};

const RISK_LABEL_KEYS = {
  private_migration: "riskPrivateMigration",
  secrecy: "riskSecrecy",
  urgency: "riskUrgency",
  money: "riskMoney",
  code: "riskCode",
  remote_access: "riskRemoteAccess",
  authority: "riskAuthority",
  location_request: "riskLocationRequest",
  personal_data: "riskPersonalData",
};

const presets = {
  home: { nameKey: "placeHome", latitude: 55.7558, longitude: 37.6173 },
  school: { nameKey: "placeSchool", latitude: 55.759, longitude: 37.6201 },
  unknown: { nameKey: "placeUnknown", latitude: 55.8012, longitude: 37.4833 },
};

let state = normalizeState(loadState());

function defaultState() {
  return {
    language: null,
    pairingCode: makePairingCode(),
    connected: false,
    child: {
      name: "Артур",
      deviceName: "Windows test device",
      status: "Не подключён",
      statusKey: "notConnected",
      statusData: {},
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

function normalizeState(saved) {
  const fresh = defaultState();
  const source = saved && typeof saved === "object" ? saved : {};
  const normalized = {
    ...fresh,
    ...source,
    child: { ...fresh.child, ...(source.child || {}) },
    alerts: Array.isArray(source.alerts) ? source.alerts : fresh.alerts,
    safePlaces: Array.isArray(source.safePlaces) ? source.safePlaces : fresh.safePlaces,
  };

  normalized.language = SUPPORTED_LANGUAGES.has(normalized.language) ? normalized.language : null;
  if (!normalized.child.statusKey) {
    const rawStatus = String(normalized.child.status || "").toLowerCase();
    normalized.child.statusKey = normalized.connected && rawStatus.includes("безопас") ? "safe" : "custom";
  }
  if (!normalized.connected) {
    normalized.child.statusKey = "notConnected";
  }
  normalized.child.statusData = normalized.child.statusData || {};
  return normalized;
}

function loadState() {
  try {
    const raw = localStorage.getItem(STORAGE_KEY);
    return raw ? JSON.parse(raw) : null;
  } catch {
    return null;
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

function language() {
  return state.language || DEFAULT_LANGUAGE;
}

function locale() {
  return language() === "ru" ? "ru-RU" : "en-US";
}

function t(key, params = {}) {
  const dictionary = I18N[language()] || I18N[DEFAULT_LANGUAGE];
  let value = dictionary[key] ?? I18N[DEFAULT_LANGUAGE][key] ?? key;
  for (const [name, replacement] of Object.entries(params)) {
    value = value.replaceAll(`{${name}}`, String(replacement));
  }
  return value;
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
    { id: "private_migration", weight: 18, words: ["telegram", "телеграм", "tg", "тг", "личку", "личка", "private chat", "dm"] },
    { id: "secrecy", weight: 24, words: ["секрет", "не говори", "родителям не говори", "никому не говори", "secret", "do not tell", "don't tell"] },
    { id: "urgency", weight: 18, words: ["срочно", "быстро", "прямо сейчас", "иначе", "urgent", "right now", "quickly"] },
    { id: "money", weight: 30, words: ["банк", "карта", "перевод", "кредит", "деньги", "bank", "card", "transfer", "credit", "money"] },
    { id: "code", weight: 30, words: ["код", "пароль", "смс", "sms", "password", "confirmation code"] },
    { id: "remote_access", weight: 38, words: ["anydesk", "rustdesk", "teamviewer", "удалённый доступ", "удаленный доступ", "экран", "install app"] },
    { id: "authority", weight: 20, words: ["полиция", "фсб", "служба безопасности", "security service", "police", "bank security"] },
    { id: "location_request", weight: 70, words: ["coordinates", "coordinate", "send location", "share location", "location pin", "gps", "where are you", "send me where you are", "координат", "локацию", "геолокацию", "геопозицию", "местоположение", "пришли где ты", "скинь где ты"] },
    { id: "personal_data", weight: 18, words: ["адрес", "фото", "паспорт", "геолокация", "address", "photo", "passport"] },
  ];
  const matches = [];
  let score = 0;
  for (const trigger of triggers) {
    const evidence = trigger.words.find((word) => normalized.includes(word));
    if (evidence) {
      score += trigger.weight;
      matches.push({
        id: trigger.id,
        label: t(RISK_LABEL_KEYS[trigger.id]),
        weight: trigger.weight,
        evidence,
      });
    }
  }

  const hasAction = matches.some((m) => ["money", "code", "remote_access", "location_request", "personal_data"].includes(m.id));
  if (matches.some((m) => m.id === "secrecy") && hasAction) {
    score += 18;
  }
  if (matches.some((m) => m.id === "private_migration") && hasAction) {
    score += 10;
  }

  score = Math.min(score, 100);
  const level = score >= 75 ? "critical" : score >= 50 ? "high" : score >= 25 ? "medium" : "low";
  const action = level === "critical" || level === "high"
    ? t("riskActionHigh")
    : level === "medium"
      ? t("riskActionMedium")
      : t("riskActionLow");
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

function setChildStatus(statusKey, statusData = {}) {
  state.child.statusKey = statusKey;
  state.child.statusData = statusData;
  state.child.status = childStatusText();
}

function childStatusText() {
  const data = state.child.statusData || {};
  if (state.child.statusKey === "notConnected") return t("statusNotConnected");
  if (state.child.statusKey === "safe") return t("statusSafe");
  if (state.child.statusKey === "insideZone") return t("statusInZone", { zone: displayZoneName(data.zoneName) });
  if (state.child.statusKey === "outsideZone") return t("statusOutsideZone");
  if (state.child.statusKey === "risk") return `${levelLabel(data.level)} ${data.score}/100`;
  return state.child.status || t("statusNotConnected");
}

function simulateLocation(placeKey) {
  const point = presets[placeKey];
  const nearest = state.safePlaces
    .map((zone) => ({ zone, distance: distanceMeters(point, zone) }))
    .sort((a, b) => a.distance - b.distance)[0];

  const inside = nearest && nearest.distance <= nearest.zone.radiusMeters;
  state.latestLocation = {
    placeKey,
    latitude: point.latitude,
    longitude: point.longitude,
    at: new Date().toISOString(),
    inside,
    nearestName: nearest?.zone.name || t("noZones"),
  };
  setChildStatus(inside ? "insideZone" : "outsideZone", { zoneName: nearest?.zone.name });
  state.child.lastSeen = new Date().toISOString();
  saveState();

  if (!inside) {
    const distance = nearest ? `${Math.round(nearest.distance)} ${t("unitMeter")}` : t("notSet");
    addAlert(
      "location",
      t("alertLocationTitle", { name: state.child.name }),
      t("alertLocationBody", { name: state.child.name, distance }),
      "high"
    );
  } else {
    render();
  }
}

function renderLanguage() {
  document.documentElement.lang = language();
  document.querySelectorAll("[data-i18n]").forEach((element) => {
    element.textContent = t(element.dataset.i18n);
  });
  document.querySelectorAll("[data-i18n-placeholder]").forEach((element) => {
    element.setAttribute("placeholder", t(element.dataset.i18nPlaceholder));
  });

  const gate = $("languageGate");
  if (gate) gate.hidden = Boolean(state.language);
  const switcher = $("languageSwitch");
  if (switcher) {
    switcher.textContent = language() === "ru" ? "EN" : "RU";
    switcher.title = t("switchLanguage");
  }

  syncDefaultInput("zoneName", ["placeHome"]);
  syncDefaultInput("childName", ["defaultChildName"]);
  syncDefaultInput("deviceName", ["defaultDeviceName"]);
}

function syncDefaultInput(id, keys) {
  const input = $(id);
  if (!input || input.dataset.changed === "true") return;
  const knownValues = keys.flatMap((key) => [I18N.ru[key], I18N.en[key]]).filter(Boolean);
  if (!input.value || knownValues.includes(input.value)) {
    input.value = t(keys[0]);
  }
}

function displayZoneName(name) {
  const normalized = String(name || "").trim().toLowerCase();
  if (["дом", "home"].includes(normalized)) return t("placeHome");
  if (["школа", "school"].includes(normalized)) return t("placeSchool");
  if (["незнакомое место", "unknown place"].includes(normalized)) return t("placeUnknown");
  return name || t("notSet");
}

function placeName(placeKey) {
  const preset = presets[placeKey];
  return preset ? t(preset.nameKey) : t("placeUnknown");
}

function levelLabel(level) {
  const key = {
    low: "levelLow",
    medium: "levelMedium",
    high: "levelHigh",
    critical: "levelCritical",
  }[level];
  return t(key || "levelLow");
}

function render() {
  renderLanguage();
  $("pairingCode").textContent = state.pairingCode;
  $("childCode").value ||= state.pairingCode;
  $("childrenCount").textContent = state.connected ? "1" : "0";
  $("alertCount").textContent = String(state.alerts.length);
  $("unreadCount").textContent = String(state.alerts.filter((alert) => !alert.acknowledged).length);
  $("zoneCount").textContent = String(state.safePlaces.length);
  const currentStatus = childStatusText();
  $("familyStatus").textContent = state.connected ? `${state.child.name}: ${currentStatus}` : t("statusWaiting");
  $("childStatus").textContent = state.connected ? currentStatus : t("statusNotConnected");

  $("zones").innerHTML = state.safePlaces.map((zone) => `
    <div class="item">
      <strong>${escapeHtml(displayZoneName(zone.name))} · ${Math.round(zone.radiusMeters)} ${t("unitMeter")}</strong>
      <span>${zone.latitude.toFixed(5)}, ${zone.longitude.toFixed(5)}</span>
    </div>
  `).join("");

  $("children").innerHTML = state.connected
    ? `<div class="item"><strong>${escapeHtml(state.child.name)}</strong><span>${escapeHtml(state.child.deviceName)} · ${escapeHtml(currentStatus)}${state.child.lastSeen ? ` · ${new Date(state.child.lastSeen).toLocaleTimeString(locale())}` : ""}</span></div>`
    : t("noChildren");

  $("alerts").innerHTML = state.alerts.length
    ? state.alerts.map((alert) => `
      <div class="alert ${alert.level}">
        <strong>${escapeHtml(alert.title)}</strong>
        <span>${escapeHtml(alert.body)}</span>
        <span>${new Date(alert.createdAt).toLocaleTimeString(locale())}${alert.acknowledged ? ` · ${t("viewed")}` : ""}</span>
        <div class="alert-actions">
          <button class="small" data-ack="${alert.id}">${t("viewedButton")}</button>
        </div>
      </div>
    `).join("")
    : `<div class="muted-line">${t("noAlerts")}</div>`;

  if (state.latestLocation) {
    const latestName = state.latestLocation.placeKey ? placeName(state.latestLocation.placeKey) : displayZoneName(state.latestLocation.name);
    $("locationResult").innerHTML = `
      <strong>${escapeHtml(latestName)}</strong>
      <span>${state.latestLocation.latitude.toFixed(5)}, ${state.latestLocation.longitude.toFixed(5)} · ${state.latestLocation.inside ? t("insideSafeZone") : t("outsideZone")}</span>
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

function setLanguage(nextLanguage) {
  if (!SUPPORTED_LANGUAGES.has(nextLanguage)) return;
  const previousLanguage = language();
  state.language = nextLanguage;
  saveState();
  syncExampleText(previousLanguage, nextLanguage);
  $("riskResult").innerHTML = "";
  $("connectMessage").textContent = "";
  render();
}

function syncExampleText(previousLanguage, nextLanguage) {
  const textarea = $("messageText");
  if (!textarea) return;
  if (textarea.value === I18N[previousLanguage].dangerText) {
    textarea.value = I18N[nextLanguage].dangerText;
  } else if (textarea.value === I18N[previousLanguage].safeText) {
    textarea.value = I18N[nextLanguage].safeText;
  }
}

document.addEventListener("input", (event) => {
  if (event.target instanceof HTMLInputElement || event.target instanceof HTMLTextAreaElement) {
    event.target.dataset.changed = "true";
  }
});

document.addEventListener("click", (event) => {
  const target = event.target;
  if (!(target instanceof HTMLElement)) return;

  if (target.dataset.language) {
    setLanguage(target.dataset.language);
    return;
  }
  if (target.id === "languageSwitch") {
    setLanguage(language() === "ru" ? "en" : "ru");
    return;
  }
  if (target.id === "enableNotifications") {
    notify("Heimdall", t("notificationEnabled"));
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
      state.safePlaces.unshift({ id: crypto.randomUUID(), name: $("zoneName").value || t("safeZoneFallback"), latitude, longitude, radiusMeters });
      saveState();
      render();
    }
  }
  if (target.id === "connectChild") {
    if ($("childCode").value.trim().toUpperCase() !== state.pairingCode) {
      $("connectMessage").textContent = t("codeMismatch");
      return;
    }
    state.connected = true;
    state.child.name = $("childName").value || t("defaultChildName");
    state.child.deviceName = $("deviceName").value || t("defaultDeviceName");
    setChildStatus("safe");
    state.child.lastSeen = new Date().toISOString();
    $("connectMessage").textContent = t("connectedMessage");
    saveState();
    render();
  }
  if (target.id === "markSafe") {
    setChildStatus("safe");
    state.child.lastSeen = new Date().toISOString();
    addAlert("safe", t("alertSafeTitle", { name: state.child.name }), t("alertSafeBody"), "safe");
  }
  if (target.id === "dangerExample") {
    $("messageText").value = t("dangerText");
    $("messageText").dataset.changed = "true";
  }
  if (target.id === "safeExample") {
    $("messageText").value = t("safeText");
    $("messageText").dataset.changed = "true";
  }
  if (target.id === "clearMessage") {
    $("messageText").value = "";
    $("riskResult").innerHTML = "";
  }
  if (target.id === "analyzeMessage") {
    const result = analyzeRisk($("messageText").value);
    $("riskResult").innerHTML = `
      <div class="risk-score"><b>${result.score}</b><strong>${escapeHtml(levelLabel(result.level))}</strong></div>
      <p>${escapeHtml(result.action)}</p>
      <div class="match-list">${result.matches.map((match) => `${escapeHtml(match.label)} +${match.weight}`).join("<br>") || t("noMatches")}</div>
    `;
    if (result.score >= 50) {
      setChildStatus("risk", { level: result.level, score: result.score });
      state.child.lastSeen = new Date().toISOString();
      const matches = result.matches.map((m) => m.label).join(", ") || t("noMatches");
      addAlert(
        "risk",
        t("alertRiskTitle", { name: state.child.name }),
        t("alertRiskBody", { level: levelLabel(result.level), score: result.score, matches }),
        result.level
      );
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
    const currentLanguage = state.language;
    state = defaultState();
    state.language = currentLanguage;
    localStorage.removeItem(STORAGE_KEY);
    $("riskResult").innerHTML = "";
    $("locationResult").innerHTML = "";
    $("connectMessage").textContent = "";
    $("messageText").value = t("dangerText");
    saveState();
    render();
  }
});

$("messageText").value = t("dangerText");
render();
