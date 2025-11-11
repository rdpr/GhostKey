import AppKit
import SwiftUI

final class StatusBarController: NSObject {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
    private let menu = NSMenu()
    private let store: CodeStore
    private let paste: PasteManager
    private let notifier: NotificationManager
    private let pasteAction: () -> Void
    private var lastBand: ColorBand?

    init(store: CodeStore, paste: PasteManager, notifier: NotificationManager, pasteAction: @escaping () -> Void) {
        self.store = store
        self.paste = paste
        self.notifier = notifier
        self.pasteAction = pasteAction
        super.init()
        configureMenu()
        statusItem.menu = menu
        if let button = statusItem.button { button.font = .systemFont(ofSize: 13, weight: .regular) }
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

        let manageItem = NSMenuItem(title: "Manage codes…", action: #selector(onManage), keyEquivalent: "")
        manageItem.target = self
        menu.addItem(manageItem)

        let pasteItem = NSMenuItem(title: "Paste next code", action: #selector(onPaste), keyEquivalent: "")
        pasteItem.target = self
        menu.addItem(pasteItem)

        menu.addItem(.separator())

        let prefsItem = NSMenuItem(title: "Preferences…", action: #selector(onPrefs), keyEquivalent: ",")
        prefsItem.target = self
        menu.addItem(prefsItem)
        
        let welcomeItem = NSMenuItem(title: "Show Welcome Guide", action: #selector(onWelcome), keyEquivalent: "")
        welcomeItem.target = self
        menu.addItem(welcomeItem)

        let quitItem = NSMenuItem(title: "Quit", action: #selector(onQuit), keyEquivalent: "q")
        quitItem.target = self
        menu.addItem(quitItem)
    }

    @objc private func onPaste() { pasteAction() }

    @objc private func onManage() {
        ManageCodesWindow.show()
    }

    @objc private func onPrefs() { PreferencesWindow.show() }
    @objc private func onWelcome() { WelcomeWindow.show() }
    @objc private func onQuit() { NSApp.terminate(nil) }
}