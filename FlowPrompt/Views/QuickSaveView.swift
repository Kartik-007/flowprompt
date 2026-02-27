import SwiftUI

struct QuickSaveView: View {
    let capturedText: String

    @StateObject private var store = PromptStore.shared
    @State private var title = ""
    @State private var selectedCategoryId: String?
    @State private var newCategoryName = ""
    @State private var showNewCategory = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Image(systemName: "square.and.arrow.down")
                    .foregroundColor(.accentColor)
                Text("Quick Save Prompt")
                    .font(.system(size: 14, weight: .semibold))
                Spacer()
                Text("esc to cancel")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.08))
                    .cornerRadius(4)
            }
            .padding(.horizontal, 16)
            .padding(.top, 12)
            .padding(.bottom, 8)

            Divider().opacity(0.5)

            VStack(alignment: .leading, spacing: 12) {
                // Title
                VStack(alignment: .leading, spacing: 4) {
                    Text("Title")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    TextField("Name this prompt...", text: $title)
                        .textFieldStyle(.roundedBorder)
                        .onSubmit { savePrompt() }
                }

                // Category
                VStack(alignment: .leading, spacing: 4) {
                    Text("Category")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    HStack {
                        if showNewCategory {
                            TextField("New category name...", text: $newCategoryName)
                                .textFieldStyle(.roundedBorder)
                            Button("Cancel") {
                                showNewCategory = false
                                newCategoryName = ""
                            }
                            .buttonStyle(.plain)
                            .foregroundColor(.secondary)
                        } else {
                            Picker("", selection: $selectedCategoryId) {
                                ForEach(store.categories) { cat in
                                    Text(cat.name).tag(Optional(cat.id))
                                }
                            }
                            .labelsHidden()

                            Button(action: { showNewCategory = true }) {
                                Image(systemName: "plus")
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                // Preview
                VStack(alignment: .leading, spacing: 4) {
                    Text("Captured Text")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    ScrollView {
                        Text(capturedText)
                            .font(.system(size: 11))
                            .foregroundColor(.primary.opacity(0.8))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                    }
                    .frame(maxHeight: 100)
                    .background(Color.primary.opacity(0.04))
                    .cornerRadius(6)
                }

                // Save Button
                HStack {
                    Spacer()
                    Button("Save (⏎)") { savePrompt() }
                        .keyboardShortcut(.return, modifiers: [])
                        .buttonStyle(.borderedProminent)
                        .disabled(title.isEmpty)
                }
            }
            .padding(16)
        }
        .frame(width: 480)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 5)
        .onAppear {
            selectedCategoryId = store.categories.first?.id
        }
    }

    private func savePrompt() {
        guard !title.isEmpty else { return }

        let categoryId: String
        if showNewCategory && !newCategoryName.isEmpty {
            let cat = store.addCategory(name: newCategoryName)
            categoryId = cat.id
        } else if let selected = selectedCategoryId {
            categoryId = selected
        } else {
            let cat = store.addCategory(name: "General")
            categoryId = cat.id
        }

        let prompt = Prompt(title: title, content: capturedText)
        store.addPrompt(prompt, toCategoryId: categoryId)

        AppDelegate.shared?.dismissQuickSave()
    }
}
