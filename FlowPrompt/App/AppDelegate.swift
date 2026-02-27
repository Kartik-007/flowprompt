import AppKit
import SwiftUI

final class AppDelegate: NSObject, NSApplicationDelegate {
    static var shared: AppDelegate?

    private var statusItem: NSStatusItem!
    private var launcherPanel: LauncherPanel?
    private var quickSavePanel: QuickSavePanel?
    private var settingsWindow: NSWindow?
    private var editorWindow: NSWindow?

    func applicationDidFinishLaunching(_ notification: Notification) {
        AppDelegate.shared = self

        setupMenuBar()
        HotkeyService.shared.onLauncherHotkey = { [weak self] in
            DispatchQueue.main.async { self?.toggleLauncher() }
        }
        HotkeyService.shared.onQuickSaveHotkey = { [weak self] in
            DispatchQueue.main.async { self?.triggerQuickSave() }
        }
        HotkeyService.shared.register()

        checkAccessibilityPermission()
    }

    func applicationWillTerminate(_ notification: Notification) {
        HotkeyService.shared.unregister()
    }

    // MARK: - Menu Bar

    private func setupMenuBar() {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "text.bubble", accessibilityDescription: "FlowPrompt")
            button.image?.size = NSSize(width: 18, height: 18)
            button.image?.isTemplate = true
        }

        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Open Launcher (⌃⌘P)", action: #selector(openLauncher), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Quick Save (⌃⌘S)", action: #selector(openQuickSave), keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "New Prompt...", action: #selector(newPrompt), keyEquivalent: "n"))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Settings...", action: #selector(openSettings), keyEquivalent: ","))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit FlowPrompt", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))

        statusItem.menu = menu
    }

    // MARK: - Launcher

    @objc private func openLauncher() {
        showLauncher()
    }

    func toggleLauncher() {
        if let panel = launcherPanel, panel.isVisible {
            dismissLauncher()
        } else {
            showLauncher()
        }
    }

    private func showLauncher() {
        dismissQuickSave()
        if launcherPanel == nil {
            launcherPanel = LauncherPanel()
        }
        launcherPanel?.showCentered()
    }

    func dismissLauncher() {
        launcherPanel?.dismiss()
        launcherPanel = nil
    }

    // MARK: - Quick Save

    @objc private func openQuickSave() {
        triggerQuickSave()
    }

    func triggerQuickSave() {
        dismissLauncher()

        CaptureService.shared.captureSelectedText { [weak self] text in
            DispatchQueue.main.async {
                self?.showQuickSave(with: text)
            }
        }
    }

    private func showQuickSave(with text: String) {
        quickSavePanel?.dismiss()
        quickSavePanel = QuickSavePanel(capturedText: text)
        quickSavePanel?.showCentered()
    }

    func dismissQuickSave() {
        quickSavePanel?.dismiss()
        quickSavePanel = nil
    }

    // MARK: - Prompt Editor

    @objc private func newPrompt() {
        showPromptEditor(prompt: nil, categoryId: nil)
    }

    func showPromptEditor(prompt: Prompt?, categoryId: String?) {
        let view = PromptEditorView(editingPrompt: prompt, editingCategoryId: categoryId)

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 500, height: 480),
            styleMask: [.titled, .closable, .miniaturizable],
            backing: .buffered,
            defer: false
        )
        window.title = prompt != nil ? "Edit Prompt" : "New Prompt"
        window.contentView = NSHostingView(rootView: view)
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        editorWindow = window
    }

    // MARK: - Settings

    @objc private func openSettings() {
        if let window = settingsWindow {
            window.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
            return
        }

        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 420, height: 280),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false
        )
        window.title = "FlowPrompt Settings"
        window.contentView = NSHostingView(rootView: SettingsView())
        window.center()
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)

        settingsWindow = window
    }

    // MARK: - Accessibility

    private func checkAccessibilityPermission() {
        let trusted = AXIsProcessTrustedWithOptions(
            [kAXTrustedCheckOptionPrompt.takeRetainedValue(): true] as CFDictionary
        )
        if !trusted {
            print("FlowPrompt: Accessibility permission not granted. Auto-paste and quick-save capture won't work until enabled.")
        }
    }
}
