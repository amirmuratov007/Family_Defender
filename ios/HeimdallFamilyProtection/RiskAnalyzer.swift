import SwiftUI

struct RiskMatch: Identifiable, Codable, Hashable {
    let id: String
    let label: String
    let evidence: String
    let weight: Int
}

enum RiskLevel: String, Codable {
    case low
    case medium
    case high
    case critical

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .yellow
        case .high: return .orange
        case .critical: return .red
        }
    }

    var title: String {
        switch self {
        case .low: return "Низкий риск"
        case .medium: return "Средний риск"
        case .high: return "Высокий риск"
        case .critical: return "Критический риск"
        }
    }
}

struct RiskResult: Codable, Hashable {
    let score: Int
    let level: RiskLevel
    let matches: [RiskMatch]
    let action: String

    static let empty = RiskResult(
        score: 0,
        level: .low,
        matches: [],
        action: "Вставьте сообщение и нажмите проверку."
    )
}

enum RiskAnalyzer {
    private static let triggers: [(id: String, label: String, weight: Int, words: [String])] = [
        ("private_migration", "Переход в личку", 18, ["telegram", "телеграм", "tg", "тг", "личку", "личка", "напиши отдельно"]),
        ("secrecy", "Секретность", 24, ["secret", "do not tell", "секрет", "не говори", "родителям не говори", "никому не говори"]),
        ("urgency", "Срочность", 18, ["urgent", "right now", "срочно", "быстро", "иначе", "прямо сейчас"]),
        ("money", "Банк или деньги", 30, ["bank", "card", "банк", "карта", "перевод", "кредит", "деньги", "кошелёк"]),
        ("code", "Код или доступ", 30, ["code", "password", "sms", "код", "пароль", "смс", "sms"]),
        ("remote_access", "Удалённый доступ", 38, ["anydesk", "rustdesk", "teamviewer", "удалённый доступ", "экран", "установи приложение"]),
        ("authority", "Ложный авторитет", 20, ["police", "security service", "bank security", "полиция", "фсб", "служба безопасности"]),
        ("location_request", "Запрос координат", 70, ["coordinates", "coordinate", "send location", "share location", "location pin", "gps", "координат", "локацию", "геолокацию", "геопозицию", "местоположение", "пришли где ты", "скинь где ты"]),
        ("personal_data", "Личные данные", 18, ["address", "photo", "passport", "адрес", "фото", "паспорт", "документ", "геолокация"])
    ]

    static func analyze(_ text: String) -> RiskResult {
        let normalized = text.lowercased()
        var score = 0
        var matches: [RiskMatch] = []

        for trigger in triggers {
            if let hit = trigger.words.first(where: { normalized.contains($0) }) {
                score += trigger.weight
                matches.append(RiskMatch(id: trigger.id, label: trigger.label, evidence: hit, weight: trigger.weight))
            }
        }

        let hasSecrecy = matches.contains { $0.id == "secrecy" }
        let hasAction = matches.contains { ["money", "code", "remote_access", "location_request", "personal_data"].contains($0.id) }
        let hasMigration = matches.contains { $0.id == "private_migration" }
        if hasSecrecy && hasAction { score += 18 }
        if hasMigration && hasAction { score += 10 }
        score = min(score, 100)

        let level: RiskLevel = score >= 75 ? .critical : score >= 50 ? .high : score >= 25 ? .medium : .low
        let action: String
        switch level {
        case .critical, .high:
            action = "Стоп. Не отправляй коды, деньги, фото, адрес и не устанавливай приложения. Позови доверенного взрослого."
        case .medium:
            action = "Сделай паузу и проверь этот контакт вместе с доверенным взрослым."
        case .low:
            action = "Явный мошеннический сценарий в этом фрагменте не найден."
        }

        return RiskResult(score: score, level: level, matches: matches, action: action)
    }
}
