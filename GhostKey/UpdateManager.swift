import Foundation
import AppKit
import Sparkle

/// Manages automatic updates using Sparkle framework
final class UpdateManager: NSObject {
    static let shared = UpdateManager()
    
    private var updaterController: SPUStandardUpdaterController?
    
    private override init() {
        super.init()
    }
    
    /// Initialize Sparkle updater
    func setup() {
        // Create updater controller
        updaterController = SPUStandardUpdaterController(
            startingUpdater: true,
            updaterDelegate: self,
            userDriverDelegate: nil
        )
        
        NSLog("✅ Sparkle updater initialized")
        
        // Check for updates automatically based on user preference
        if updaterController?.updater.automaticallyChecksForUpdates == true {
            NSLog("📦 Automatic update checks enabled")
        }
    }
    
    /// Manually check for updates (called from menu)
    func checkForUpdates() {
        updaterController?.checkForUpdates(nil)
    }
    
    /// Get the updater instance (for menu item binding)
    var updater: SPUUpdater? {
        updaterController?.updater
    }
}

// MARK: - SPUUpdaterDelegate

extension UpdateManager: SPUUpdaterDelegate {
    func feedURLString(for updater: SPUUpdater) -> String? {
        // Use the feed URL from Info.plist, or provide a default
        return Bundle.main.infoDictionary?["SUFeedURL"] as? String
    }
    
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        NSLog("📦 Appcast loaded successfully")
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        NSLog("✅ No updates available - running latest version")
    }
    
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        NSLog("🎉 Update found: \(item.displayVersionString)")
    }
    
    func updater(_ updater: SPUUpdater, willInstallUpdate item: SUAppcastItem) {
        NSLog("⬇️ Installing update: \(item.displayVersionString)")
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        NSLog("❌ Update error: \(error.localizedDescription)")
    }
}

