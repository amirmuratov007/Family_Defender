import SwiftUI
import FamilyControls

@main
struct HeimdallApp: App {
    @StateObject private var shieldManager = FamilyShieldManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(shieldManager)
        }
    }
}
