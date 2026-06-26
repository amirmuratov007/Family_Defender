import Foundation
import SwiftUI

#if canImport(FamilyControls)
import FamilyControls
import ManagedSettings
import DeviceActivity
#endif

@MainActor
final class FamilyShieldManager: ObservableObject {
    @Published var statusText = "Family Controls authorization has not been requested."

    #if canImport(ManagedSettings)
    private let store = ManagedSettingsStore()
    #endif

    func requestAuthorization() async {
        #if canImport(FamilyControls)
        do {
            try await AuthorizationCenter.shared.requestAuthorization(for: .child)
            statusText = "Family Controls authorization granted."
        } catch {
            statusText = "Authorization failed: \(error.localizedDescription)"
        }
        #else
        statusText = "FamilyControls framework is unavailable in this build environment."
        #endif
    }

    func applyBaseRules() {
        #if canImport(ManagedSettings)
        // Production app should apply parent-selected FamilyActivitySelection here.
        store.shield.webDomains = nil
        statusText = "Base protection rules placeholder applied. Connect FamilyActivitySelection after entitlement approval."
        #else
        statusText = "ManagedSettings framework is unavailable in this build environment."
        #endif
    }
}
