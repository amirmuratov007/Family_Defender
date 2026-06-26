import SwiftUI

@main
struct HeimdallApp: App {
    @StateObject private var familyShield = FamilyShieldManager()
    @StateObject private var alertStore = FamilyAlertStore()
    @StateObject private var notificationManager = NotificationManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(familyShield)
                .environmentObject(alertStore)
                .environmentObject(notificationManager)
        }
    }
}
