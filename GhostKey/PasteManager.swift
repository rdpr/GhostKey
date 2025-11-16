import AppKit
import ApplicationServices
import Carbon
import CoreGraphics

final class PasteManager {
    func ensureAccessibilityPermission() -> Bool {
        let opts = [kAXTrustedCheckOptionPrompt.takeRetainedValue() as String: true] as CFDictionary
        return AXIsProcessTrustedWithOptions(opts)
    }

    func paste(code: String) -> Bool {
        guard AXIsProcessTrusted() else { return false }
        return typeDigits(code: code)
    }

    private func typeDigits(code: String) -> Bool {
        guard let src = CGEventSource(stateID: .privateState) else { return false }
        
        // Small delay before starting to ensure focus
        Thread.sleep(forTimeInterval: 0.1)
        
        for c in code {
            guard let vk = vkFor(char: c) else { continue }
            
            // Create and post key down event
            if let keyDown = CGEvent(keyboardEventSource: src, virtualKey: vk, keyDown: true) {
                keyDown.post(tap: .cgSessionEventTap)
            } else {
                continue
            }
            
            Thread.sleep(forTimeInterval: 0.02)
            
            // Create and post key up event
            if let keyUp = CGEvent(keyboardEventSource: src, virtualKey: vk, keyDown: false) {
                keyUp.post(tap: .cgSessionEventTap)
            } else {
                continue
            }
            
            Thread.sleep(forTimeInterval: 0.03)
        }
        
        // Press Return/Enter if preference is enabled
        if Preferences.pressReturnAfterPaste {
            let returnKey: CGKeyCode = 36 // Return key
            
            if let keyDown = CGEvent(keyboardEventSource: src, virtualKey: returnKey, keyDown: true) {
                keyDown.post(tap: .cgSessionEventTap)
            }
            
            Thread.sleep(forTimeInterval: 0.02)
            
            if let keyUp = CGEvent(keyboardEventSource: src, virtualKey: returnKey, keyDown: false) {
                keyUp.post(tap: .cgSessionEventTap)
            }
        }
        
        return true
    }
    
    private func vkFor(char: Character) -> CGKeyCode? {
        switch char {
        case "0": return 0x1D  // 29
        case "1": return 0x12  // 18
        case "2": return 0x13  // 19
        case "3": return 0x14  // 20
        case "4": return 0x15  // 21
        case "5": return 0x17  // 23
        case "6": return 0x16  // 22
        case "7": return 0x1A  // 26
        case "8": return 0x1C  // 28
        case "9": return 0x19  // 25
        default: return nil
        }
    }
}