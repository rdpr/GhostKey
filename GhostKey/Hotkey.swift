import AppKit
import Carbon.HIToolbox


struct HotKeyModifiers: OptionSet { let rawValue: UInt32
    static let command = HotKeyModifiers(rawValue: UInt32(cmdKey))
    static let option = HotKeyModifiers(rawValue: UInt32(optionKey))
    static let control = HotKeyModifiers(rawValue: UInt32(controlKey))
    static let shift = HotKeyModifiers(rawValue: UInt32(shiftKey))
}


enum HotKeyKey { case y
var carbonKeyCode: UInt32 { switch self { case .y: return 16 } } // kVK_ANSI_Y
}


final class GlobalHotKey {
private var hotKeyRef: EventHotKeyRef? = nil
private var eventHandler: EventHandlerRef? = nil
private let handler: () -> Void
private let modifiers: HotKeyModifiers
private let key: HotKeyKey


init(modifiers: HotKeyModifiers, key: HotKeyKey, handler: @escaping () -> Void) {
self.modifiers = modifiers
self.key = key
self.handler = handler
}


func register() {
var eventSpec = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyReleased))
let callback: EventHandlerUPP = { _, _, userData in
let mySelf = Unmanaged<GlobalHotKey>.fromOpaque(userData!).takeUnretainedValue()
mySelf.handler()
return noErr
}
let selfPtr = Unmanaged.passUnretained(self).toOpaque()
InstallEventHandler(GetApplicationEventTarget(), callback, 1, &eventSpec, selfPtr, &eventHandler)


let id = EventHotKeyID(signature: OSType(0x79636465), id: 1) // 'ycde'
RegisterEventHotKey(key.carbonKeyCode, modifiers.rawValue, id, GetApplicationEventTarget(), 0, &hotKeyRef)
}


deinit {
if let hk = hotKeyRef { UnregisterEventHotKey(hk) }
if let eh = eventHandler { RemoveEventHandler(eh) }
}
}
