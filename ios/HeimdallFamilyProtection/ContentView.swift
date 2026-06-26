import CoreLocation
import SwiftUI

enum AppRole: String, CaseIterable, Identifiable {
    case parent
    case child

    var id: String { rawValue }

    var title: String {
        switch self {
        case .parent: return "Я родитель"
        case .child: return "Я ребёнок"
        }
    }

    var shortTitle: String {
        switch self {
        case .parent: return "Родитель"
        case .child: return "Ребёнок"
        }
    }

    var icon: String {
        switch self {
        case .parent: return "person.2.badge.shield.checkmark"
        case .child: return "figure.child"
        }
    }
}

struct ContentView: View {
    @AppStorage("heimdall.selected.role") private var selectedRoleRaw = ""

    var body: some View {
        NavigationStack {
            ZStack {
                AppBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        if let role = AppRole(rawValue: selectedRoleRaw) {
                            RoleHeader(role: role) {
                                selectedRoleRaw = ""
                            }

                            switch role {
                            case .parent:
                                ParentAppView()
                            case .child:
                                ChildAppView()
                            }
                        } else {
                            RoleSelectionView { role in
                                selectedRoleRaw = role.rawValue
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationTitle("Heimdall")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .font(.system(.body, design: .rounded))
        .preferredColorScheme(.dark)
    }
}

private struct RoleSelectionView: View {
    let onSelect: (AppRole) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 22) {
            HeaderBlock(
                title: "Family Defender",
                subtitle: "Выберите, кто открывает приложение на этом iPhone."
            )

            ForEach(AppRole.allCases) { role in
                Button {
                    onSelect(role)
                } label: {
                    HStack(spacing: 14) {
                        BrandLogo(size: 30)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(role.title)
                                .font(.system(.headline, design: .rounded).weight(.semibold))
                            Text(role == .parent ? "Панель детей, тревоги и уведомления" : "Пауза, проверка сообщения и связь со взрослым")
                                .font(.system(.footnote, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.secondary)
                    }
                    .foregroundStyle(.white)
                    .padding(16)
                    .background(.white.opacity(0.07))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

private struct RoleHeader: View {
    let role: AppRole
    let changeRole: () -> Void

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            BrandLogo(size: 34)
            VStack(alignment: .leading, spacing: 2) {
                Text("Heimdall")
                    .font(.system(.title2, design: .rounded).weight(.semibold))
                    .foregroundStyle(.white)
                Text(role.shortTitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button {
                changeRole()
            } label: {
                Image(systemName: "arrow.triangle.2.circlepath")
                    .frame(width: 36, height: 32)
            }
            .buttonStyle(.bordered)
            .accessibilityLabel("Сменить роль")
        }
    }
}

private struct ParentAppView: View {
    @EnvironmentObject private var familyShield: FamilyShieldManager
    @EnvironmentObject private var alertStore: FamilyAlertStore
    @EnvironmentObject private var notifications: NotificationManager
    @State private var safePlaceName = "Дом"
    @State private var safePlaceLatitude = ""
    @State private var safePlaceLongitude = ""
    @State private var safePlaceRadius = "500"
    @State private var safePlaceMessage = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderBlock(
                title: "Дети в безопасности",
                subtitle: alertStore.lastSafetyText
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricCard(title: "Дети", value: "\(alertStore.devices.count)")
                MetricCard(title: "Тревоги", value: "\(alertStore.alerts.count)")
                MetricCard(title: "Новые", value: "\(alertStore.unreadAlertCount)")
                MetricCard(title: "В очереди", value: "\(notifications.pendingNotificationCount)")
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Код подключения")
                    Text(alertStore.pairingCode)
                        .font(.system(size: 38, weight: .black, design: .rounded))
                        .tracking(4)
                        .foregroundStyle(.yellow)
                        .accessibilityLabel("Код подключения \(alertStore.pairingCode)")
                    Text("Введите этот код на iPhone ребёнка. В текущем MVP код хранится локально, позже он уйдёт в backend pairing flow.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Новый код") {
                            alertStore.regeneratePairingCode()
                        }
                        .buttonStyle(.bordered)
                        Button("Уведомить кодом") {
                            notifications.sendPairingNotification(code: alertStore.pairingCode)
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Уведомления")
                    Text(notifications.statusText)
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Включить уведомления") {
                            notifications.requestAuthorization()
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Тестовая тревога") {
                            let alert = alertStore.addTestAlert()
                            notifications.sendParentRiskNotification(alert: alert)
                        }
                        .buttonStyle(.bordered)
                    }
                    HStack {
                        Button("Обновить статус") {
                            notifications.refreshStatus()
                        }
                        .buttonStyle(.bordered)
                        Button("Очистить уведомления") {
                            notifications.clearDeliveredAndPending()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Геолокация")
                    Text(alertStore.locationStatusText)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                    TextField("Название зоны", text: $safePlaceName)
                        .textFieldStyle(.roundedBorder)
                    HStack {
                        TextField("Широта", text: $safePlaceLatitude)
                            .keyboardType(.numbersAndPunctuation)
                            .textFieldStyle(.roundedBorder)
                        TextField("Долгота", text: $safePlaceLongitude)
                            .keyboardType(.numbersAndPunctuation)
                            .textFieldStyle(.roundedBorder)
                    }
                    TextField("Радиус в метрах", text: $safePlaceRadius)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    VStack(alignment: .leading, spacing: 8) {
                        Button("Добавить зону") {
                            addSafePlace()
                        }
                        .buttonStyle(.borderedProminent)
                        Button("Текущая точка = зона") {
                            makeLatestLocationSafe()
                        }
                        .buttonStyle(.bordered)
                    }
                    if !safePlaceMessage.isEmpty {
                        Text(safePlaceMessage)
                            .font(.system(.footnote, design: .rounded))
                            .foregroundStyle(safePlaceMessage.hasPrefix("Добавлено") ? .green : .red)
                    }
                    if !alertStore.safePlaces.isEmpty {
                        ForEach(alertStore.safePlaces) { place in
                            SafePlaceRow(place: place) {
                                alertStore.removeSafePlace(place)
                            }
                        }
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Подключённые дети")
                    if alertStore.devices.isEmpty {
                        EmptyLine(title: "Пока нет устройств", text: "Откройте режим ребёнка на iPhone ребёнка и подключите его.")
                    } else {
                        ForEach(alertStore.devices) { device in
                            DeviceRow(device: device)
                        }
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Лента тревог")
                    if alertStore.alerts.isEmpty {
                        EmptyLine(title: "Тревог нет", text: "Когда риск станет высоким, родитель увидит уведомление и запись здесь.")
                    } else {
                        ForEach(alertStore.alerts) { alert in
                            AlertRow(alert: alert) {
                                alertStore.acknowledgeAlert(alert)
                            }
                        }
                        Button("Очистить ленту") {
                            alertStore.clearAlerts()
                        }
                        .buttonStyle(.bordered)
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Apple Screen Time")
                    Text(familyShield.statusText)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    Button("Запросить Family Controls") {
                        Task { await familyShield.requestAuthorization() }
                    }
                    .buttonStyle(.bordered)
                    Button("Включить базовые правила") {
                        familyShield.applyBaseRules()
                    }
                    .buttonStyle(.bordered)
                    Button("Сбросить локальный тест", role: .destructive) {
                        alertStore.reset()
                        notifications.clearDeliveredAndPending()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .onAppear {
            notifications.refreshStatus()
        }
    }

    private func addSafePlace() {
        guard
            let latitude = parseCoordinate(safePlaceLatitude),
            let longitude = parseCoordinate(safePlaceLongitude)
        else {
            safePlaceMessage = "Введите широту и долготу."
            return
        }
        guard abs(latitude) <= 90, abs(longitude) <= 180 else {
            safePlaceMessage = "Координаты вне допустимого диапазона."
            return
        }

        let radius = Double(safePlaceRadius.replacingOccurrences(of: ",", with: ".")) ?? 500
        alertStore.addSafePlace(name: safePlaceName, latitude: latitude, longitude: longitude, radiusMeters: radius)
        safePlaceMessage = "Добавлено: \(safePlaceName)."
    }

    private func makeLatestLocationSafe() {
        let radius = Double(safePlaceRadius.replacingOccurrences(of: ",", with: ".")) ?? 500
        if alertStore.makeLatestLocationSafePlace(name: safePlaceName, radiusMeters: radius) {
            safePlaceMessage = "Добавлено из последней точки ребёнка."
        } else {
            safePlaceMessage = "Сначала получите геолокацию ребёнка."
        }
    }

    private func parseCoordinate(_ value: String) -> Double? {
        Double(value.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "."))
    }
}

private struct ChildAppView: View {
    @EnvironmentObject private var alertStore: FamilyAlertStore
    @EnvironmentObject private var notifications: NotificationManager
    @EnvironmentObject private var locationManager: LocationSafetyManager

    @State private var childName = "Артур"
    @State private var deviceName = "iPhone ребёнка"
    @State private var trustedAdult = "Папа"
    @State private var trustedAdultPhone = ""
    @State private var pairingCode = ""
    @State private var connectionStatus = ""
    @State private var text = "Перейдём в Telegram. Родителям не говори. Срочно открой банк и пришли код из СМС."
    @State private var result = RiskResult.empty

    private let dangerousExample = "Перейдём в Telegram. Родителям не говори. Срочно открой банк и пришли код из СМС."
    private let safeExample = "Тренировка завтра в 16:00. Домашнее задание скину в школьный чат."

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderBlock(
                title: "Детская защита",
                subtitle: "Проверка риска, кнопка безопасности и связь со взрослым."
            )

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Подключение")
                    Text("Введите код подключения, который родитель видит в своей панели.")
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                    TextField("Код подключения", text: $pairingCode)
                        .textInputAutocapitalization(.characters)
                        .textFieldStyle(.roundedBorder)
                    TextField("Имя ребёнка", text: $childName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Устройство", text: $deviceName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Доверенный взрослый", text: $trustedAdult)
                        .textFieldStyle(.roundedBorder)
                    TextField("Телефон взрослого", text: $trustedAdultPhone)
                        .keyboardType(.phonePad)
                        .textFieldStyle(.roundedBorder)
                    Button("Подключить к родителю") {
                        let connected = alertStore.connectChild(
                            childName: childName,
                            deviceName: deviceName,
                            trustedAdult: trustedAdult,
                            trustedAdultPhone: trustedAdultPhone,
                            enteredPairingCode: pairingCode
                        )
                        connectionStatus = connected ? "Подключено к родительскому профилю." : "Код не совпадает. Проверьте код у родителя."
                    }
                    .buttonStyle(.borderedProminent)
                    if !connectionStatus.isEmpty {
                        Text(connectionStatus)
                            .font(.footnote)
                            .foregroundStyle(connectionStatus.hasPrefix("Подключено") ? .green : .red)
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Я в безопасности")
                    Button {
                        alertStore.markChildSafe(childName: childName)
                        notifications.sendSafeNotification(childName: childName)
                    } label: {
                        Label("Сообщить родителю", systemImage: "checkmark.shield")
                    }
                    .buttonStyle(.borderedProminent)
                    if let callURL = alertStore.firstTrustedAdultCallURL {
                        Link(destination: callURL) {
                            Label("Позвонить взрослому", systemImage: "phone.fill")
                        }
                        .buttonStyle(.bordered)
                    } else {
                        Text("Добавьте телефон взрослого, чтобы здесь появилась кнопка звонка.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Геолокация")
                    Text(locationManager.authorizationText)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(locationManager.statusText)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                    Text(alertStore.locationStatusText)
                        .font(.system(.footnote, design: .rounded))
                        .foregroundStyle(.secondary)
                    HStack {
                        Button("Разрешить") {
                            locationManager.requestAuthorization()
                        }
                        .buttonStyle(.bordered)
                        Button("Всегда") {
                            locationManager.requestAlwaysAuthorization()
                        }
                        .buttonStyle(.bordered)
                        if locationManager.isMonitoring {
                            Button("Остановить") {
                                locationManager.stopMonitoring()
                            }
                            .buttonStyle(.borderedProminent)
                        } else {
                            Button("Мониторинг") {
                                locationManager.startMonitoring()
                            }
                            .buttonStyle(.borderedProminent)
                        }
                    }
                    HStack {
                        Button("Проверить сейчас") {
                            checkCurrentLocation()
                        }
                        .buttonStyle(.bordered)
                        Button("Тест вне зоны") {
                            let alert = alertStore.addLocationTestAlert(childName: childName)
                            notifications.sendLocationAlertNotification(alert: alert)
                        }
                        .buttonStyle(.bordered)
                    }
                    if let latest = alertStore.latestLocation {
                        Text("Последняя точка: \(latest.coordinateText) · \(latest.createdAt, style: .time)")
                            .font(.system(.caption, design: .rounded))
                            .foregroundStyle(.secondary)
                    }
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Проверить сообщение")
                    HStack {
                        Button("Опасный пример") {
                            text = dangerousExample
                            result = .empty
                        }
                        .buttonStyle(.bordered)
                        Button("Безопасный пример") {
                            text = safeExample
                            result = .empty
                        }
                        .buttonStyle(.bordered)
                    }
                    TextEditor(text: $text)
                        .frame(minHeight: 150)
                        .scrollContentBackground(.hidden)
                        .padding(12)
                        .background(.white.opacity(0.06))
                        .clipShape(RoundedRectangle(cornerRadius: 8))

                    HStack {
                        Button("Проверить риск") {
                            result = RiskAnalyzer.analyze(text)
                            if let alert = alertStore.recordRisk(result: result, childName: childName) {
                                notifications.sendParentRiskNotification(alert: alert)
                            }
                        }
                        .buttonStyle(.borderedProminent)

                        Button("Очистить") {
                            text = ""
                            result = .empty
                        }
                        .buttonStyle(.bordered)
                    }

                    RiskResultView(result: result)
                }
            }
        }
        .onAppear {
            locationManager.onLocationUpdate = { coordinate, accuracy in
                handleLocationUpdate(coordinate: coordinate, accuracy: accuracy)
            }
            if pairingCode.isEmpty {
                pairingCode = alertStore.pairingCode
            }
            notifications.refreshStatus()
        }
        .onDisappear {
            locationManager.onLocationUpdate = nil
        }
    }

    private func checkCurrentLocation() {
        guard let coordinate = locationManager.lastCoordinate else {
            locationManager.checkNow()
            return
        }
        handleLocationUpdate(coordinate: coordinate, accuracy: locationManager.lastAccuracyMeters)
    }

    private func handleLocationUpdate(coordinate: CLLocationCoordinate2D, accuracy: CLLocationAccuracy) {
        if let alert = alertStore.recordChildLocation(
            childName: childName,
            coordinate: coordinate,
            accuracyMeters: accuracy
        ) {
            notifications.sendLocationAlertNotification(alert: alert)
        }
    }
}

private struct HeaderBlock: View {
    let title: String
    let subtitle: String

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            BrandLogo(size: 38)
            VStack(alignment: .leading, spacing: 7) {
                Text("HEIMDALL-GROUP")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .tracking(1.4)
                    .foregroundStyle(.yellow)
                Text(title)
                    .font(.system(size: 30, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(.subheadline, design: .rounded))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct BrandLogo: View {
    let size: CGFloat

    var body: some View {
        Image("HeimdallMark")
            .resizable()
            .scaledToFit()
            .frame(width: size, height: size)
            .shadow(color: .yellow.opacity(0.35), radius: size * 0.12, y: size * 0.04)
            .accessibilityLabel("Логотип Heimdall")
    }
}

private struct PanelCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        content
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.07))
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct MetricCard: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(value)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .foregroundStyle(.yellow)
            Text(title)
                .font(.system(.footnote, design: .rounded).weight(.semibold))
                .foregroundStyle(.secondary)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

private struct SectionTitle: View {
    let text: String

    init(_ text: String) {
        self.text = text
    }

    var body: some View {
        HStack(spacing: 8) {
            BrandLogo(size: 16)
            Text(text)
                .font(.system(.title3, design: .rounded).weight(.semibold))
                .foregroundStyle(.white)
        }
    }
}

private struct SafePlaceRow: View {
    let place: SafePlace
    let remove: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 10) {
            Image(systemName: "location.fill")
                .foregroundStyle(.yellow)
                .frame(width: 22)
            VStack(alignment: .leading, spacing: 4) {
                Text(place.name)
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.white)
                Text("\(String(format: "%.5f", place.latitude)), \(String(format: "%.5f", place.longitude)) · радиус \(Int(place.radiusMeters)) м")
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button(role: .destructive) {
                remove()
            } label: {
                Image(systemName: "trash")
            }
            .buttonStyle(.bordered)
        }
        .padding(.vertical, 6)
    }
}

private struct DeviceRow: View {
    let device: ChildDevice

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            HStack {
                Text(device.childName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Spacer()
                Text(device.status)
                    .font(.caption.bold())
                    .foregroundStyle(.yellow)
            }
            Text("\(device.deviceName) · \(device.trustedAdult)")
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text("Код: \(device.pairingCode) · Обновлено \(device.lastSeen, style: .time)")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
    }
}

private struct AlertRow: View {
    let alert: FamilyAlert
    let acknowledge: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("\(alert.childName): \(alert.level.title)")
                    .font(.headline)
                    .foregroundStyle(alert.level.color)
                Spacer()
                Text("\(alert.score)/100")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            }
            Text(alert.reasons.joined(separator: ", "))
                .font(.footnote)
                .foregroundStyle(.secondary)
            Text(alert.createdAt, style: .time)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(alert.summary)
                .font(.caption)
                .foregroundStyle(.secondary)
            if alert.isAcknowledged {
                Text("Просмотрено")
                    .font(.caption.bold())
                    .foregroundStyle(.green)
            } else {
                Button("Отметить просмотренной") {
                    acknowledge()
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(.vertical, 8)
    }
}

private struct EmptyLine: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            Text(text)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct RiskResultView: View {
    let result: RiskResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline) {
                Text("\(result.score)")
                    .font(.system(size: 44, weight: .black))
                    .foregroundStyle(result.level.color)
                Text(result.level.title)
                    .font(.headline)
                    .foregroundStyle(.white)
            }
            Text(result.action)
                .foregroundStyle(.white)
            ForEach(result.matches) { match in
                Label("\(match.label) +\(match.weight)", systemImage: "exclamationmark.triangle")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.top, 8)
    }
}

private struct AppBackground: View {
    private let nodes: [CGPoint] = [
        CGPoint(x: 0.08, y: 0.10), CGPoint(x: 0.24, y: 0.16), CGPoint(x: 0.42, y: 0.08),
        CGPoint(x: 0.62, y: 0.18), CGPoint(x: 0.86, y: 0.09), CGPoint(x: 0.16, y: 0.32),
        CGPoint(x: 0.36, y: 0.28), CGPoint(x: 0.54, y: 0.40), CGPoint(x: 0.78, y: 0.34),
        CGPoint(x: 0.12, y: 0.58), CGPoint(x: 0.31, y: 0.68), CGPoint(x: 0.50, y: 0.62),
        CGPoint(x: 0.70, y: 0.72), CGPoint(x: 0.90, y: 0.55), CGPoint(x: 0.22, y: 0.88),
        CGPoint(x: 0.48, y: 0.92), CGPoint(x: 0.82, y: 0.86)
    ]

    private let links: [(Int, Int)] = [
        (0, 1), (1, 2), (2, 3), (3, 4), (1, 6), (5, 6), (6, 7), (7, 8),
        (5, 9), (9, 10), (10, 11), (11, 12), (12, 13), (10, 14), (11, 15), (12, 16),
        (2, 7), (3, 8), (7, 12), (8, 13)
    ]

    private let stars: [CGPoint] = [
        CGPoint(x: 0.18, y: 0.07), CGPoint(x: 0.32, y: 0.11), CGPoint(x: 0.73, y: 0.12),
        CGPoint(x: 0.93, y: 0.23), CGPoint(x: 0.05, y: 0.41), CGPoint(x: 0.43, y: 0.49),
        CGPoint(x: 0.64, y: 0.53), CGPoint(x: 0.27, y: 0.77), CGPoint(x: 0.57, y: 0.82),
        CGPoint(x: 0.94, y: 0.78), CGPoint(x: 0.07, y: 0.91)
    ]

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [
                    Color(red: 0.01, green: 0.01, blue: 0.05),
                    Color(red: 0.02, green: 0.06, blue: 0.13),
                    Color(red: 0.03, green: 0.02, blue: 0.07),
                    Color.black
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            Canvas { context, size in
                let resolvedNodes = nodes.map { point in
                    CGPoint(x: point.x * size.width, y: point.y * size.height)
                }
                for link in links {
                    var path = Path()
                    path.move(to: resolvedNodes[link.0])
                    path.addLine(to: resolvedNodes[link.1])
                    context.stroke(path, with: .color(Color.cyan.opacity(0.16)), lineWidth: 1)
                }
                for point in resolvedNodes {
                    let rect = CGRect(x: point.x - 2.5, y: point.y - 2.5, width: 5, height: 5)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.yellow.opacity(0.62)))
                }
                for star in stars {
                    let point = CGPoint(x: star.x * size.width, y: star.y * size.height)
                    let rect = CGRect(x: point.x - 0.8, y: point.y - 0.8, width: 1.6, height: 1.6)
                    context.fill(Path(ellipseIn: rect), with: .color(Color.white.opacity(0.38)))
                }
            }
            .blendMode(.screen)

            LinearGradient(
                colors: [.black.opacity(0.08), .black.opacity(0.46)],
                startPoint: .top,
                endPoint: .bottom
            )
        }
        .ignoresSafeArea()
    }
}
