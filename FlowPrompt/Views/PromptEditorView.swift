import SwiftUI

struct PromptEditorView: View {
    @StateObject private var store = PromptStore.shared
    @Environment(\.dismiss) private var dismiss

    let editingPrompt: Prompt?
    let editingCategoryId: String?

    @State private var title: String = ""
    @State private var content: String = ""
    @State private var tagsText: String = ""
    @State private var selectedCategoryId: String?
    @State private var newCategoryName: String = ""
    @State private var showNewCategory = false

    var isEditing: Bool { editingPrompt != nil }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(isEditing ? "Edit Prompt" : "New Prompt")
                    .font(.headline)
                Spacer()
                Button("Cancel") { dismiss() }
                    .buttonStyle(.plain)
                    .foregroundColor(.secondary)
            }
            .padding()

            Divider()

            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    TextField("Tags (comma-separated)", text: $tagsText)

                    if showNewCategory {
                        HStack {
                            TextField("New category...", text: $newCategoryName)
                            Button("Cancel") {
                                showNewCategory = false
                                newCategoryName = ""
                            }
                        }
                    } else {
                        HStack {
                            Picker("Category", selection: $selectedCategoryId) {
                                ForEach(store.categories) { cat in
                                    Text(cat.name).tag(Optional(cat.id))
                                }
                            }
                            Button(action: { showNewCategory = true }) {
                                Image(systemName: "plus")
                            }
                        }
                    }
                }

                Section("Prompt Content") {
                    TextEditor(text: $content)
                        .font(.system(size: 13, design: .monospaced))
                        .frame(minHeight: 150)
                }
            }
            .formStyle(.grouped)

            Divider()

            HStack {
                if isEditing {
                    Button("Delete", role: .destructive) {
                        if let p = editingPrompt {
                            store.deletePrompt(id: p.id)
                        }
                        dismiss()
                    }
                }
                Spacer()
                Button(isEditing ? "Update" : "Create") { savePrompt() }
                    .buttonStyle(.borderedProminent)
                    .disabled(title.isEmpty || content.isEmpty)
                    .keyboardShortcut(.return, modifiers: .command)
            }
            .padding()
        }
        .frame(width: 500, height: 480)
        .onAppear {
            if let p = editingPrompt {
                title = p.title
                content = p.content
                tagsText = p.tags.joined(separator: ", ")
                selectedCategoryId = editingCategoryId
            } else {
                selectedCategoryId = store.categories.first?.id
            }
        }
    }

    private func savePrompt() {
        let tags = tagsText.split(separator: ",").map { $0.trimmingCharacters(in: .whitespaces) }.filter { !$0.isEmpty }

        let categoryId: String
        if showNewCategory && !newCategoryName.isEmpty {
            let cat = store.addCategory(name: newCategoryName)
            categoryId = cat.id
        } else if let selected = selectedCategoryId {
            categoryId = selected
        } else {
            return
        }

        if var existing = editingPrompt {
            existing.title = title
            existing.content = content
            existing.tags = tags
            if categoryId != editingCategoryId {
                if let oldCat = editingCategoryId {
                    store.deletePrompt(id: existing.id)
                }
                store.addPrompt(existing, toCategoryId: categoryId)
            } else {
                store.updatePrompt(existing, inCategoryId: categoryId)
            }
        } else {
            let prompt = Prompt(title: title, content: content, tags: tags)
            store.addPrompt(prompt, toCategoryId: categoryId)
        }

        dismiss()
    }
}
