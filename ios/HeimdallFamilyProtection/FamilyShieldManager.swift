import Foundation
import FamilyControls
import ManagedSettings

@MainActor
final class FamilyShieldManager: ObservableObject {
    @Published var selection = FamilyActivitySelection()
    @Published var status = "Not authorized"

    private let authorizationCenter = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()

    func requestAuthorization() async {
        do {
            try await authorizationCenter.requestAuthorization(for: .child)
            status = "Authorized"
        } catch {
            status = "Authorization failed: \(error.localizedDescription)"
        }
    }

    func applyDefaultRules() {
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens.isEmpty ? nil : ShieldSettings.ActivityCategoryPolicy.specific(selection.categoryTokens)
        status = "Family rules applied"
    }

    func clearRules() {
        store.clearAllSettings()
        status = "Rules cleared"
    }
}
