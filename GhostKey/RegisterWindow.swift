import SwiftUI


struct RegisterView: View {
@State private var input = ""
@State private var error: String? = nil
private let store = CodeStore()


var body: some View {
VStack(alignment: .leading, spacing: 12) {
Text("Register Mode").font(.headline)
Text("Press your token (or type) then hit Return. Lines must be 6–10 digits.")
.font(.caption)
.foregroundStyle(.secondary)
TextField("Code…", text: $input)
.textFieldStyle(.roundedBorder)
.font(.system(size: 18, weight: .medium, design: .monospaced))
.onSubmit { append() }
.onChange(of: input) { _ in error = nil }
if let e = error { Text(e).foregroundStyle(.red).font(.footnote) }
HStack {
Button("Append") { append() }
Button("Close") { RegisterWindow.close() }
.keyboardShortcut(.cancelAction)
}
}
.padding(16)
.frame(width: 420)
}


private func append() {
do {
try CodeStore().append(code: input)
input = ""
} catch { self.error = error.localizedDescription }
}
}


enum RegisterWindow {
private static var window: NSWindow?


static func show() {
if window == nil {
let hosting = NSHostingView(rootView: RegisterView())
let w = NSWindow(contentRect: NSRect(x: 0, y: 0, width: 440, height: 160), styleMask: [.titled, .closable], backing: .buffered, defer: false)
w.center(); w.title = "GhostKey – Register"; w.isReleasedWhenClosed = false
w.contentView = hosting
window = w
}
window?.makeKeyAndOrderFront(nil)
NSApp.activate(ignoringOtherApps: true)
}
static func close() { window?.close() }
}
