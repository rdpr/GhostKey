import SwiftUI
import ServiceManagement


struct PreferencesView: View {
@State private var codesPath = Preferences.codesURL.path
@State private var indexPath = Preferences.indexURL.path
@State private var yellow = Preferences.thresholds.yellow
@State private var orange = Preferences.thresholds.orange
@State private var red = Preferences.thresholds.red
@State private var pasteMethod = Preferences.pasteMethodType
@State private var launchAtLogin = (try? SMAppService.mainApp.status == .enabled) ?? false


var body: some View {
Form {
Section("Files") {
fileRow(title: "codes.txt", path: $codesPath, pick: pickCodes)
fileRow(title: "index.json", path: $indexPath, pick: pickIndex)
}
Section("Thresholds") {
Stepper(value: $yellow, in: 1...10_000) { Text("Yellow at ≤ \(yellow)") }
Stepper(value: $orange, in: 1...10_000) { Text("Orange at ≤ \(orange)") }
Stepper(value: $red, in: 0...10_000) { Text("Red at ≤ \(red)") }
}
Section("Paste method") {
Picker("Method", selection: $pasteMethod) {
Text("Clipboard + ⌘V").tag(0)
Text("Type digits").tag(1)
}
.pickerStyle(.segmented)
}
Section("General") {
Toggle("Launch at login", isOn: Binding(
get: { launchAtLogin },
set: { val in
launchAtLogin = val
try? (val ? SMAppService.mainApp.register() : SMAppService.mainApp.unregister())
}
))
}
HStack {
Spacer()
Button("Save") { save() }
.keyboardShortcut(.defaultAction)
}
}
.padding(16)
}


private func fileRow(title: String, path: Binding<String>, pick: @escaping () -> Void) -> some View {
HStack {
Text(title).frame(width: 90, alignment: .trailing)
TextField("", text: path)
Button("Choose…", action: pick)
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


private func save() {
let d = UserDefaults.standard
d.set(codesPath, forKey: "codesPath")
d.set(indexPath, forKey: "indexPath")
d.set(yellow, forKey: "yellowThreshold")
d.set(orange, forKey: "orangeThreshold")
d.set(red, forKey: "redThreshold")
d.set(pasteMethod, forKey: "pasteMethodType")
}
}


enum PreferencesWindow {
static func show() { NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil) }
}
