import Foundation
import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
import DeviceActivity
#endif

@MainActor
final class FamilyShieldManager: ObservableObject {
    @Published var statusText = "Family Controls ещё не запрашивался."

    #if canImport(ManagedSettings)
    private let store = ManagedSettingsStore()
    #endif

    func requestAuthorization() async {
        #if canImport(FamilyControls)
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .child)
            statusText = "Family Controls разрешён родителем."
        } catch {
            statusText = "Не удалось получить Family Controls: \(error.localizedDescription)"
        }
        #else
        statusText = "FamilyControls недоступен в этой среде сборки."
        #endif
    }

    func applyBaseRules() {
        #if canImport(ManagedSettings)
        // Production app should apply parent-selected FamilyActivitySelection here.
        store.shield.webDomains = nil
        statusText = "Базовые правила сохранены. После одобрения Apple сюда подключается FamilyActivitySelection."
        #else
        statusText = "ManagedSettings недоступен в этой среде сборки."
        #endif
    }
}
