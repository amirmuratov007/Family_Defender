import Combine
import CoreLocation
import Foundation

struct ChildDevice: Identifiable, Codable, Hashable {
    let id: UUID
    var childName: String
    var deviceName: String
    var trustedAdult: String
    var trustedAdultPhone: String
    var lastSeen: Date
    var status: String
    var pairingCode: String

    init(
        id: UUID = UUID(),
        childName: String,
        deviceName: String,
        trustedAdult: String,
        trustedAdultPhone: String = "",
        lastSeen: Date = Date(),
        status: String = "В безопасности",
        pairingCode: String = FamilyAlertStore.makePairingCode()
    ) {
        self.id = id
        self.childName = childName
        self.deviceName = deviceName
        self.trustedAdult = trustedAdult
        self.trustedAdultPhone = trustedAdultPhone
        self.lastSeen = lastSeen
        self.status = status
        self.pairingCode = pairingCode
    }

    var trustedAdultCallURL: URL? {
        let digits = trustedAdultPhone.filter(\.isNumber)
        guard digits.count >= 7 else { return nil }
        return URL(string: "tel://\(digits)")
    }
}

struct FamilyAlert: Identifiable, Codable, Hashable {
    let id: UUID
    var childName: String
    var score: Int
    var level: RiskLevel
    var reasons: [String]
    var createdAt: Date
    var acknowledgedAt: Date?
    var summary: String

    init(
        id: UUID = UUID(),
        childName: String,
        score: Int,
        level: RiskLevel,
        reasons: [String],
        createdAt: Date = Date(),
        acknowledgedAt: Date? = nil,
        summary: String
    ) {
        self.id = id
        self.childName = childName
        self.score = score
        self.level = level
        self.reasons = reasons
        self.createdAt = createdAt
        self.acknowledgedAt = acknowledgedAt
        self.summary = summary
    }

    var isAcknowledged: Bool {
        acknowledgedAt != nil
    }
}

struct SafePlace: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var latitude: Double
    var longitude: Double
    var radiusMeters: Double
    var createdAt: Date

    init(
        id: UUID = UUID(),
        name: String,
        latitude: Double,
        longitude: Double,
        radiusMeters: Double = 500,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.latitude = latitude
        self.longitude = longitude
        self.radiusMeters = radiusMeters
        self.createdAt = createdAt
    }

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    func distanceMeters(to coordinate: CLLocationCoordinate2D) -> CLLocationDistance {
        CLLocation(latitude: latitude, longitude: longitude).distance(
            from: CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        )
    }
}

struct ChildLocationSnapshot: Codable, Hashable {
    var childName: String
    var latitude: Double
    var longitude: Double
    var accuracyMeters: Double
    var createdAt: Date
    var status: String

    var coordinateText: String {
        "\(String(format: "%.5f", latitude)), \(String(format: "%.5f", longitude))"
    }
}

@MainActor
final class FamilyAlertStore: ObservableObject {
    @Published private(set) var devices: [ChildDevice] = []
    @Published private(set) var alerts: [FamilyAlert] = []
    @Published private(set) var pairingCode: String = FamilyAlertStore.makePairingCode()
    @Published private(set) var safePlaces: [SafePlace] = []
    @Published private(set) var latestLocation: ChildLocationSnapshot?

    private let storageKey = "heimdall.family.alert.store.v2"

    init() {
        load()
    }

    var latestAlert: FamilyAlert? {
        alerts.first
    }

    var unreadAlertCount: Int {
        alerts.filter { !$0.isAcknowledged }.count
    }

    var lastSafetyText: String {
        if unreadAlertCount > 0 {
            return "Есть \(unreadAlertCount) непросмотренных тревог"
        }
        guard let device = devices.first else { return "Нет подключённых детей" }
        return "\(device.childName): \(device.status)"
    }

    var firstTrustedAdultCallURL: URL? {
        devices.first?.trustedAdultCallURL
    }

    var locationStatusText: String {
        if let latestLocation {
            return "\(latestLocation.childName): \(latestLocation.status)"
        }
        if safePlaces.isEmpty {
            return "Добавьте дом, школу или другую безопасную зону."
        }
        return "Безопасных зон: \(safePlaces.count). Ожидаю геолокацию ребёнка."
    }

    nonisolated static func makePairingCode() -> String {
        let alphabet = Array("ABCDEFGHJKLMNPQRSTUVWXYZ23456789")
        return String((0..<6).compactMap { _ in alphabet.randomElement() })
    }

