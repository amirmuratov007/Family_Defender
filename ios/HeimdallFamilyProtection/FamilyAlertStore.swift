import Foundation

struct ChildDevice: Identifiable, Codable, Hashable {
    let id: UUID
    var childName: String
    var deviceName: String
    var trustedAdult: String
    var lastSeen: Date
    var status: String

    init(
        id: UUID = UUID(),
        childName: String,
        deviceName: String,
        trustedAdult: String,
        lastSeen: Date = Date(),
        status: String = "В безопасности"
    ) {
        self.id = id
        self.childName = childName
        self.deviceName = deviceName
        self.trustedAdult = trustedAdult
        self.lastSeen = lastSeen
        self.status = status
    }
}

struct FamilyAlert: Identifiable, Codable, Hashable {
    let id: UUID
    var childName: String
    var score: Int
    var level: RiskLevel
    var reasons: [String]
    var createdAt: Date
    var summary: String

    init(
        id: UUID = UUID(),
        childName: String,
        score: Int,
        level: RiskLevel,
        reasons: [String],
        createdAt: Date = Date(),
        summary: String
    ) {
        self.id = id
        self.childName = childName
        self.score = score
        self.level = level
        self.reasons = reasons
        self.createdAt = createdAt
        self.summary = summary
    }
}

@MainActor
final class FamilyAlertStore: ObservableObject {
    @Published private(set) var devices: [ChildDevice] = []
    @Published private(set) var alerts: [FamilyAlert] = []

    private let storageKey = "heimdall.family.alert.store.v1"

    init() {
        load()
    }

    var latestAlert: FamilyAlert? {
        alerts.first
    }

    var lastSafetyText: String {
        guard let device = devices.first else { return "Нет подключённых детей" }
        return "\(device.childName): \(device.status)"
    }

    func connectChild(childName: String, deviceName: String, trustedAdult: String) {
        let cleanChildName = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDeviceName = deviceName.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanTrustedAdult = trustedAdult.trimmingCharacters(in: .whitespacesAndNewlines)
        let device = ChildDevice(
            childName: cleanChildName.isEmpty ? "Ребёнок" : cleanChildName,
            deviceName: cleanDeviceName.isEmpty ? "iPhone ребёнка" : cleanDeviceName,
            trustedAdult: cleanTrustedAdult.isEmpty ? "Доверенный взрослый" : cleanTrustedAdult
        )
        devices = [device]
        save()
    }

    func markChildSafe(childName: String) {
        let resolvedName = resolvedChildName(childName)
        if devices.isEmpty {
            connectChild(childName: resolvedName, deviceName: "iPhone ребёнка", trustedAdult: "Доверенный взрослый")
        }
        devices = devices.map { device in
            var updated = device
            updated.status = "В безопасности"
            updated.lastSeen = Date()
            return updated
        }
        save()
    }

    func recordRisk(result: RiskResult, childName: String) -> FamilyAlert? {
        guard result.score >= 50 else {
            markChildSafe(childName: childName)
            return nil
        }

        let alert = FamilyAlert(
            childName: resolvedChildName(childName),
            score: result.score,
            level: result.level,
            reasons: result.matches.map(\.label),
            summary: result.action
        )
        alerts.insert(alert, at: 0)
        alerts = Array(alerts.prefix(20))
        devices = devices.map { device in
            var updated = device
            updated.status = "\(result.level.title) \(result.score)/100"
            updated.lastSeen = Date()
            return updated
        }
        save()
        return alert
    }

    func addTestAlert() -> FamilyAlert {
        let alert = FamilyAlert(
            childName: devices.first?.childName ?? "Ребёнок",
            score: 88,
            level: .critical,
            reasons: ["Секретность", "Код или доступ", "Банк или деньги"],
            summary: "Тестовая тревога для проверки уведомлений родителя."
        )
        alerts.insert(alert, at: 0)
        save()
        return alert
    }

    func reset() {
        devices = []
        alerts = []
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func resolvedChildName(_ childName: String) -> String {
        let clean = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.isEmpty { return clean }
        return devices.first?.childName ?? "Ребёнок"
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let state = try? JSONDecoder().decode(State.self, from: data)
        else { return }
        devices = state.devices
        alerts = state.alerts
    }

    private func save() {
        let state = State(devices: devices, alerts: alerts)
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private struct State: Codable {
        var devices: [ChildDevice]
        var alerts: [FamilyAlert]
    }
}
