import SwiftUI
import ServiceManagement
import Carbon.HIToolbox

struct PreferencesView: View {
    @State private var yellow = Preferences.thresholds.yellow
    @State private var orange = Preferences.thresholds.orange
    @State private var red = Preferences.thresholds.red
    @State private var launchAtLogin = (try? SMAppService.mainApp.status == .enabled) ?? false
    @State private var hotkeyKeyCode = Preferences.hotkey.keyCode
    @State private var hotkeyModifiers = Preferences.hotkey.modifiers
    @State private var isRecordingHotkey = false
    @State private var pressReturnAfterPaste = Preferences.pressReturnAfterPaste
    @State private var showCounterInMenuBar = Preferences.showCounterInMenuBar
    @State private var updateChannel = Preferences.updateChannel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Thresholds Section
                sectionHeader("Thresholds")
                VStack(alignment: .leading, spacing: 8) {
                    thresholdRow(imageName: "YellowGhost", label: "at ≤", value: $yellow, onChange: saveThresholds)
                    thresholdRow(imageName: "OrangeGhost", label: "at ≤", value: $orange, onChange: saveThresholds)
                    thresholdRow(imageName: "RedGhost", label: "at ≤", value: $red, onChange: saveThresholds)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Hotkey Section
                sectionHeader("Hotkey")
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Text("Paste shortcut")
                        HotkeyRecorder(
                            keyCode: $hotkeyKeyCode,
                            modifiers: $hotkeyModifiers,
                            isRecording: $isRecordingHotkey,
                            onCommit: saveHotkey
                        )
                        Button("Reset") {
                            isRecordingHotkey = false // Ensure recording state is cleared
                            hotkeyKeyCode = 16 // Y key
                            hotkeyModifiers = 6400 // Ctrl+Option+Cmd (4096 + 2048 + 256)
                            saveHotkey()
                        }
                        .buttonStyle(.borderless)
                    }
                    
