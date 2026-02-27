import AppKit
import Carbon

final class PasteService {
    static let shared = PasteService()
    private init() {}

    /// Writes text to the pasteboard and simulates Cmd+V in the frontmost app.
    /// Preserves the previous clipboard contents and restores after a delay.
    func paste(text: String) {
        let pb = NSPasteboard.general
        let previousContents = pb.string(forType: .string)
        let previousChangeCount = pb.changeCount

        pb.clearContents()
        pb.setString(text, forType: .string)

        simulateCmdV()

        // Restore previous clipboard after a short delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if pb.changeCount == previousChangeCount + 1, let prev = previousContents {
                pb.clearContents()
                pb.setString(prev, forType: .string)
            }
        }
    }

    /// Copies text to clipboard without simulating paste.
    func copyToClipboard(text: String) {
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
    }

    private func simulateCmdV() {
        let src = CGEventSource(stateID: .hidSystemState)
        let vKeyCode: CGKeyCode = 0x09

        let keyDown = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: true)
        keyDown?.flags = .maskCommand
        keyDown?.post(tap: .cghidEventTap)

        let keyUp = CGEvent(keyboardEventSource: src, virtualKey: vKeyCode, keyDown: false)
        keyUp?.flags = .maskCommand
        keyUp?.post(tap: .cghidEventTap)
    }
}
