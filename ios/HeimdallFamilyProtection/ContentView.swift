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
                        Image(systemName: role.icon)
                            .font(.title2)
                            .frame(width: 34)
                        VStack(alignment: .leading, spacing: 4) {
                            Text(role.title)
                                .font(.headline)
                            Text(role == .parent ? "Панель детей, тревоги и уведомления" : "Пауза, проверка сообщения и связь со взрослым")
                                .font(.footnote)
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
            Image(systemName: role.icon)
                .font(.title2)
                .foregroundStyle(.yellow)
                .frame(width: 38, height: 38)
                .background(.white.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            VStack(alignment: .leading, spacing: 2) {
                Text("Heimdall")
                    .font(.title.bold())
                    .foregroundStyle(.white)
                Text(role.shortTitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Сменить") {
                changeRole()
            }
            .buttonStyle(.bordered)
        }
    }
}

private struct ParentAppView: View {
    @EnvironmentObject private var familyShield: FamilyShieldManager
    @EnvironmentObject private var alertStore: FamilyAlertStore
    @EnvironmentObject private var notifications: NotificationManager

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderBlock(
                title: "Дети в безопасности",
                subtitle: alertStore.lastSafetyText
            )

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                MetricCard(title: "Дети", value: "\(alertStore.devices.count)")
                MetricCard(title: "Тревоги", value: "\(alertStore.alerts.count)")
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
                            AlertRow(alert: alert)
                        }
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
                }
            }
        }
    }
}

private struct ChildAppView: View {
    @EnvironmentObject private var alertStore: FamilyAlertStore
    @EnvironmentObject private var notifications: NotificationManager

    @State private var childName = "Артур"
    @State private var deviceName = "iPhone ребёнка"
    @State private var trustedAdult = "Папа"
    @State private var text = "Перейдём в Telegram. Родителям не говори. Срочно открой банк и пришли код из СМС."
    @State private var result = RiskResult.empty

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HeaderBlock(
                title: "Детская защита",
                subtitle: "Проверка риска, кнопка безопасности и связь со взрослым."
            )

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Подключение")
                    TextField("Имя ребёнка", text: $childName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Устройство", text: $deviceName)
                        .textFieldStyle(.roundedBorder)
                    TextField("Доверенный взрослый", text: $trustedAdult)
                        .textFieldStyle(.roundedBorder)
                    Button("Подключить к родителю") {
                        alertStore.connectChild(childName: childName, deviceName: deviceName, trustedAdult: trustedAdult)
                    }
                    .buttonStyle(.borderedProminent)
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
                }
            }

            PanelCard {
                VStack(alignment: .leading, spacing: 12) {
                    SectionTitle("Проверить сообщение")
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
    }
}

private struct HeaderBlock: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("HEIMDALL-GROUP")
                .font(.caption.bold())
                .tracking(2)
                .foregroundStyle(.yellow)
            Text(title)
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text(subtitle)
                .foregroundStyle(.secondary)
        }
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
                .font(.system(size: 36, weight: .black))
                .foregroundStyle(.yellow)
            Text(title)
                .font(.footnote.bold())
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
        Text(text)
            .font(.title3.bold())
            .foregroundStyle(.white)
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
        }
        .padding(.vertical, 8)
    }
}

private struct AlertRow: View {
    let alert: FamilyAlert

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
    var body: some View {
        LinearGradient(
            colors: [Color.black, Color(red: 0.08, green: 0.07, blue: 0.04)],
            startPoint: .top,
            endPoint: .bottom
        )
        .ignoresSafeArea()
    }
}
