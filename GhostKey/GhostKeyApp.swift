import SwiftUI
import AppKit
import ServiceManagement

@main
struct GhostKeyApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        Settings {
            PreferencesView()
                .frame(minWidth: 520, minHeight: 420)
        }
        // No main window; status bar only.
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    private var status: StatusBarController!
    private let store = CodeStore()
    private var watcher: FileWatcher?
    private let paste = PasteManager()
    private let notifier = NotificationManager()
    private var hotkey: GlobalHotKey?
    private var prefsObserver: NSObjectProtocol?

    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
        Preferences.registerDefaults()
        
        // Register as login item by default on first launch
        enableLoginItemIfNeeded()

        do { try store.bootstrapIfNeeded() } catch {
            NSAlert(error: error).runModal()
        }
        store.loadAll()

        status = StatusBarController(store: store, paste: paste, notifier: notifier) {
            self.pasteNextCode()
        } reloadAction: {
            self.store.loadAll()
            self.status.refreshTitle()
        }

        watcher = FileWatcher(paths: [Preferences.codesURL.path, Preferences.indexURL.path]) { [weak self] in
            self?.store.loadAll()
            self?.status.refreshTitle()
        }

        notifier.requestAuthIfNeeded()

        // Register hotkey from preferences
        let hk = Preferences.hotkey
        NSLog("Registering hotkey: keyCode=\(hk.keyCode), modifiers=\(hk.modifiers)")
        
        // Validate hotkey settings
        if hk.keyCode == 0 || hk.modifiers == 0 {
            NSLog("⚠️ Invalid hotkey settings detected, using defaults")
            // Use default values: Control + Option + Cmd + Y
            let defaultModifiers: UInt32 = 4096 + 2048 + 256 // controlKey | optionKey | cmdKey
            hotkey = GlobalHotKey(keyCode: 16, modifiers: defaultModifiers) { [weak self] in
                self?.pasteNextCode()
            }
        } else {
            hotkey = GlobalHotKey(keyCode: hk.keyCode, modifiers: hk.modifiers) { [weak self] in
                self?.pasteNextCode()
            }
        }
        hotkey?.register()

        // Listen for preferences changes to rebind watchers and hotkey
        prefsObserver = NotificationCenter.default.addObserver(forName: .YCPreferencesSaved, object: nil, queue: .main) { [weak self] _ in
            guard let self = self else { return }
            self.watcher?.updatePaths([Preferences.codesURL.path, Preferences.indexURL.path])
            self.store.loadAll()
            self.status.refreshTitle()
            
            // Re-register hotkey with new settings
            let hk = Preferences.hotkey
            self.hotkey = GlobalHotKey(keyCode: hk.keyCode, modifiers: hk.modifiers) { [weak self] in
                self?.pasteNextCode()
            }
            self.hotkey?.register()
        }

        status.refreshTitle()
    }

    func applicationWillTerminate(_ notification: Notification) {
        if let obs = prefsObserver { NotificationCenter.default.removeObserver(obs) }
    }

    private func pasteNextCode() {
        guard paste.ensureAccessibilityPermission() else {
            status.flashError("Grant Accessibility to allow typing codes.")
            return
        }
        guard let code = store.peekNext() else {
            status.flashInfo("No codes available.")
            return
        }
        let ok = paste.paste(code: code)
        if ok, store.advance() {
            status.refreshTitle(didConsume: true)
        }
    }
    
    private func enableLoginItemIfNeeded() {
        // Check if this is first launch by seeing if we've set the flag before
        let hasLaunchedKey = "HasLaunchedBefore"
        let hasLaunched = UserDefaults.standard.bool(forKey: hasLaunchedKey)
        
        NSLog("=== Login Item Setup ===")
        NSLog("First launch: \(!hasLaunched)")
        NSLog("App path: \(Bundle.main.bundlePath)")
        
        // Check current status first
        do {
            let currentStatus = try SMAppService.mainApp.status
            NSLog("Current SMAppService status: \(currentStatus.rawValue)")
            
            if !hasLaunched {
                // First launch - register as login item by default
                NSLog("Attempting to register as login item...")
                
                if currentStatus == .notRegistered {
                    try SMAppService.mainApp.register()
                    let newStatus = try SMAppService.mainApp.status
                    NSLog("Registration complete. New status: \(newStatus.rawValue)")
                    
                    if newStatus == .enabled {
                        NSLog("✅ Successfully registered as login item")
                    } else {
                        NSLog("⚠️ Registration returned success but status is: \(newStatus.rawValue)")
                    }
                } else {
                    NSLog("Already registered with status: \(currentStatus.rawValue)")
                }
                
                UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            } else {
                NSLog("Not first launch. Current status: \(currentStatus.rawValue)")
            }
        } catch {
            NSLog("❌ SMAppService error: \(error)")
            NSLog("Error details: \(error.localizedDescription)")
            
            // Mark as launched even if registration fails
            if !hasLaunched {
                UserDefaults.standard.set(true, forKey: hasLaunchedKey)
            }
        }
        
        NSLog("======================")
    }
}