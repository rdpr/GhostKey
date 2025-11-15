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
        let feedURL = Bundle.main.infoDictionary?["SUFeedURL"] as? String
        NSLog("📡 Feed URL: \(feedURL ?? "nil")")
        return feedURL
    }
    
    func updater(_ updater: SPUUpdater, didFinishLoading appcast: SUAppcast) {
        NSLog("📦 Appcast loaded successfully")
        NSLog("📦 Appcast items count: \(appcast.items.count)")
        
        if let firstItem = appcast.items.first {
            NSLog("📦 Latest item version: \(firstItem.displayVersionString)")
            NSLog("📦 Latest item download URL: \(firstItem.fileURL?.absoluteString ?? "nil")")
            
            // Log signature info
            if let signature = firstItem.propertiesDictionary["sparkle:edSignature"] as? String {
                NSLog("🔐 Item has EdDSA signature: \(signature.prefix(50))...")
            } else {
                NSLog("⚠️ Item missing EdDSA signature!")
            }
            
            // Log all properties for debugging
            NSLog("📋 Item properties: \(firstItem.propertiesDictionary)")
        }
    }
    
    func updaterDidNotFindUpdate(_ updater: SPUUpdater) {
        NSLog("✅ No updates available - running latest version")
        NSLog("✅ Current version: \(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "unknown")")
    }
    
    func updater(_ updater: SPUUpdater, didFindValidUpdate item: SUAppcastItem) {
        NSLog("🎉 Update found: \(item.displayVersionString)")
        NSLog("🎉 Download URL: \(item.fileURL?.absoluteString ?? "nil")")
        NSLog("🎉 File size: \(item.contentLength) bytes")
        
        // Check public key
        if let publicKey = Bundle.main.infoDictionary?["SUPublicEDKey"] as? String {
            NSLog("🔑 Public key in bundle: \(publicKey.prefix(20))...")
        } else {
            NSLog("❌ No public key in bundle!")
        }
    }
    
    func updater(_ updater: SPUUpdater, willInstallUpdate item: SUAppcastItem) {
        NSLog("⬇️ Installing update: \(item.displayVersionString)")
    }
    
    func updater(_ updater: SPUUpdater, didAbortWithError error: Error) {
        NSLog("❌ Update error: \(error.localizedDescription)")
        NSLog("❌ Error domain: \((error as NSError).domain)")
        NSLog("❌ Error code: \((error as NSError).code)")
        NSLog("❌ Error user info: \((error as NSError).userInfo)")
        
        // If it's a validation error, log more details
        if (error as NSError).domain == "SUSparkleErrorDomain" {
            NSLog("❌ This is a Sparkle error")
        }
    }
    
    func updater(_ updater: SPUUpdater, failedToDownloadUpdate item: SUAppcastItem, error: Error) {
        NSLog("❌ Failed to download update: \(error.localizedDescription)")
    }
    
    func updater(_ updater: SPUUpdater, didDownloadUpdate item: SUAppcastItem) {
        NSLog("✅ Successfully downloaded update: \(item.displayVersionString)")
    }
    
    func updater(_ updater: SPUUpdater, didExtractUpdate item: SUAppcastItem) {
        NSLog("✅ Successfully extracted update: \(item.displayVersionString)")
    }
}

