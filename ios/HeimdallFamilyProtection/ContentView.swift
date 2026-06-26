import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var familyShield: FamilyShieldManager
    @State private var text = "Перейдем в телеграм. Родителям не говори. Срочно открой банк и пришли код из смс."
    @State private var result = RiskAnalyzer.analyze("")

    var body: some View {
        NavigationStack {
            ZStack {
                Color.black.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 28) {
                        HeaderView()
                        authorizationBlock
                        analysisBlock
                        protectionBlock
                    }
                    .padding(24)
                }
            }
            .navigationTitle("Heimdall")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
        .preferredColorScheme(.dark)
    }

    private var authorizationBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Parent-controlled protection")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("The child does not configure protection alone. A parent authorizes Family Controls and chooses rules.")
                .foregroundStyle(.secondary)
            Button("Request Family Controls authorization") {
                Task { await familyShield.requestAuthorization() }
            }
            .buttonStyle(.borderedProminent)
            Text(familyShield.statusText)
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private var analysisBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Check suspicious text")
                .font(.title2.bold())
                .foregroundStyle(.white)
            TextEditor(text: $text)
                .frame(minHeight: 140)
                .scrollContentBackground(.hidden)
                .foregroundStyle(.white)
                .padding(12)
                .background(.white.opacity(0.06))
            Button("Analyze risk") {
                result = RiskAnalyzer.analyze(text)
            }
            .buttonStyle(.borderedProminent)
            RiskResultView(result: result)
        }
    }

    private var protectionBlock: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Protection rules")
                .font(.title2.bold())
                .foregroundStyle(.white)
            Text("After Apple approves Family Controls, this app can shield risky apps and react to Device Activity events.")
                .foregroundStyle(.secondary)
            Button("Enable base protection rules") {
                familyShield.applyBaseRules()
            }
            .buttonStyle(.bordered)
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
            Text("A safety pause against messenger scams, secrecy, codes, banking pressure, and remote-access fraud.")
                .foregroundStyle(.secondary)
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