    func regeneratePairingCode() {
        pairingCode = Self.makePairingCode()
        if !devices.isEmpty {
            devices = devices.map { device in
                var updated = device
                updated.pairingCode = pairingCode
                return updated
            }
        }
        save()
    }

    @discardableResult
    func connectChild(
        childName: String,
        deviceName: String,
        trustedAdult: String,
        trustedAdultPhone: String = "",
        enteredPairingCode: String? = nil
    ) -> Bool {
        if let enteredPairingCode, normalizedPairingCode(enteredPairingCode) != pairingCode {
            return false
        }

        let device = ChildDevice(
            childName: cleaned(childName, fallback: "Ребёнок"),
            deviceName: cleaned(deviceName, fallback: "iPhone ребёнка"),
            trustedAdult: cleaned(trustedAdult, fallback: "Доверенный взрослый"),
            trustedAdultPhone: trustedAdultPhone.trimmingCharacters(in: .whitespacesAndNewlines),
            pairingCode: pairingCode
        )
        devices = [device]
        save()
        return true
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

    func addSafePlace(name: String, latitude: Double, longitude: Double, radiusMeters: Double) {
        let place = SafePlace(
            name: cleaned(name, fallback: "Безопасная зона"),
            latitude: latitude,
            longitude: longitude,
            radiusMeters: max(100, min(radiusMeters, 10_000))
        )
        safePlaces.insert(place, at: 0)
        safePlaces = Array(safePlaces.prefix(12))
        save()
    }

    func removeSafePlace(_ place: SafePlace) {
        safePlaces.removeAll { $0.id == place.id }
        save()
    }

    func makeLatestLocationSafePlace(name: String, radiusMeters: Double) -> Bool {
        guard let latestLocation else { return false }
        addSafePlace(
            name: name,
            latitude: latestLocation.latitude,
            longitude: latestLocation.longitude,
            radiusMeters: radiusMeters
        )
        return true
    }

    func recordChildLocation(
        childName: String,
        coordinate: CLLocationCoordinate2D,
        accuracyMeters: CLLocationAccuracy
    ) -> FamilyAlert? {
        let resolvedName = resolvedChildName(childName)
        guard !safePlaces.isEmpty else {
            latestLocation = ChildLocationSnapshot(
                childName: resolvedName,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                accuracyMeters: max(0, accuracyMeters),
                createdAt: Date(),
                status: "точка получена, но безопасные зоны ещё не заданы"
            )
            save()
            return nil
        }

        let nearest = nearestSafePlace(to: coordinate)
        if let nearest, nearest.distance <= nearest.place.radiusMeters {
            latestLocation = ChildLocationSnapshot(
                childName: resolvedName,
                latitude: coordinate.latitude,
                longitude: coordinate.longitude,
                accuracyMeters: max(0, accuracyMeters),
                createdAt: Date(),
                status: "в безопасной зоне \(nearest.place.name)"
            )
            updateDeviceLocationStatus("\(nearest.place.name): в зоне", childName: resolvedName)
            save()
            return nil
        }

        let distanceText = nearest.map { Self.formatMeters($0.distance) } ?? "неизвестно"
        latestLocation = ChildLocationSnapshot(
            childName: resolvedName,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude,
            accuracyMeters: max(0, accuracyMeters),
            createdAt: Date(),
            status: "вне безопасных зон, ближайшая зона \(distanceText)"
        )

        let reasons = ["Геолокация", "Вне безопасной зоны"]
        if isDuplicateAlert(level: .high, score: 72, reasons: reasons, childName: resolvedName) {
            updateDeviceLocationStatus("Вне безопасной зоны", childName: resolvedName)
            save()
            return nil
        }

        let alert = FamilyAlert(
            childName: resolvedName,
            score: 72,
            level: .high,
            reasons: reasons,
            summary: "Ребёнок находится вне заданных безопасных зон. Последняя точка: \(LocationSafetyManager.format(coordinate))."
        )
        alerts.insert(alert, at: 0)
        alerts = Array(alerts.prefix(20))
        updateDeviceLocationStatus("Вне безопасной зоны", childName: resolvedName)
        save()
        return alert
    }

    func addLocationTestAlert(childName: String) -> FamilyAlert {
        let alert = FamilyAlert(
            childName: resolvedChildName(childName),
            score: 72,
            level: .high,
            reasons: ["Геолокация", "Тест вне зоны"],
            summary: "Тестовая гео-тревога: ребёнок вышел за пределы безопасной зоны."
        )
        alerts.insert(alert, at: 0)
        alerts = Array(alerts.prefix(20))
        save()
        return alert
    }

    func recordRisk(result: RiskResult, childName: String) -> FamilyAlert? {
        guard result.score >= 50 else {
            markChildSafe(childName: childName)
            return nil
        }

        let reasons = result.matches.map(\.label)
        if isDuplicateAlert(level: result.level, score: result.score, reasons: reasons, childName: childName) {
            updateDeviceStatus(result: result)
            save()
            return nil
        }

        let alert = FamilyAlert(
            childName: resolvedChildName(childName),
            score: result.score,
            level: result.level,
            reasons: reasons,
            summary: result.action
        )
        alerts.insert(alert, at: 0)
        alerts = Array(alerts.prefix(20))
        updateDeviceStatus(result: result)
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
        alerts = Array(alerts.prefix(20))
        save()
        return alert
    }

    func acknowledgeAlert(_ alert: FamilyAlert) {
        acknowledgeAlert(id: alert.id)
    }

    func acknowledgeAlert(id: UUID) {
        alerts = alerts.map { alert in
            guard alert.id == id else { return alert }
            var updated = alert
            updated.acknowledgedAt = Date()
            return updated
        }
        save()
    }

    func clearAlerts() {
        alerts = []
        save()
    }

    func reset() {
        devices = []
        alerts = []
        safePlaces = []
        latestLocation = nil
        pairingCode = Self.makePairingCode()
        UserDefaults.standard.removeObject(forKey: storageKey)
    }

    private func cleaned(_ value: String, fallback: String) -> String {
        let clean = value.trimmingCharacters(in: .whitespacesAndNewlines)
        return clean.isEmpty ? fallback : clean
    }

    private func normalizedPairingCode(_ value: String) -> String {
        value
            .uppercased()
            .filter { $0.isLetter || $0.isNumber }
    }

    private func resolvedChildName(_ childName: String) -> String {
        let clean = childName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !clean.isEmpty { return clean }
        return devices.first?.childName ?? "Ребёнок"
    }

    private func updateDeviceStatus(result: RiskResult) {
        devices = devices.map { device in
            var updated = device
            updated.status = "\(result.level.title) \(result.score)/100"
            updated.lastSeen = Date()
            return updated
        }
    }

    private func updateDeviceLocationStatus(_ status: String, childName: String) {
        if devices.isEmpty {
            connectChild(childName: childName, deviceName: "iPhone ребёнка", trustedAdult: "Доверенный взрослый")
        }
        devices = devices.map { device in
            var updated = device
            updated.status = status
            updated.lastSeen = Date()
            return updated
        }
    }

    private func nearestSafePlace(to coordinate: CLLocationCoordinate2D) -> (place: SafePlace, distance: CLLocationDistance)? {
        safePlaces
            .map { place in (place: place, distance: place.distanceMeters(to: coordinate)) }
            .min { lhs, rhs in lhs.distance < rhs.distance }
    }

    private static func formatMeters(_ meters: CLLocationDistance) -> String {
        if meters >= 1000 {
            return "\(String(format: "%.1f", meters / 1000)) км"
        }
        return "\(Int(meters.rounded())) м"
    }

    private func isDuplicateAlert(level: RiskLevel, score: Int, reasons: [String], childName: String) -> Bool {
        guard let latest = alerts.first else { return false }
        let sameChild = latest.childName == resolvedChildName(childName)
        let sameLevel = latest.level == level
        let sameReasons = latest.reasons == reasons
        let closeInTime = Date().timeIntervalSince(latest.createdAt) < 120
        return sameChild && sameLevel && sameReasons && closeInTime && abs(latest.score - score) < 5
    }

    private func load() {
        guard
            let data = UserDefaults.standard.data(forKey: storageKey),
            let state = try? JSONDecoder().decode(State.self, from: data)
        else { return }
        devices = state.devices
        alerts = state.alerts
        pairingCode = state.pairingCode
        safePlaces = state.safePlaces ?? []
        latestLocation = state.latestLocation
    }

    private func save() {
        let state = State(
            devices: devices,
            alerts: alerts,
            pairingCode: pairingCode,
            safePlaces: safePlaces,
            latestLocation: latestLocation
        )
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: storageKey)
    }

    private struct State: Codable {
        var devices: [ChildDevice]
        var alerts: [FamilyAlert]
        var pairingCode: String
        var safePlaces: [SafePlace]?
        var latestLocation: ChildLocationSnapshot?
    }
}
