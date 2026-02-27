import Foundation

struct Category: Codable, Identifiable, Equatable {
    var id: String
    var name: String
    var prompts: [Prompt]

    init(id: String = UUID().uuidString, name: String, prompts: [Prompt] = []) {
        self.id = id
        self.name = name
        self.prompts = prompts
    }

    var promptCount: Int { prompts.count }
}

struct PromptData: Codable {
    var version: Int = 1
    var categories: [Category]

    init(categories: [Category] = []) {
        self.categories = categories
    }
}
