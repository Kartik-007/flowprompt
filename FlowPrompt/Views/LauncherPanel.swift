import AppKit
import SwiftUI

final class LauncherPanel: NSPanel {
    init() {
        super.init(
            contentRect: NSRect(x: 0, y: 0, width: 620, height: 460),
            styleMask: [.nonactivatingPanel, .fullSizeContentView, .borderless],
            backing: .buffered,
            defer: true
        )

        isFloatingPanel = true
        level = .floating
        isOpaque = false
        backgroundColor = .clear
        hasShadow = true
        hidesOnDeactivate = false
        isMovableByWindowBackground = false
        collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary]
        animationBehavior = .utilityWindow

        let hostView = NSHostingView(rootView: LauncherView())
        hostView.frame = contentRect(forFrameRect: frame)
        contentView = hostView
    }

    func showCentered() {
        let screen = NSScreen.main ?? NSScreen.screens.first!
        let screenFrame = screen.visibleFrame
        let x = screenFrame.midX - frame.width / 2
        let y = screenFrame.midY + screenFrame.height * 0.1
        setFrameOrigin(NSPoint(x: x, y: y))
        makeKeyAndOrderFront(nil)

        // Ensure the SwiftUI view's text field gets focus
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            self.makeKey()
        }
    }

    func dismiss() {
        orderOut(nil)
    }

    override var canBecomeKey: Bool { true }
}
