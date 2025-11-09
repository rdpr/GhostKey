import AppKit
import ApplicationServices


final class PasteManager {
// 0 = clipboard+cmdV, 1 = type digits
private var method: Int { Preferences.pasteMethodType }


func ensureAccessibilityPermission() -> Bool {
let opts = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
return AXIsProcessTrustedWithOptions(opts)
}


func paste(code: String) -> Bool {
switch method {
case 0:
return pasteByClipboard(code: code)
default:
return typeDigits(code: code)
}
}


private func pasteByClipboard(code: String) -> Bool {
let pb = NSPasteboard.general
pb.clearContents()
pb.setString(code, forType: .string)
// Send ⌘V
guard let src = CGEventSource(stateID: .combinedSessionState) else { return false }
let vDown = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: true) // v
vDown?.flags = .maskCommand
let vUp = CGEvent(keyboardEventSource: src, virtualKey: 0x09, keyDown: false)
vUp?.flags = .maskCommand
vDown?.post(tap: .cghidEventTap)
vUp?.post(tap: .cghidEventTap)
return true
}


private func typeDigits(code: String) -> Bool {
guard let src = CGEventSource(stateID: .combinedSessionState) else { return false }
for c in code {
guard let vk = vkFor(char: c) else { continue }
CGEvent(keyboardEventSource: src, virtualKey: vk, keyDown: true)?.post(tap: .cghidEventTap)
CGEvent(keyboardEventSource: src, virtualKey: vk, keyDown: false)?.post(tap: .cghidEventTap)
}
return true
}


private func vkFor(char: Character) -> CGKeyCode? {
switch char {
case "0": return 29
case "1": return 18
case "2": return 19
case "3": return 20
case "4": return 21
case "5": return 23
case "6": return 22
case "7": return 26
case "8": return 28
case "9": return 25
default: return nil
}
}
}
