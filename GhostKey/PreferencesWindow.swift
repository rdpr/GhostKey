import SwiftUI
import ServiceManagement
import Carbon.HIToolbox

struct PreferencesView: View {
    @State private var codesPath = Preferences.codesURL.path
    @State private var indexPath = Preferences.indexURL.path
    @State private var yellow = Preferences.thresholds.yellow
    @State private var orange = Preferences.thresholds.orange
    @State private var red = Preferences.thresholds.red
    @State private var launchAtLogin = (try? SMAppService.mainApp.status == .enabled) ?? false
    @State private var hotkeyKeyCode = Preferences.hotkey.keyCode
    @State private var hotkeyModifiers = Preferences.hotkey.modifiers
    @State private var isRecordingHotkey = false
    @State private var pressReturnAfterPaste = Preferences.pressReturnAfterPaste

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Files Section
                sectionHeader("Files")
                VStack(spacing: 8) {
                    fileRow(title: "codes.txt", path: $codesPath, pick: pickCodes, onCommit: saveCodesPath)
                    fileRow(title: "index.json", path: $indexPath, pick: pickIndex, onCommit: saveIndexPath)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Thresholds Section
                sectionHeader("Thresholds")
                VStack(spacing: 8) {
                    thresholdRow(label: "🟡 Yellow at ≤", value: $yellow, onChange: saveThresholds)
                    thresholdRow(label: "🟠 Orange at ≤", value: $orange, onChange: saveThresholds)
                    thresholdRow(label: "🔴 Red at ≤", value: $red, onChange: saveThresholds)
                }
                
                Divider()
                    .padding(.vertical, 4)
                
                // Hotkey Section
                sectionHeader("Hotkey")
                HStack {
                    Text("Paste shortcut")
                        .frame(width: 120, alignment: .trailing)
                    HotkeyRecorder(
                        keyCode: $hotkeyKeyCode,
                        modifiers: $hotkeyModifiers,
                        isRecording: $isRecordingHotkey,
                        onCommit: saveHotkey
                    )
                    Button("Reset") {
                        hotkeyKeyCode = 16 // Y
                        hotkeyModifiers = 7424 // Ctrl+Option+Cmd
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
                .padding(.leading, 120)
                
                Divider()
                    .padding(.vertical, 4)
                
                // General Section
                sectionHeader("General")
                Toggle("Launch at login", isOn: Binding(
                    get: { launchAtLogin },
                    set: { val in
                        launchAtLogin = val
                        try? (val ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister())
                    }
                ))
                
            }
            .padding(20)
        }
    }
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.secondary)
            .textCase(.uppercase)
    }
    
    private func thresholdRow(label: String, value: Binding<Int>, onChange: @escaping () -> Void) -> some View {
        HStack {
            Text(label)
                .frame(width: 120, alignment: .trailing)
            HStack(spacing: 4) {
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
    }

    private func fileRow(title: String, path: Binding<String>, pick: @escaping () -> Void, onCommit: @escaping () -> Void) -> some View {
        HStack {
            Text(title).frame(width: 90, alignment: .trailing)
            TextField("", text: path, onCommit: onCommit)
            Button("Choose…") {
                pick()
                onCommit()
            }
        }
    }

    private func pickCodes() { if let p = pickFile(allowCreate: true) { codesPath = p.path } }
    private func pickIndex() { if let p = pickFile(allowCreate: true) { indexPath = p.path } }

    private func pickFile(allowCreate: Bool) -> URL? {
        let p = NSOpenPanel()
        p.canChooseFiles = true; p.canChooseDirectories = false
        p.allowsMultipleSelection = false
        p.canCreateDirectories = allowCreate
        return p.runModal() == .OK ? p.url : nil
    }

    private func saveCodesPath() {
        UserDefaults.standard.set(codesPath, forKey: "codesPath")
        NotificationCenter.default.post(name: .YCPreferencesSaved, object: nil)
    }
    
    private func saveIndexPath() {
        UserDefaults.standard.set(indexPath, forKey: "indexPath")
        NotificationCenter.default.post(name: .YCPreferencesSaved, object: nil)
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

extension Notification.Name { static let YCPreferencesSaved = Notification.Name("YCPreferencesSaved") }

enum PreferencesWindow {
    private static var window: NSWindow?

    static func show() {
        if window == nil {
            let hosting = NSHostingView(rootView: PreferencesView())
            let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 580, height: 520), styleMask: [.titled, .closable, .resizable], backing: .buffered, defer: false)
            w.center(); w.title = "GhostKey Preferences"; w.isReleasedWhenClosed = false
            w.contentView = hosting
            w.minSize = NSSize(width: 540, height: 460)
            window = w
        }
        window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
}
