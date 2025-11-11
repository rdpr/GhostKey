import SwiftUI
import AppKit

struct WelcomeView: View {
    @State private var currentStep = 0
    @State private var dontShowAgain = false
    
    private let steps: [WelcomeStep] = [
        WelcomeStep(
            title: "Welcome to GhostKey",
            emoji: nil, // Use app icon instead
            description: "Your menu bar companion for managing and pasting one-time codes.",
            details: [
                "Store codes in a simple text file",
                "Paste with a global hotkey (⌃⌥⌘Y)",
                "Visual counter shows remaining codes",
                "Codes are automatically deleted after use"
            ]
        ),
        WelcomeStep(
            title: "Getting Started",
            emoji: "🚀",
            description: "Here's what you need to do first:",
            details: [
                "Grant Accessibility permission (required)",
                "Add codes via menu → 'Manage codes…'",
                "Or edit codes.txt manually",
                "Press ⌃⌥⌘Y to paste your first code"
            ]
        ),
        WelcomeStep(
            title: "Understanding the Counter",
            emoji: "🟢",
            description: "The menu bar icon shows how many codes remain:",
            details: [
                "🟢 Green: Plenty of codes available",
                "🟡 Yellow: Getting low (≤40)",
                "🟠 Orange: Running out (≤20)",
                "🔴 Red: Critical - add more! (≤10)"
            ]
        ),
        WelcomeStep(
            title: "You're All Set!",
            emoji: "✨",
            description: "Ready to start using GhostKey.",
            details: [
                "Customize your hotkey in Preferences",
                "Adjust color thresholds to your needs",
                "Enable 'Launch at Login' to start automatically",
                "Access this guide anytime from the menu"
            ]
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Main content area
            VStack(spacing: 24) {
                // Step indicator
                HStack(spacing: 8) {
                    ForEach(0..<steps.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentStep ? Color.accentColor : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                    }
                }
                .padding(.top, 20)
                
                // Content
                VStack(spacing: 16) {
                    // Show app icon for first step, emoji for others
                    if let emoji = steps[currentStep].emoji {
                        Text(emoji)
                            .font(.system(size: 64))
                    } else if let appIcon = NSImage(named: "AppIcon") {
                        Image(nsImage: appIcon)
                            .resizable()
                            .frame(width: 80, height: 80)
                    }
                    
                    Text(steps[currentStep].title)
                        .font(.system(size: 24, weight: .bold))
                    
                    Text(steps[currentStep].description)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    VStack(alignment: .leading, spacing: 10) {
                        ForEach(steps[currentStep].details, id: \.self) { detail in
                            HStack(alignment: .top, spacing: 10) {
                                Text("•")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(.accentColor)
                                Text(detail)
                                    .font(.system(size: 13))
                                    .fixedSize(horizontal: false, vertical: true)
                            }
                        }
                    }
                    .frame(maxWidth: 400)
                    .padding(.horizontal, 40)
                    .padding(.top, 8)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
            }
            
            Divider()
            
            // Bottom controls
            HStack {
                Toggle("Don't show this again", isOn: $dontShowAgain)
                    .font(.system(size: 12))
                
                Spacer()
                
                if currentStep > 0 {
                    Button("Back") {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentStep -= 1
                        }
                    }
                    .keyboardShortcut("[", modifiers: [.command])
                }
                
                Button(currentStep < steps.count - 1 ? "Next" : "Get Started") {
                    if currentStep < steps.count - 1 {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            currentStep += 1
                        }
                    } else {
                        finishWelcome()
                    }
                }
                .keyboardShortcut(.defaultAction)
            }
            .padding(16)
        }
        .frame(width: 560, height: 460)
    }
    
    private func finishWelcome() {
        if dontShowAgain {
            UserDefaults.standard.set(true, forKey: "hasSeenWelcome")
        }
        WelcomeWindow.close()
        
        // Open Manage Codes window to help user get started
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            ManageCodesWindow.show()
        }
    }
}

struct WelcomeStep {
    let title: String
    let emoji: String?
    let description: String
    let details: [String]
}

enum WelcomeWindow {
    private static var window: NSWindow?
    
    static func show() {
        if window == nil {
            let hosting = NSHostingView(rootView: WelcomeView())
            let w = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 560, height: 460),
                styleMask: [.titled, .closable],
                backing: .buffered,
                defer: false
            )
            w.center()
            w.title = "Welcome to GhostKey"
            w.isReleasedWhenClosed = false
            w.contentView = hosting
            w.level = .floating // Show above other windows
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    static func close() {
        window?.close()
        window = nil
    }
    
    static func shouldShow() -> Bool {
        return !UserDefaults.standard.bool(forKey: "hasSeenWelcome")
    }
}

