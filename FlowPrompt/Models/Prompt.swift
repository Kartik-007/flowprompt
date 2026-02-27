import Foundation

struct Prompt: Codable, Identifiable, Equatable {
    var id: String
    var title: String
    var content: String
    var tags: [String]
    var createdAt: Date
    var lastUsedAt: Date?
    var useCount: Int
    var isFavorite: Bool

    init(
        id: String = UUID().uuidString,
        title: String,
        content: String,
        tags: [String] = [],
        createdAt: Date = Date(),
        lastUsedAt: Date? = nil,
        useCount: Int = 0,
        isFavorite: Bool = false
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.tags = tags
        self.createdAt = createdAt
        self.lastUsedAt = lastUsedAt
        self.useCount = useCount
        self.isFavorite = isFavorite
    }
}
