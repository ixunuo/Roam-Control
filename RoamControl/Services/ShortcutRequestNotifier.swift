import Foundation
import UserNotifications

enum ShortcutRequest: String {
    case openLocalDevVPN = "OpenLocalVPN"
    case turnOffMobileData = "TurnOffData"
    case turnOnMobileData = "TurnOnData"
}

/// Asks for the user's Shortcuts to run by posting a local notification.
/// A personal automation in the Shortcuts app can trigger on notifications
/// from this app, which lets the app request a shortcut without opening the
/// Shortcuts app or leaving the foreground.
final class ShortcutRequestNotifier: NSObject, UNUserNotificationCenterDelegate {
    static let shared = ShortcutRequestNotifier()

    private override init() {
        super.init()
    }

    func register() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { _, _ in }
    }

    func post(_ request: ShortcutRequest) {
        let content = UNMutableNotificationContent()
        content.title = LocalizedText.text("Roam Control")
        content.body = LocalizedText.format("Invoking shortcut: %@", request.rawValue)
        // No sound on purpose: the request is a silent, vibration-free signal.

        UNUserNotificationCenter.current().add(
            UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )
        )
    }

    // Foreground requests still have to surface, otherwise the automation
    // filter never sees them.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .list]
    }
}
