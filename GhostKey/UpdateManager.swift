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
        // Check if we have a valid public key (not in development builds)
        let publicKey = Bundle.main.infoDictionary?["SUPublicEDKey"] as? String
        
        if publicKey == nil || publicKey?.isEmpty == true {
            NSLog("⚠️ No SUPublicEDKey found in Info.plist")
            NSLog("ℹ️ Sparkle updates are only available in release builds")
            NSLog("ℹ️ For development, check https://github.com/rdpr/GhostKey/releases")
            return
        }
        
        do {
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
        } catch {
            NSLog("⚠️ Failed to initialize Sparkle: \(error.localizedDescription)")
            NSLog("⚠️ Updates will not be available. This is normal for development builds.")
        }
    }
    
    /// Manually check for updates (called from menu)
    func checkForUpdates() {
        guard let controller = updaterController else {
            NSLog("⚠️ Update checker not available")
            showUpdateUnavailableAlert()
            return
        }
        
        controller.checkForUpdates(nil)
    }
    
    /// Show alert when updates are not available
    private func showUpdateUnavailableAlert() {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.messageText = "Updates Not Available"
            alert.informativeText = "Automatic updates are only available in release builds downloaded from GitHub.\n\nFor development builds, you can manually check for new releases at:\nhttps://github.com/rdpr/GhostKey/releases"
            alert.alertStyle = .informational
            alert.addButton(withTitle: "OK")
            alert.runModal()
        }
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

