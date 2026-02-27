import AppKit
import Carbon

final class CaptureService {
    static let shared = CaptureService()
    private init() {}

    /// Tries to capture the currently selected text by simulating Cmd+C,
    /// then reading from the pasteboard. Falls back to whatever is already on the clipboard.
    func captureSelectedText(completion: @escaping (String) -> Void) {
        let pb = NSPasteboard.general
        let previousChangeCount = pb.changeCount

        simulateCmdC()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if pb.changeCount != previousChangeCount, let text = pb.string(forType: .string), !text.isEmpty {
                completion(text)
            } else if let text = pb.string(forType: .string), !text.isEmpty {
                completion(text)
            } else {
                completion("")
            }
        }
    }

    private func simulateCmdC() {
        let src = CGEventSource(stateID: .hidSystemState)
        let cKeyCode: CGKeyCode = 0x08

        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: cKeyCode, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: cKeyCode, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}
