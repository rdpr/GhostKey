import UserNotifications

final class NotificationManager: NSObject, UNUserNotificationCenterDelegate {
    func requestAuthIfNeeded() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        
        // Check current authorization status
        center.getNotificationSettings { settings in
            NSLog("Notification authorization status: \(settings.authorizationStatus.rawValue)")
            
            if settings.authorizationStatus == .notDetermined {
                // Request authorization
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
                    if let error = error {
                        NSLog("❌ Notification authorization error: \(error)")
                    } else {
                        NSLog("Notification authorization: \(granted ? "✅ granted" : "❌ denied")")
                    }
                }
            } else if settings.authorizationStatus == .denied {
                NSLog("⚠️ Notifications denied. Enable in System Settings → Notifications → GhostKey")
            } else {
                NSLog("✅ Notifications authorized")
            }
        }
    }

    func notifyThreshold(band: ColorBand, remaining: Int) {
        let content = UNMutableNotificationContent()
        content.title = "GhostKey"
        content.body = bandMessage(band: band, remaining: remaining)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(req)
    }

    private func bandMessage(band: ColorBand, remaining: Int) -> String {
        switch band {
        case .yellow: return "Getting low: \(remaining) codes left."
        case .orange: return "Running low: \(remaining) codes left."
        case .red: return "CRITICAL: only \(remaining) codes left!"
        default: return ""
        }
    }

    // Ensure banners appear even if app is frontmost
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}