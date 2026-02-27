import SwiftUI

struct LauncherView: View {
    @StateObject private var store = PromptStore.shared
    @State private var searchText = ""
    @State private var selectedIndex = 0
    @State private var expandedCategories: Set<String> = []

    private var displayItems: [DisplayItem] {
        if !searchText.isEmpty {
            let results = SearchService.shared.search(query: searchText, in: store.categories)
            return results.map { .prompt($0.prompt, $0.categoryName, $0.categoryId) }
        }

        var items: [DisplayItem] = []
        let recent = store.recentlyUsed
        if !recent.isEmpty {
            items.append(.header("Recently Used"))
            for p in recent {
                let catName = store.categories.first { $0.prompts.contains(where: { $0.id == p.id }) }?.name ?? ""
                let catId = store.categoryId(forPrompt: p.id) ?? ""
                items.append(.prompt(p, catName, catId))
            }
            items.append(.separator)
        }

        for category in store.categories {
            items.append(.category(category))
            if expandedCategories.contains(category.id) {
                for prompt in category.prompts {
                    items.append(.prompt(prompt, category.name, category.id))
                }
            }
        }
        return items
    }

    private var selectableIndices: [Int] {
        displayItems.enumerated().compactMap { (i, item) in
            switch item {
            case .prompt: return i
            case .category: return i
            default: return nil
            }
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            SearchBarView(text: $searchText, onKeyNavigation: handleKeyNavigation)
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

            Divider().opacity(0.5)

            ScrollViewReader { proxy in
                ScrollView {
                    LazyVStack(spacing: 0) {
                        ForEach(Array(displayItems.enumerated()), id: \.offset) { index, item in
                            itemView(for: item, at: index)
                                .id(index)
                        }
                    }
                    .padding(.vertical, 4)
                }
                .onChange(of: selectedIndex) { newIdx in
                    withAnimation(.easeOut(duration: 0.1)) {
                        proxy.scrollTo(newIdx, anchor: .center)
                    }
                }
            }
            .frame(maxHeight: 280)

            Divider().opacity(0.5)

            previewPane
                .frame(height: 80)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
        }
        .frame(width: 620)
        .background(VisualEffectView(material: .hudWindow, blendingMode: .behindWindow))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.3), radius: 20, y: 5)
        .onAppear {
            searchText = ""
            selectedIndex = selectableIndices.first ?? 0
            expandedCategories = Set(store.categories.map(\.id))
        }
    }

    @ViewBuilder
    private func itemView(for item: DisplayItem, at index: Int) -> some View {
        let isSelected = index == selectedIndex
        switch item {
        case .header(let title):
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 2)

        case .separator:
            Divider().padding(.horizontal, 16).padding(.vertical, 4)

        case .category(let cat):
            HStack {
                Image(systemName: expandedCategories.contains(cat.id) ? "chevron.down" : "chevron.right")
                    .font(.caption2)
                    .foregroundColor(.secondary)
                    .frame(width: 12)
                Text(cat.name)
                    .fontWeight(.semibold)
                Spacer()
                Text("\(cat.promptCount)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 2)
                    .background(Color.primary.opacity(0.08))
                    .clipShape(Capsule())
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 6)
            .background(isSelected ? Color.accentColor.opacity(0.2) : Color.clear)
            .cornerRadius(6)
            .padding(.horizontal, 8)
            .contentShape(Rectangle())
            .onTapGesture {
                toggleCategory(cat.id)
            }

        case .prompt(let prompt, _, _):
            PromptRowView(prompt: prompt, isSelected: isSelected)
                .contentShape(Rectangle())
                .onTapGesture {
                    selectAndPaste(prompt)
                }
        }
    }

    @ViewBuilder
    private var previewPane: some View {
        if let selected = selectedPrompt {
            VStack(alignment: .leading, spacing: 4) {
                Text("Preview")
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(selected.content)
                    .font(.system(size: 12))
                    .foregroundColor(.primary.opacity(0.8))
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        } else {
            Text("Select a prompt to preview")
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }

    private var selectedPrompt: Prompt? {
        guard selectedIndex >= 0, selectedIndex < displayItems.count else { return nil }
        if case .prompt(let p, _, _) = displayItems[selectedIndex] { return p }
        return nil
    }

    // MARK: - Navigation

    private func handleKeyNavigation(_ key: KeyNavigation) {
        let selectable = selectableIndices
        guard !selectable.isEmpty else { return }

        switch key {
        case .up:
            if let currentPos = selectable.firstIndex(of: selectedIndex), currentPos > 0 {
                selectedIndex = selectable[currentPos - 1]
            } else {
                selectedIndex = selectable.first ?? 0
            }
        case .down:
            if let currentPos = selectable.firstIndex(of: selectedIndex), currentPos < selectable.count - 1 {
                selectedIndex = selectable[currentPos + 1]
            } else {
                selectedIndex = selectable.last ?? 0
            }
        case .enter:
            if let prompt = selectedPrompt {
                selectAndPaste(prompt)
            } else if case .category(let cat) = displayItems[safe: selectedIndex] {
                toggleCategory(cat.id)
            }
        case .cmdEnter:
            if let prompt = selectedPrompt {
                PasteService.shared.copyToClipboard(text: prompt.content)
                store.recordUse(promptId: prompt.id)
                AppDelegate.shared?.dismissLauncher()
            }
        case .escape:
            AppDelegate.shared?.dismissLauncher()
        case .right:
            if case .category(let cat) = displayItems[safe: selectedIndex] {
                expandedCategories.insert(cat.id)
            }
        case .left:
            if case .category(let cat) = displayItems[safe: selectedIndex] {
                expandedCategories.remove(cat.id)
            }
        case .cmdN:
            AppDelegate.shared?.dismissLauncher()
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                AppDelegate.shared?.showPromptEditor(prompt: nil, categoryId: nil)
            }
        case .cmdE:
            if let prompt = selectedPrompt {
                let catId = store.categoryId(forPrompt: prompt.id)
                AppDelegate.shared?.dismissLauncher()
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    AppDelegate.shared?.showPromptEditor(prompt: prompt, categoryId: catId)
                }
            }
        case .cmdDelete:
            if let prompt = selectedPrompt {
                store.deletePrompt(id: prompt.id)
            }
        }
    }

    private func toggleCategory(_ id: String) {
        if expandedCategories.contains(id) {
            expandedCategories.remove(id)
        } else {
            expandedCategories.insert(id)
        }
    }

    private func selectAndPaste(_ prompt: Prompt) {
        store.recordUse(promptId: prompt.id)
        AppDelegate.shared?.dismissLauncher()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            PasteService.shared.paste(text: prompt.content)
        }
    }
}

// MARK: - Helpers

enum DisplayItem {
    case header(String)
    case separator
    case category(Category)
    case prompt(Prompt, String, String) // prompt, categoryName, categoryId
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

enum KeyNavigation {
    case up, down, enter, cmdEnter, escape, right, left, cmdN, cmdE, cmdDelete
}

struct VisualEffectView: NSViewRepresentable {
    let material: NSVisualEffectView.Material
    let blendingMode: NSVisualEffectView.BlendingMode

    func makeNSView(context: Context) -> NSVisualEffectView {
        let view = NSVisualEffectView()
        view.material = material
        view.blendingMode = blendingMode
        view.state = .active
        return view
    }

    func updateNSView(_ nsView: NSVisualEffectView, context: Context) {
        nsView.material = material
        nsView.blendingMode = blendingMode
    }
}
