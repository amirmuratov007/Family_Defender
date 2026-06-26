import Foundation
import UserNotifications

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    @Published var statusText = "Уведомления ещё не включены."
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var pendingNotificationCount = 0

    override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        refreshStatus()
    }

    func refreshStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
                DispatchQueue.main.async {
                    self.authorizationStatus = settings.authorizationStatus
                    self.pendingNotificationCount = requests.count
                    self.statusText = self.text(for: settings.authorizationStatus)
                }
            }
        }
    }

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            DispatchQueue.main.async {
                if let error {
                    self.statusText = "Не удалось включить уведомления: \(error.localizedDescription)"
                } else {
                    self.statusText = granted ? "Уведомления включены." : "Уведомления запрещены в настройках iOS."
                }
                self.refreshStatus()
            }
        }
    }

    func sendParentRiskNotification(alert: FamilyAlert) {
        let content = UNMutableNotificationContent()
        content.title = "Heimdall: тревога \(alert.childName)"
        content.body = "\(alert.level.title) \(alert.score)/100. \(alert.reasons.joined(separator: ", "))"
        content.sound = .default
        content.badge = NSNumber(value: alert.level == .critical ? 1 : 0)

        enqueue(identifier: "risk-\(alert.id.uuidString)", content: content)
    }

    func sendSafeNotification(childName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Heimdall: ребёнок в безопасности"
        content.body = "\(childName) отметил, что всё в порядке."
        content.sound = .default

        enqueue(identifier: "safe-\(UUID().uuidString)", content: content)
    }

    func sendPairingNotification(code: String) {
        let content = UNMutableNotificationContent()
        content.title = "Heimdall: код подключения"
        content.body = "Код для подключения ребёнка: \(code)"
        content.sound = .default

        enqueue(identifier: "pairing-\(UUID().uuidString)", content: content)
    }

    func clearDeliveredAndPending() {
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        refreshStatus()
    }

    private func enqueue(identifier: String, content: UNMutableNotificationContent) {
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        )
        UNUserNotificationCenter.current().add(request) { _ in
            DispatchQueue.main.async {
                self.refreshStatus()
            }
        }
    }

    private func text(for status: UNAuthorizationStatus) -> String {
        switch status {
        case .authorized, .provisional, .ephemeral:
            return "Уведомления включены. В очереди: \(pendingNotificationCount)"
        case .denied:
            return "Уведомления запрещены в настройках iOS."
        case .notDetermined:
            return "Уведомления ещё не включены."
        @unknown default:
            return "Статус уведомлений неизвестен."
        }
    }

    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound, .badge])
    }
}
