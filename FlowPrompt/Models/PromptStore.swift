import Foundation
import Combine

final class PromptStore: ObservableObject {
    static let shared = PromptStore()

    @Published var data: PromptData = PromptData()

    private let storageURL: URL

    private init() {
        let dir = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent(".flowprompt")
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        self.storageURL = dir.appendingPathComponent("prompts.json")
        load()
    }

    // MARK: - Persistence

    func load() {
        guard FileManager.default.fileExists(atPath: storageURL.path) else {
            data = Self.sampleData()
            save()
            return
        }
        do {
            let raw = try Data(contentsOf: storageURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            data = try decoder.decode(PromptData.self, from: raw)
        } catch {
            print("FlowPrompt: failed to load prompts – \(error)")
            data = PromptData()
        }
    }

    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
            let raw = try encoder.encode(data)
            try raw.write(to: storageURL, options: .atomic)
        } catch {
            print("FlowPrompt: failed to save prompts – \(error)")
        }
    }

    // MARK: - Categories

    var categories: [Category] {
        get { data.categories }
        set { data.categories = newValue; save() }
    }

    func addCategory(name: String) -> Category {
        let cat = Category(name: name)
        data.categories.append(cat)
        save()
        return cat
    }

    func deleteCategory(id: String) {
        data.categories.removeAll { $0.id == id }
        save()
    }

    func categoryIndex(for id: String) -> Int? {
        data.categories.firstIndex { $0.id == id }
    }

    // MARK: - Prompts

    var allPrompts: [Prompt] {
        data.categories.flatMap { $0.prompts }
    }

    func addPrompt(_ prompt: Prompt, toCategoryId categoryId: String) {
        guard let idx = categoryIndex(for: categoryId) else { return }
        data.categories[idx].prompts.append(prompt)
        save()
    }

    func updatePrompt(_ prompt: Prompt, inCategoryId categoryId: String) {
        guard let catIdx = categoryIndex(for: categoryId),
              let promptIdx = data.categories[catIdx].prompts.firstIndex(where: { $0.id == prompt.id })
        else { return }
        data.categories[catIdx].prompts[promptIdx] = prompt
        save()
    }

    func deletePrompt(id: String) {
        for i in data.categories.indices {
            data.categories[i].prompts.removeAll { $0.id == id }
        }
        save()
    }

    func recordUse(promptId: String) {
        for i in data.categories.indices {
            if let j = data.categories[i].prompts.firstIndex(where: { $0.id == promptId }) {
                data.categories[i].prompts[j].useCount += 1
                data.categories[i].prompts[j].lastUsedAt = Date()
                save()
                return
            }
        }
    }

    func categoryId(forPrompt promptId: String) -> String? {
        data.categories.first { cat in cat.prompts.contains { $0.id == promptId } }?.id
    }

    // MARK: - Recently Used

    var recentlyUsed: [Prompt] {
        allPrompts
            .filter { $0.lastUsedAt != nil }
            .sorted { ($0.lastUsedAt ?? .distantPast) > ($1.lastUsedAt ?? .distantPast) }
            .prefix(5)
            .map { $0 }
    }

    // MARK: - Sample Data

    private static func sampleData() -> PromptData {
        PromptData(categories: [
            Category(id: "coding", name: "Coding", prompts: [
                Prompt(title: "Code Review", content: "Review this code for correctness, performance, and readability. Suggest specific improvements with code examples.", tags: ["review", "quality"]),
                Prompt(title: "Bug Report", content: "Analyze this bug. Describe the root cause, the expected vs actual behavior, and suggest a fix with code.", tags: ["debug", "bug"]),
                Prompt(title: "Refactor", content: "Refactor this code to improve readability and maintainability. Explain the changes you made and why.", tags: ["refactor", "clean"]),
            ]),
            Category(id: "writing", name: "Writing", prompts: [
                Prompt(title: "Summarize", content: "Summarize the following text in 3-5 concise bullet points, capturing the key ideas.", tags: ["summary"]),
                Prompt(title: "Improve Writing", content: "Improve the clarity, tone, and grammar of the following text while preserving the original meaning.", tags: ["edit", "grammar"]),
            ]),
            Category(id: "analysis", name: "Analysis", prompts: [
                Prompt(title: "Pros and Cons", content: "List the pros and cons of the following approach. Be specific and consider edge cases.", tags: ["analysis", "decision"]),
            ]),
        ])
    }
}
