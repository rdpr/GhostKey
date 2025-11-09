import SwiftUI
import AppKit


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


func applicationDidFinishLaunching(_ notification: Notification) {
NSApp.setActivationPolicy(.accessory) // No Dock icon (also LSUIElement)
Preferences.registerDefaults()


// Prepare storage dir & default files.
do { try store.bootstrapIfNeeded() } catch {
NSAlert(error: error).runModal()
}
store.loadAll()


// Build status bar.
status = StatusBarController(store: store, paste: paste, notifier: notifier) {
// Paste action (menu or hotkey)
self.pasteNextCode()
} reloadAction: {
self.store.loadAll()
self.status.refreshTitle()
}


// Watch files
watcher = FileWatcher(paths: [Preferences.codesURL.path, Preferences.indexURL.path]) { [weak self] in
self?.store.loadAll()
self?.status.refreshTitle()
}


// Notifications authorization (one-time)
notifier.requestAuthIfNeeded()


// Install global hotkey ⌃⌥⌘Y
hotkey = GlobalHotKey(modifiers: [.control, .option, .command], key: .y) { [weak self] in
self?.pasteNextCode()
}
hotkey?.register()


// Initial title & band
status.refreshTitle()
}


private func pasteNextCode() {
guard paste.ensureAccessibilityPermission() else {
status.flashError("Grant Accessibility to allow typing/paste.")
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
}