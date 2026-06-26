(function initHeimdallRiskConsole() {
  const setupForm = document.querySelector("[data-setup-form]");
  const riskText = document.querySelector("#riskText");
  const analyzeRiskBtn = document.querySelector("#analyzeRiskBtn");

  if (!setupForm && !riskText && !analyzeRiskBtn) return;

  const lang = document.documentElement.lang === "ru" ? "ru" : "en";
  const storageKey = "heimdall.family.test.v1";

  const copy = {
    ru: {
      defaultFamilyTitle: "Семья пока не добавлена",
      defaultFamilyCopy: "После настройки родителем здесь появятся реальные iPhone, имена и статусы. Выдуманных детей на экране больше нет.",
      noProfile: "Не выбран",
      noDevicesTitle: "Нет подключенных iPhone",
      noDevicesText: "Устройство появится здесь после установки Heimdall и подтверждения родителем.",
      setupSaved: "Локальный тест создан. Теперь проверьте подозрительное сообщение.",
      setupEmpty: "Локальный профиль ещё не создан.",
      connected: "Подключён локальный тест",
      trustedAdult: "Доверенный взрослый",
      levels: {
        critical: "Критический риск",
        high: "Высокий риск",
        medium: "Средний риск",
        low: "Низкий риск"
      },
      actions: {
        critical: "Стоп. Не отправляйте коды, деньги, фото, адрес и не устанавливайте приложения. Позовите доверенного взрослого.",
        high: "Стоп. Не отправляйте коды, деньги, фото, адрес и не устанавливайте приложения. Позовите доверенного взрослого.",
        medium: "Сделайте паузу и проверьте контакт вместе с доверенным взрослым.",
        low: "Явный мошеннический сценарий в этом фрагменте не найден."
      },
      reasons: {
        new_contact: "новый контакт",
        private_migration: "переход в личку",
        secrecy: "секретность",
        urgency: "срочность",
        money: "банк или деньги",
        code: "код или доступ",
        remote_access: "удалённый доступ",
        authority: "ложный авторитет",
        personal_data: "личные данные"
      },
      noReasons: "Сильные признаки риска не найдены",
      alertEmptyTitle: "Тревог пока нет",
      alertEmptyText: "Высокий риск появится здесь после проверки сообщения.",
      alertPrefix: "Риск",
      reset: "Локальный тест сброшен.",
      networkError: "Не удалось проверить сообщение. Проверьте локальный сервер."
    },
    en: {
      defaultFamilyTitle: "No family members added yet",
      defaultFamilyCopy: "Real iPhones, names and statuses will appear here only after parent setup. There are no fake children on this screen.",
      noProfile: "Not selected",
      noDevicesTitle: "No connected iPhones",
      noDevicesText: "The device will appear here after Heimdall is installed and approved by the parent.",
      setupSaved: "Local test created. Now check a suspicious message.",
      setupEmpty: "No local profile yet.",
      connected: "Local test connected",
      trustedAdult: "Trusted adult",
      levels: {
        critical: "Critical risk",
        high: "High risk",
        medium: "Medium risk",
        low: "Low risk"
      },
      actions: {
        critical: "Stop. Do not send codes, money, photos, address or install apps. Call a trusted adult.",
        high: "Stop. Do not send codes, money, photos, address or install apps. Call a trusted adult.",
        medium: "Pause and verify this contact with a trusted adult.",
        low: "No clear scam pattern was detected in this fragment."
      },
      reasons: {
        new_contact: "new contact",
        private_migration: "private chat migration",
        secrecy: "secrecy",
        urgency: "urgency",
        money: "bank or money",
        code: "code or access",
        remote_access: "remote access",
        authority: "false authority",
        personal_data: "personal data"
      },
      noReasons: "No strong risk signals found",
      alertEmptyTitle: "No alerts yet",
      alertEmptyText: "High risk checks will appear here.",
      alertPrefix: "Risk",
      reset: "Local test reset.",
      networkError: "Could not check the message. Verify the local server."
    }
  }[lang];

  const dangerousExample = lang === "ru"
    ? "Перейдём в Telegram. Родителям не говори. Срочно открой банк и пришли код из СМС."
    : "Move to Telegram. Do not tell your parents. Open the bank app right now and send the SMS code.";

  const safeExample = lang === "ru"
    ? "Тренировка завтра в 16:00. Домашнее задание скину в школьный чат."
    : "Practice is tomorrow at 4 PM. I will send the homework to the school chat.";

  function readState() {
    try {
      return JSON.parse(localStorage.getItem(storageKey)) || { alerts: [] };
    } catch {
      return { alerts: [] };
    }
  }

  function writeState(state) {
    localStorage.setItem(storageKey, JSON.stringify({ ...state, alerts: state.alerts || [] }));
  }

  function setText(selector, value) {
    const element = document.querySelector(selector);
    if (element) element.textContent = value;
  }

  function reasonLabel(match) {
    return copy.reasons[match.id] || match.label || match.id;
  }

  function renderState() {
    const state = readState();
    const hasDevice = Boolean(state.childName || state.deviceName);
    setText("[data-family-device-count]", hasDevice ? "1" : "0");
    setText("[data-family-profile]", hasDevice ? (state.childName || state.deviceName) : copy.noProfile);
    setText("[data-family-title]", hasDevice ? copy.connected : copy.defaultFamilyTitle);
    setText(
      "[data-family-copy]",
      hasDevice
        ? `${state.childName || "Child"} · ${state.deviceName || "iPhone"} · ${copy.trustedAdult}: ${state.trustedAdult || "—"}`
        : copy.defaultFamilyCopy
    );
    setText("[data-setup-status]", hasDevice ? copy.setupSaved : copy.setupEmpty);

    const deviceList = document.querySelector("[data-device-list]");
    if (deviceList) {
      deviceList.innerHTML = hasDevice
        ? `<strong>${escapeHtml(state.deviceName || "iPhone")}</strong><p>${escapeHtml(state.childName || "Child")} · ${escapeHtml(state.trustedAdult || copy.trustedAdult)}</p>`
        : `<strong>${copy.noDevicesTitle}</strong><p>${copy.noDevicesText}</p>`;
    }

    renderAlerts(state.alerts || []);
  }

  function renderAlerts(alerts) {
    const feed = document.querySelector("[data-alert-feed]");
    if (!feed) return;
    if (!alerts.length) {
      feed.innerHTML = `<div class="empty-state"><strong>${copy.alertEmptyTitle}</strong><p>${copy.alertEmptyText}</p></div>`;
      return;
    }
    feed.innerHTML = alerts
      .slice(0, 5)
      .map(alert => `
        <article class="alert-item">
          <strong>${copy.alertPrefix} ${alert.score}/100 · ${copy.levels[alert.level] || alert.level}</strong>
          <span>${escapeHtml(alert.reasons.join(", "))}</span>
          <time>${escapeHtml(alert.time)}</time>
        </article>
      `)
      .join("");
  }

  function renderRisk(result) {
    setText("[data-risk-score]", String(result.score));
    setText("[data-risk-level]", copy.levels[result.level] || result.level);
    setText("[data-risk-action]", copy.actions[result.level] || result.action);
    const chips = document.querySelector("[data-risk-matches]");
    if (chips) {
      const matches = result.matches || [];
      chips.innerHTML = matches.length
        ? matches.map(match => `<span class="chip">${reasonLabel(match)} +${match.weight}</span>`).join("")
        : `<span class="chip">${copy.noReasons}</span>`;
    }
  }

  function rememberAlert(result) {
    if (result.score < 50) return;
    const state = readState();
    const reasons = (result.matches || []).map(reasonLabel);
    state.alerts = [
      {
        score: result.score,
        level: result.level,
        reasons: reasons.length ? reasons : [copy.noReasons],
        time: new Date().toLocaleString(lang === "ru" ? "ru-RU" : "en-US")
      },
      ...(state.alerts || [])
    ].slice(0, 10);
    writeState(state);
    renderState();
  }

  function escapeHtml(value) {
    return String(value)
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  }

  if (setupForm) {
    setupForm.addEventListener("submit", event => {
      event.preventDefault();
      const formData = new FormData(setupForm);
      const state = readState();
      state.childName = String(formData.get("childName") || "").trim();
      state.deviceName = String(formData.get("deviceName") || "").trim();
      state.trustedAdult = String(formData.get("trustedAdult") || "").trim();
      writeState(state);
      renderState();
    });
  }

  if (document.querySelector("#loadSafeBtn")) {
    document.querySelector("#loadSafeBtn").addEventListener("click", () => {
      riskText.value = safeExample;
    });
  }

  const clearLocal = document.querySelector("[data-clear-local]");
  if (clearLocal) {
    clearLocal.addEventListener("click", () => {
      localStorage.removeItem(storageKey);
      if (riskText) riskText.value = dangerousExample;
      renderState();
      setText("[data-setup-status]", copy.reset);
    });
  }

  if (analyzeRiskBtn && riskText) {
    analyzeRiskBtn.addEventListener("click", async () => {
      analyzeRiskBtn.setAttribute("aria-busy", "true");
      try {
        const response = await fetch("/api/analyze", {
          method: "POST",
          headers: { "content-type": "application/json" },
          body: JSON.stringify({ text: riskText.value })
        });
        if (!response.ok) throw new Error(`HTTP ${response.status}`);
        const result = await response.json();
        renderRisk(result);
        rememberAlert(result);
      } catch {
        renderRisk({ score: 0, level: "low", matches: [], action: copy.networkError });
        setText("[data-risk-action]", copy.networkError);
      } finally {
        analyzeRiskBtn.removeAttribute("aria-busy");
      }
    });
  }

  if (riskText && !riskText.value.trim()) riskText.value = dangerousExample;
  renderState();
})();
