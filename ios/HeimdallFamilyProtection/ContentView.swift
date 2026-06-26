import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var familyShield: FamilyShieldManager
    @State private var role: AppRole = .parent
    @State private var text = "Перейдем в телеграм. Родителям не говори. Срочно открой банк и пришли код из смс."
    @State private var result = RiskAnalyzer.analyze("")

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        HeaderView()
                        rolePicker
                        if role == .parent {
                            ParentDashboardView()
                        } else {
                            ChildProtectionView(text: $text, result: $result)
                        }
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Heimdall")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var rolePicker: some View {
        Picker("Режим", selection: $role) {
            ForEach(AppRole.allCases) { role in
                Text(role.title).tag(role)
            }
        }
        .pickerStyle(.segmented)
    }
}

private enum AppRole: String, CaseIterable, Identifiable {
    case parent
    case child

    var id: String { rawValue }

    var title: String {
        switch self {
        case .parent: return "Родитель"
        case .child: return "Ребенок"
        }
    }
}

private struct ParentDashboardView: View {
    @EnvironmentObject private var familyShield: FamilyShieldManager

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            ParentSetupView()
            ParentStatusView()
            ParentRulesView()
        }
    }
}

private struct ParentSetupView: View {
    @EnvironmentObject private var familyShield: FamilyShieldManager

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Родительская версия")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("Родитель создает семью, подключает iPhone ребенка, дает разрешение Screen Time и получает только риск-сигналы, а не всю переписку.")
                .foregroundStyle(.secondary)
            Button("Запросить разрешение Family Controls") {
                Task { await familyShield.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
            Button("Включить базовые правила") {
                familyShield.applyBaseRules()
            }
            .buttonStyle(.bordered)
            Text(familyShield.statusText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ParentStatusView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Семейная панель")
                .font(.title2.bold())
                .foregroundStyle(.white)
            InfoRow(title: "Подключенные устройства", value: "0")
            InfoRow(title: "Доверенные взрослые", value: "Не добавлены")
            InfoRow(title: "Последняя тревога", value: "Нет реальных событий")
            Text("После подключения здесь появятся реальные устройства семьи. Демонстрационные дети и фальшивые тревоги не показываются.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }
}

private struct ParentRulesView: View {
    private let rules = [
        "новый контакт или переход из игры в личку",
        "секретность, давление или срочность",
        "код, банк, деньги, адрес, фото или удаленный доступ",
        "антискам-пауза перед опасным действием"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Что получает родитель")
                .font(.title2.bold())
                .foregroundStyle(.white)
            ForEach(rules, id: \.self) { rule in
                Label(rule, systemImage: "shield.checkered")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

private struct ChildProtectionView: View {
    @Binding var text: String
    @Binding var result: RiskResult

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            VStack(alignment: .leading, spacing: 12) {
                Text("Версия ребенка")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Ребенок не настраивает слежку и правила. Он получает простую паузу, объяснение риска и кнопку связи со взрослым.")
                    .foregroundStyle(.secondary)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Проверить подозрительное сообщение")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                TextEditor(text: $text)
                    .frame(minHeight: 140)
                    .scrollContentBackground(.hidden)
                    .foregroundStyle(.white)
                    .padding(12)
                    .background(.white.opacity(0.06))
                Button("Проверить риск") {
                    result = RiskAnalyzer.analyze(text)
                }
                .buttonStyle(.borderedProminent)
                RiskResultView(result: result)
            }

            VStack(alignment: .leading, spacing: 12) {
                Text("Антискам-пауза")
                    .font(.title2.bold())
                    .foregroundStyle(.white)
                Text("Если кто-то просит код, деньги, фото, адрес, секрет или удаленный доступ, ребенок видит паузу и зовет взрослого.")
                    .foregroundStyle(.secondary)
                Button("Позвонить доверенному взрослому") {}
                    .buttonStyle(.bordered)
            }
        }
    }
}

private struct HeaderView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("HEIMDALL-GROUP")
                .font(.caption.bold())
                .tracking(2)
                .foregroundStyle(Color(red: 0.96, green: 0.82, blue: 0.45))
            Text("Family Protection")
                .font(.largeTitle.bold())
                .foregroundStyle(.white)
            Text("Родительская панель и детская антискам-пауза против секретности, кодов, денег и удаленного доступа.")
                .foregroundStyle(.secondary)
        }
    }
}

private struct InfoRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Text(title)
                .foregroundStyle(.secondary)
            Spacer(minLength: 16)
            Text(value)
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(.white.opacity(0.12))
                .frame(height: 1)
        }
    }
}

private struct RiskResultView: View {
    let result: RiskResult

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Risk \(result.score)/100")
                .font(.title.bold())
                .foregroundStyle(result.level.color)
            Text(result.action)
                .foregroundStyle(.white)
            ForEach(result.matches) { match in
                Text("\(match.label): \(match.evidence)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