                    Toggle("Press Return after pasting", isOn: Binding(
                        get: { pressReturnAfterPaste },
                        set: { val in
                            pressReturnAfterPaste = val
                            UserDefaults.standard.set(val, forKey: "pressReturnAfterPaste")
                        }
                    ))
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // General Section
                sectionHeader("General")
                VStack(alignment: .leading, spacing: 8) {
                    Toggle("Launch at login", isOn: Binding(
                        get: { launchAtLogin },
                        set: { val in
                            launchAtLogin = val
                            try? (val ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister())
                        }
                    ))
                    
                    Toggle("Show counter in menu bar", isOn: Binding(
                        get: { showCounterInMenuBar },
                        set: { val in
                            showCounterInMenuBar = val
                            UserDefaults.standard.set(val, forKey: "showCounterInMenuBar")
                            // Trigger menu bar refresh
                            NotificationCenter.default.post(name: .YCPreferencesSaved, object: nil)
                        }
                    ))
                    
                    HStack(spacing: 8) {
                        Text("Update channel")
                        Picker("", selection: Binding(
                            get: { updateChannel },
                            set: { val in
                                updateChannel = val
                                UserDefaults.standard.set(val, forKey: "updateChannel")
                                // Notify UpdateManager to reload allowed channels
                                NotificationCenter.default.post(name: .updateChannelChanged, object: nil)
                            }
                        )) {
                            Text("Stable").tag("stable")
                            Text("Beta").tag("beta")
                            Text("Development").tag("dev")
                        }
                        .pickerStyle(.menu)
                        .frame(width: 140)
                        
                        Text("•")
                            .foregroundColor(.secondary)
                        
                        Text(channelDescription(updateChannel))
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
            }
            .padding(20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .contentShape(Rectangle())
            .onTapGesture {
                // Unfocus any active text field when clicking outside
                NSApp.keyWindow?.makeFirstResponder(nil)
            }
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
    
    private func thresholdRow(imageName: String, label: String, value: Binding<Int>, onChange: @escaping () -> Void) -> some View {
        HStack(spacing: 8) {
            Image(imageName)
                .resizable()
                .frame(width: 14, height: 14)
            Text(label)
            TextField("", value: value, format: .number)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
                .multilineTextAlignment(.trailing)
                .onChange(of: value.wrappedValue) { _ in
                    onChange()
                }
            Stepper("", value: value, in: 0...10_000, onEditingChanged: { _ in onChange() })
                .labelsHidden()
        }
    }

    private func saveThresholds() {
        let d = UserDefaults.standard
        d.set(yellow, forKey: "yellowThreshold")
        d.set(orange, forKey: "orangeThreshold")
        d.set(red, forKey: "redThreshold")
        NotificationCenter.default.post(name: .YCPreferencesSaved, object: nil)
    }
    
    private func saveHotkey() {
        let d = UserDefaults.standard
        d.set(Int(hotkeyKeyCode), forKey: "hotkeyKeyCode")
        d.set(Int(hotkeyModifiers), forKey: "hotkeyModifiers")
        NotificationCenter.default.post(name: .YCPreferencesSaved, object: nil)
    }
    
    private func channelDescription(_ channel: String) -> String {
        switch channel {
        case "stable":
            return "Only stable releases"
        case "beta":
            return "Stable + beta releases"
        case "dev":
            return "All releases (unstable)"
        default:
            return ""
        }
    }
}

struct HotkeyRecorder: NSViewRepresentable {
    @Binding var keyCode: UInt32
    @Binding var modifiers: UInt32
    @Binding var isRecording: Bool
    var onCommit: () -> Void
    
    func makeNSView(context: Context) -> RecorderTextField {
        let textField = RecorderTextField()
        textField.isEditable = true
        textField.isSelectable = true
        textField.isBordered = true
        textField.bezelStyle = .roundedBezel
        textField.delegate = context.coordinator
        textField.placeholderString = "Click to record..."
        textField.coordinator = context.coordinator
        updateDisplay(textField)
        return textField
    }
    
    func updateNSView(_ nsView: RecorderTextField, context: Context) {
        updateDisplay(nsView)
    }
    
    private func updateDisplay(_ textField: NSTextField) {
        if isRecording {
            textField.stringValue = "Press keys..."
            textField.textColor = .systemBlue
        } else {
            textField.stringValue = GlobalHotKey.displayString(keyCode: keyCode, modifiers: modifiers)
            textField.textColor = .labelColor
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: HotkeyRecorder
        var monitor: Any?
        
        init(_ parent: HotkeyRecorder) {
            self.parent = parent
        }
        
        func controlTextDidBeginEditing(_ obj: Notification) {
            guard let textField = obj.object as? NSTextField else { return }
            parent.isRecording = true
            
            // Notify app to temporarily disable global hotkey
            NotificationCenter.default.post(name: .disableGlobalHotkey, object: nil)
            
            // Start monitoring key events
            monitor = NSEvent.addLocalMonitorForEvents(matching: [.keyDown, .flagsChanged]) { [weak self] event in
                guard let self = self else { return event }
                
                if event.type == .keyDown {
                    let mods = event.modifierFlags
                    var carbonMods: UInt32 = 0
                    
                    if mods.contains(.control) { carbonMods |= UInt32(controlKey) }
                    if mods.contains(.option) { carbonMods |= UInt32(optionKey) }
                    if mods.contains(.shift) { carbonMods |= UInt32(shiftKey) }
                    if mods.contains(.command) { carbonMods |= UInt32(cmdKey) }
                    
                    // Require at least one modifier
                    if carbonMods != 0 {
                        self.parent.keyCode = UInt32(event.keyCode)
                        self.parent.modifiers = carbonMods
                        self.stopRecording(textField)
                        self.parent.onCommit()
                    }
                    return nil // Consume the event
                }
                
                return event
            }
        }
        
        func controlTextDidEndEditing(_ obj: Notification) {
            stopRecording(obj.object as? NSTextField)
        }
        
        func startRecording() {
            parent.isRecording = true
        }
        
        private func stopRecording(_ textField: NSTextField?) {
            parent.isRecording = false
            if let monitor = monitor {
                NSEvent.removeMonitor(monitor)
                self.monitor = nil
            }
            textField?.window?.makeFirstResponder(nil)
            
            // Re-enable global hotkey
            NotificationCenter.default.post(name: .enableGlobalHotkey, object: nil)
        }
    }
}

class RecorderTextField: NSTextField {
    weak var coordinator: HotkeyRecorder.Coordinator?
    
    override func mouseDown(with event: NSEvent) {
        // Make this text field the first responder to trigger editing
        if let window = self.window {
            window.makeFirstResponder(self)
        }
        coordinator?.startRecording()
        super.mouseDown(with: event)
    }
    
    override func becomeFirstResponder() -> Bool {
        let result = super.becomeFirstResponder()
        if result {
            // Trigger the delegate method
            NotificationCenter.default.post(
                name: NSTextField.textDidBeginEditingNotification,
                object: self
            )
        }
        return result
    }
}

extension Notification.Name { 
    static let YCPreferencesSaved = Notification.Name("YCPreferencesSaved")
    static let disableGlobalHotkey = Notification.Name("DisableGlobalHotkey")
    static let enableGlobalHotkey = Notification.Name("EnableGlobalHotkey")
    static let updateChannelChanged = Notification.Name("UpdateChannelChanged")
}

enum PreferencesWindow {
    private static var window: NSWindow?

    static func show() {
        if window == nil {
            let hosting = NSHostingView(rootView: PreferencesView())
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 460), styleMask: [.titled, .closable], backing: .buffered, defer: false)
            w.center(); w.title = "GhostKey Preferences"; w.isReleasedWhenClosed = false
            w.contentView = hosting
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
