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
        let showCounter = Preferences.showCounterInMenuBar
        
        // Create attributed string with ghost icon and optionally counter
        if let button = statusItem.button {
            // Load the ghost image
            if let ghostImage = NSImage(named: band.imageName) {
                // Create a properly sized image for menu bar (16pt)
                ghostImage.size = NSSize(width: 16, height: 16)
                
                // Create an attachment for the image
                let attachment = NSTextAttachment()
                attachment.image = ghostImage
                
                // Adjust attachment bounds to vertically align with text
                attachment.bounds = CGRect(x: 0, y: -4, width: 16, height: 16)
                
                // Create attributed string with image + optional text
                let imageString = NSAttributedString(attachment: attachment)
                let combined = NSMutableAttributedString()
                combined.append(imageString)
                
                // Only add counter text if preference is enabled
                if showCounter {
                    let textString = NSAttributedString(
                        string: " \(remaining)",
                        attributes: [
                            .font: NSFont.systemFont(ofSize: 13, weight: .regular)
                        ]
                    )
                    combined.append(textString)
                }
                
                button.attributedTitle = combined
            } else {
                // Fallback to emoji if image not found
                if showCounter {
                    button.title = "\(band.emoji) \(remaining)"
                } else {
                    button.title = band.emoji
                }
            }
        }

        // Notify on downgrade only
        if let last = lastBand, band.isWorse(than: last) {
            notifier.notifyThreshold(band: band, remaining: remaining)
        }
        lastBand = band

        // Update the counter display menu item (first item)
        if let counterItem = menu.items.first {
            counterItem.title = "\(remaining) codes remaining"
        }
        
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
        
        // Add disabled counter display at the top
        let counterItem = NSMenuItem(title: "\(store.remaining) codes remaining", action: nil, keyEquivalent: "")
        counterItem.isEnabled = false
        menu.addItem(counterItem)
        
        menu.addItem(.separator())

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
