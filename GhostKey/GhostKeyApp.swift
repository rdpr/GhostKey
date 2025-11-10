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
        hotkey = GlobalHotKey(keyCode: hk.keyCode, modifiers: hk.modifiers) { [weak self] in
            self?.pasteNextCode()
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
        
        if !hasLaunched {
            // First launch - register as login item by default
            try? SMAppService.mainApp.register()
            UserDefaults.standard.set(true, forKey: hasLaunchedKey)
        }
    }
}