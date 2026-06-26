const TRIGGERS = [
  { id: "new_contact", label: "new contact", weight: 12, words: ["new contact", "unknown", "незнаком", "новый контакт"] },
  { id: "private_migration", label: "private chat migration", weight: 18, words: ["telegram", "телеграм", "tg", "тг", "private chat", "личку", "личка", "dm"] },
  { id: "secrecy", label: "secrecy", weight: 24, words: ["secret", "do not tell", "don't tell", "никому", "секрет", "не говори", "родителям не говори"] },
  { id: "urgency", label: "urgency", weight: 18, words: ["urgent", "right now", "quickly", "срочно", "быстро", "прямо сейчас", "иначе"] },
  { id: "money", label: "bank or money", weight: 30, words: ["bank", "card", "transfer", "credit", "банк", "карта", "перевод", "кредит", "деньги"] },
  { id: "code", label: "code or access", weight: 30, words: ["code", "password", "sms", "код", "пароль", "смс", "подтверди"] },
  { id: "remote_access", label: "remote access", weight: 38, words: ["anydesk", "rustdesk", "teamviewer", "удаленный доступ", "установи приложение"] },
  { id: "authority", label: "false authority", weight: 20, words: ["police", "security service", "bank security", "полиция", "фсб", "служба безопасности"] },
  { id: "personal_data", label: "personal data", weight: 18, words: ["address", "photo", "passport", "адрес", "фото", "паспорт", "геолокация"] }
];

function normalizeText(text) {
  return String(text || "").toLowerCase().replace(/\s+/g, " ").trim();
}

function analyzeRisk(text) {
  const normalized = normalizeText(text);
  const matches = [];
  let score = 0;

  for (const trigger of TRIGGERS) {
    const hit = trigger.words.find(word => normalized.includes(word));
    if (hit) {
      score += trigger.weight;
      matches.push({ id: trigger.id, label: trigger.label, evidence: hit, weight: trigger.weight });
    }
  }

  const hasSecrecy = matches.some(match => match.id === "secrecy");
  const hasAction = matches.some(match => ["money", "code", "remote_access", "personal_data"].includes(match.id));
  const hasMigration = matches.some(match => match.id === "private_migration");
  if (hasSecrecy && hasAction) score += 18;
  if (hasMigration && hasAction) score += 10;

  score = Math.min(100, score);
  const level = score >= 75 ? "critical" : score >= 50 ? "high" : score >= 25 ? "medium" : "low";
  const action = level === "critical" || level === "high"
    ? "Stop. Do not send codes, money, photos, address, or install apps. Call a trusted adult."
    : level === "medium"
      ? "Pause and verify this contact with a trusted adult before acting."
      : "No major scam pattern was detected in this short fragment.";

  return { score, level, matches, action };
}

module.exports = { analyzeRisk, TRIGGERS };
