import Carbon
import AppKit
import Combine

final class HotkeyService {
    static let shared = HotkeyService()

    var onLauncherHotkey: (() -> Void)?
    var onQuickSaveHotkey: (() -> Void)?

    private var launcherHotkeyRef: EventHotKeyRef?
    private var quickSaveHotkeyRef: EventHotKeyRef?

    private static var instance: HotkeyService?

    private init() {
        HotkeyService.instance = self
    }

    func register() {
        installHandler()
        // Ctrl+Cmd+P  (keycode 35 = P)
        registerHotkey(id: 1, keyCode: UInt32(kVK_ANSI_P), modifiers: UInt32(cmdKey | controlKey), ref: &launcherHotkeyRef)
        // Ctrl+Cmd+S  (keycode 1 = S)
        registerHotkey(id: 2, keyCode: UInt32(kVK_ANSI_S), modifiers: UInt32(cmdKey | controlKey), ref: &quickSaveHotkeyRef)
    }

    func unregister() {
        if let ref = launcherHotkeyRef { UnregisterEventHotKey(ref); launcherHotkeyRef = nil }
        if let ref = quickSaveHotkeyRef { UnregisterEventHotKey(ref); quickSaveHotkeyRef = nil }
    }

    // MARK: - Private

    private func registerHotkey(id: UInt32, keyCode: UInt32, modifiers: UInt32, ref: inout EventHotKeyRef?) {
        var hotkeyID = EventHotKeyID(signature: OSType(0x464C5057), id: id) // "FLPW"
        let status = RegisterEventHotKey(keyCode, modifiers, hotkeyID, GetApplicationEventTarget(), 0, &ref)
        if status != noErr {
            print("FlowPrompt: failed to register hotkey id=\(id) status=\(status)")
        }
    }

    private func installHandler() {
        var eventType = EventTypeSpec(eventClass: OSType(kEventClassKeyboard), eventKind: UInt32(kEventHotKeyPressed))
        InstallEventHandler(GetApplicationEventTarget(), { (_, event, _) -> OSStatus in
            var hotkeyID = EventHotKeyID()
            GetEventParameter(event, EventParamName(kEventParamDirectObject), EventParamType(typeEventHotKeyID),
                              nil, MemoryLayout<EventHotKeyID>.size, nil, &hotkeyID)
            switch hotkeyID.id {
            case 1: HotkeyService.instance?.onLauncherHotkey?()
            case 2: HotkeyService.instance?.onQuickSaveHotkey?()
            default: break
            }
            return noErr
        }, 1, &eventType, nil, nil)
    }
}
