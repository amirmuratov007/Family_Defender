import SwiftUI

struct RiskMatch: Identifiable {
    let id: String
    let label: String
    let evidence: String
    let weight: Int
}

enum RiskLevel: String {
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
}

struct RiskResult {
    let score: Int
    let level: RiskLevel
    let matches: [RiskMatch]
    let action: String
}

enum RiskAnalyzer {
    private static let triggers: [(id: String, label: String, weight: Int, words: [String])] = [
        ("private_migration", "Private chat migration", 18, ["telegram", "телеграм", "tg", "тг", "личку", "личка"]),
        ("secrecy", "Secrecy", 24, ["secret", "do not tell", "секрет", "не говори", "родителям не говори"]),
        ("urgency", "Urgency", 18, ["urgent", "right now", "срочно", "быстро", "иначе"]),
        ("money", "Bank or money", 30, ["bank", "card", "банк", "карта", "перевод", "кредит", "деньги"]),
        ("code", "Code or access", 30, ["code", "password", "sms", "код", "пароль", "смс"]),
        ("remote_access", "Remote access", 38, ["anydesk", "rustdesk", "teamviewer", "удаленный доступ"]),
        ("personal_data", "Personal data", 18, ["address", "photo", "passport", "адрес", "фото", "паспорт"])
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
        let hasAction = matches.contains { ["money", "code", "remote_access", "personal_data"].contains($0.id) }
        let hasMigration = matches.contains { $0.id == "private_migration" }
        if hasSecrecy && hasAction { score += 18 }
        if hasMigration && hasAction { score += 10 }
        score = min(score, 100)

        let level: RiskLevel = score >= 75 ? .critical : score >= 50 ? .high : score >= 25 ? .medium : .low
        let action: String
        switch level {
        case .critical, .high:
            action = "Stop. Do not send codes, money, photos, address, or install apps. Call a trusted adult."
        case .medium:
            action = "Pause and verify this contact with a trusted adult before acting."
        case .low:
            action = "No major scam pattern was detected in this short fragment."
        }

        return RiskResult(score: score, level: level, matches: matches, action: action)
    }
}
