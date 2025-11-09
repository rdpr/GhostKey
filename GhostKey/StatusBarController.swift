import AppKit
import SwiftUI


final class StatusBarController: NSObject {
private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
private let menu = NSMenu()
private let store: CodeStore
private let paste: PasteManager
private let notifier: NotificationManager
private let pasteAction: () -> Void
private let reloadAction: () -> Void
private var lastBand: ColorBand?


init(store: CodeStore, paste: PasteManager, notifier: NotificationManager, pasteAction: @escaping () -> Void, reloadAction: @escaping () -> Void) {
self.store = store
self.paste = paste
self.notifier = notifier
self.pasteAction = pasteAction
self.reloadAction = reloadAction
super.init()
configureMenu()
statusItem.menu = menu
if let button = statusItem.button { button.font = .monospacedSystemFont(ofSize: 13, weight: .regular) }
}


func refreshTitle(didConsume: Bool = false) {
let remaining = store.remaining
let band = ColorBand.from(remaining: remaining)
statusItem.button?.title = "\(band.emoji) \(remaining)"


// Notify on downgrade only
if let last = lastBand, band.isWorse(than: last) {
notifier.notifyThreshold(band: band, remaining: remaining)
}
lastBand = band


// Submenu updates
if let pasteItem = menu.item(withTitle: "Paste next code") {
pasteItem.isEnabled = remaining > 0
}
}


func flashInfo(_ text: String) { NSApp.presentError(NSError(domain: "info", code: 0, userInfo: [NSLocalizedDescriptionKey: text])) }
func flashError(_ text: String) { NSApp.presentError(NSError(domain: "error", code: 1, userInfo: [NSLocalizedDescriptionKey: text])) }


private func configureMenu() {
menu.autoenablesItems = false
menu.items = []


let pasteItem = NSMenuItem(title: "Paste next code", action: #selector(onPaste), keyEquivalent: "")
pasteItem.target = self
menu.addItem(pasteItem)


let regItem = NSMenuItem(title: "Start Register Mode…", action: #selector(onRegister), keyEquivalent: "")
regItem.target = self
menu.addItem(regItem)


menu.addItem(.separator())


let resetItem = NSMenuItem(title: "Reset index…", action: #selector(onResetIndex), keyEquivalent: "")
resetItem.target = self
menu.addItem(resetItem)


let reloadItem = NSMenuItem(title: "Reload files", action: #selector(onReload), keyEquivalent: "r")
reloadItem.target = self
menu.addItem(reloadItem)


let openCodes = NSMenuItem(title: "Open codes.txt", action: #selector(onOpenCodes), keyEquivalent: "")
openCodes.target = self
menu.addItem(openCodes)


let openIndex = NSMenuItem(title: "Open index.json", action: #selector(onOpenIndex), keyEquivalent: "")
openIndex.target = self
menu.addItem(openIndex)


menu.addItem(.separator())


let prefsItem = NSMenuItem(title: "Preferences…", action: #selector(onPrefs), keyEquivalent: ",")
prefsItem.target = self
menu.addItem(prefsItem)


let quitItem = NSMenuItem(title: "Quit", action: #selector(onQuit), keyEquivalent: "q")
quitItem.target = self
menu.addItem(quitItem)
}


@objc private func onPaste() { pasteAction() }


@objc private func onRegister() {
RegisterWindow.show()
}


@objc private func onResetIndex() {
let alert = NSAlert()
alert.messageText = "Reset index?"
alert.informativeText = "This sets next_index to 0. You can edit index.json manually later."
alert.addButton(withTitle: "Reset")
alert.addButton(withTitle: "Cancel")
if alert.runModal() == .alertFirstButtonReturn {
store.resetIndex(to: 0)
refreshTitle()
}
}


@objc private func onReload() { reloadAction() }


@objc private func onOpenCodes() { NSWorkspace.shared.open(Preferences.codesURL) }
@objc private func onOpenIndex() { NSWorkspace.shared.open(Preferences.indexURL) }


@objc private func onPrefs() { PreferencesWindow.show() }
@objc private func onQuit() { NSApp.terminate(nil) }
}