import Foundation
import UserNotifications

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var statusText = "Уведомления ещё не включены."

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error {
                    self.statusText = "Не удалось включить уведомления: \(error.localizedDescription)"
                } else {
                    self.statusText = granted ? "Уведомления включены." : "Уведомления запрещены в настройках iOS."
                }
            }
        }
    }

    func sendParentRiskNotification(alert: FamilyAlert) {
        let content = UNMutableNotificationContent()
        content.title = "Heimdall: тревога \(alert.childName)"
        content.body = "\(alert.level.title) \(alert.score)/100. \(alert.reasons.joined(separator: ", "))"
        content.sound = .default
        content.badge = 1

        let request = UNNotificationRequest(
            identifier: "risk-\(alert.id.uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    func sendSafeNotification(childName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Heimdall: ребёнок в безопасности"
        content.body = "\(childName) отметил, что всё в порядке."
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: "safe-\(UUID().uuidString)",
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request)
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
