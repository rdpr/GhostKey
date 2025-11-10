import AppKit
import Carbon.HIToolbox

final class GlobalHotKey {
    private var hotKeyRef: EventHotKeyRef? = nil
    private var eventHandler: EventHandlerRef? = nil
    private let handler: () -> Void
    private let modifiers: UInt32
    private let keyCode: UInt32

    init(keyCode: UInt32, modifiers: UInt32, handler: @escaping () -> Void) {
        self.keyCode = keyCode
        self.modifiers = modifiers
        self.handler = handler
    }

    func register() {
        unregister()
        
        NSLog("🔑 Registering hotkey: keyCode=\(keyCode), modifiers=\(modifiers)")
        NSLog("   Display: \(GlobalHotKey.displayString(keyCode: keyCode, modifiers: modifiers))")
        
        var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased))
        let callback: EventHandlerUPP = { _, _, userData in
            let mySelf = Unmanaged<GlobalHotKey>.fromOpaque(userData!).takeUnretainedValue()
            mySelf.handler()
            return noErr
        }
        let selfPtr = Unmanaged.passUnretained(self).toOpaque()
        
        let eventStatus = InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventSpec, selfPtr, &eventHandler)
        if eventStatus != noErr {
            NSLog("❌ Failed to install event handler: \(eventStatus)")
            return
        }
        
        let id = EventHotKeyID(signature: OSType(0x79636465), id: 1) // 'ycde'
        let registerStatus = RegisterEventHotKey(keyCode, modifiers, id, GetApplicationEventTarget(), 0, &hotKeyRef)
        
        if registerStatus != noErr {
            NSLog("❌ Failed to register hotkey: \(registerStatus)")
            if registerStatus == -9878 { // eventHotKeyExistsErr
                NSLog("   Error: Hotkey already registered by another app")
            }
        } else {
            NSLog("✅ Hotkey registered successfully")
        }
    }
    
    func unregister() {
        if let hk = hotKeyRef { 
            UnregisterEventHotKey(hk)
            hotKeyRef = nil
        }
        if let eh = eventHandler { 
            RemoveEventHandler(eh)
            eventHandler = nil
        }
    }

    deinit {
        unregister()
    }
}

// Helper for displaying hotkey combinations
extension GlobalHotKey {
    static func displayString(keyCode: UInt32, modifiers: UInt32) -> String {
        var parts: [String] = []
        
        if modifiers & UInt32(controlKey) != 0 { parts.append("⌃") }
        if modifiers & UInt32(optionKey) != 0 { parts.append("⌥") }
        if modifiers & UInt32(shiftKey) != 0 { parts.append("⇧") }
        if modifiers & UInt32(cmdKey) != 0 { parts.append("⌘") }
        
        if let keyName = keyCodeToString(keyCode) {
            parts.append(keyName)
        } else {
            parts.append("?")
        }
        
        return parts.joined()
    }
    
    private static func keyCodeToString(_ keyCode: UInt32) -> String? {
        let keyMap: [UInt32: String] = [
            0: "A", 1: "S", 2: "D", 3: "F", 4: "H", 5: "G", 6: "Z", 7: "X",
            8: "C", 9: "V", 11: "B", 12: "Q", 13: "W", 14: "E", 15: "R",
            16: "Y", 17: "T", 18: "1", 19: "2", 20: "3", 21: "4", 22: "6",
            23: "5", 24: "=", 25: "9", 26: "7", 27: "-", 28: "8", 29: "0",
            30: "]", 31: "O", 32: "U", 33: "[", 34: "I", 35: "P", 37: "L",
            38: "J", 39: "'", 40: "K", 41: ";", 42: "\\", 43: ",", 44: "/",
            45: "N", 46: "M", 47: ".", 49: "Space", 51: "⌫", 53: "⎋",
            36: "↩", 48: "⇥", 123: "←", 124: "→", 125: "↓", 126: "↑"
        ]
        return keyMap[keyCode]
    }
}
