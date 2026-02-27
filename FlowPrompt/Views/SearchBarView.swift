import SwiftUI
import AppKit

struct SearchBarView: View {
    @Binding var text: String
    var onKeyNavigation: (KeyNavigation) -> Void

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.secondary)
                .font(.system(size: 16))

            KeyInterceptingTextField(text: $text, placeholder: "Search prompts...", onKeyNavigation: onKeyNavigation)
                .font(.system(size: 16))
                .textFieldStyle(.plain)

            if !text.isEmpty {
                Button(action: { text = "" }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }

            Text("esc")
                .font(.caption2)
                .foregroundColor(.secondary)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(Color.primary.opacity(0.08))
                .cornerRadius(4)
        }
        .padding(.vertical, 8)
    }
}

struct KeyInterceptingTextField: NSViewRepresentable {
    @Binding var text: String
    var placeholder: String
    var onKeyNavigation: (KeyNavigation) -> Void

    func makeNSView(context: Context) -> NSTextField {
        let field = HotkeyTextField()
        field.delegate = context.coordinator
        field.placeholderString = placeholder
        field.isBordered = false
        field.drawsBackground = false
        field.focusRingType = .none
        field.font = .systemFont(ofSize: 16)
        field.onKeyNavigation = onKeyNavigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            field.window?.makeFirstResponder(field)
        }
        return field
    }

    func updateNSView(_ nsView: NSTextField, context: Context) {
        if nsView.stringValue != text {
            nsView.stringValue = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, NSTextFieldDelegate {
        var parent: KeyInterceptingTextField
        init(_ parent: KeyInterceptingTextField) { self.parent = parent }

        func controlTextDidChange(_ obj: Notification) {
            if let field = obj.object as? NSTextField {
                parent.text = field.stringValue
            }
        }
    }
}

final class HotkeyTextField: NSTextField {
    var onKeyNavigation: ((KeyNavigation) -> Void)?

    override func keyUp(with event: NSEvent) {
        // Let super handle it
    }

    override func performKeyEquivalent(with event: NSEvent) -> Bool {
        let flags = event.modifierFlags.intersection(.deviceIndependentFlagsMask)

        if event.keyCode == 53 { // Escape
            onKeyNavigation?(.escape)
            return true
        }

        if flags.contains(.command) {
            switch event.keyCode {
            case 36: // Cmd+Enter
                onKeyNavigation?(.cmdEnter)
                return true
            case 45: // Cmd+N
                onKeyNavigation?(.cmdN)
                return true
            case 14: // Cmd+E
                onKeyNavigation?(.cmdE)
                return true
            case 51 where flags.contains(.command): // Cmd+Delete
                onKeyNavigation?(.cmdDelete)
                return true
            default:
                break
            }
        }

        switch event.keyCode {
        case 126: // Up
            onKeyNavigation?(.up)
            return true
        case 125: // Down
            onKeyNavigation?(.down)
            return true
        case 36: // Enter (no modifier)
            if !flags.contains(.command) {
                onKeyNavigation?(.enter)
                return true
            }
        case 124: // Right
            if stringValue.isEmpty {
                onKeyNavigation?(.right)
                return true
            }
        case 123: // Left
            if stringValue.isEmpty {
                onKeyNavigation?(.left)
                return true
            }
        default:
            break
        }

        return super.performKeyEquivalent(with: event)
    }
}
