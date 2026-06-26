import SwiftUI

@main
struct HeimdallApp: App {
    @StateObject private var familyShield = FamilyShieldManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(familyShield)
        }
    }
}
