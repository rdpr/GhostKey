import UserNotifications


final class NotificationManager {
func requestAuthIfNeeded() {
UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { _, _ in }
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
}
