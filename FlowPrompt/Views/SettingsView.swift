import SwiftUI
import ServiceManagement

struct SettingsView: View {
    @AppStorage("launchAtLogin") private var launchAtLogin = false
    @AppStorage("autoPaste") private var autoPaste = true

    var body: some View {
        TabView {
            generalTab
                .tabItem { Label("General", systemImage: "gear") }

            hotkeysTab
                .tabItem { Label("Hotkeys", systemImage: "keyboard") }

            aboutTab
                .tabItem { Label("About", systemImage: "info.circle") }
        }
        .frame(width: 420, height: 280)
    }

    private var generalTab: some View {
        Form {
            Toggle("Launch at Login", isOn: $launchAtLogin)
                .onChange(of: launchAtLogin) { newValue in
                    do {
                        if newValue {
                            try SMAppService.mainApp.register()
                        } else {
                            try SMAppService.mainApp.unregister()
                        }
                    } catch {
                        print("FlowPrompt: login item error – \(error)")
                    }
                }

            Toggle("Auto-paste on selection", isOn: $autoPaste)

            LabeledContent("Storage Location") {
                Text("~/.flowprompt/prompts.json")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textSelection(.enabled)
            }

            Button("Open Storage Folder") {
                let url = FileManager.default.homeDirectoryForCurrentUser
                    .appendingPathComponent(".flowprompt")
                NSWorkspace.shared.open(url)
            }
        }
        .formStyle(.grouped)
        .padding()
    }

    private var hotkeysTab: some View {
        Form {
            LabeledContent("Open Launcher") {
                Text("⌃⌘P")
                    .font(.system(size: 14, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(6)
            }

            LabeledContent("Quick Save") {
                Text("⌃⌘S")
                    .font(.system(size: 14, design: .rounded))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(6)
            }

            Text("Custom hotkey configuration coming in a future update.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .formStyle(.grouped)
        .padding()
    }

    private var aboutTab: some View {
        VStack(spacing: 12) {
            Image(systemName: "text.bubble")
                .font(.system(size: 40))
                .foregroundColor(.accentColor)
            Text("FlowPrompt")
                .font(.title2.bold())
            Text("v1.0.0")
                .foregroundColor(.secondary)
            Text("Your global prompt launcher.")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
