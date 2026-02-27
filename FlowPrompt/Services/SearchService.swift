import Foundation

struct SearchResult: Identifiable {
    let prompt: Prompt
    let categoryName: String
    let categoryId: String
    let score: Int

    var id: String { prompt.id }
}

final class SearchService {
    static let shared = SearchService()
    private init() {}

    func search(query: String, in categories: [Category]) -> [SearchResult] {
        let q = query.lowercased().trimmingCharacters(in: .whitespaces)
        guard !q.isEmpty else { return [] }

        var results: [SearchResult] = []

        for category in categories {
            for prompt in category.prompts {
                let score = computeScore(query: q, prompt: prompt, categoryName: category.name)
                if score > 0 {
                    results.append(SearchResult(prompt: prompt, categoryName: category.name, categoryId: category.id, score: score))
                }
            }
        }

        return results.sorted { $0.score > $1.score }
    }

    private func computeScore(query: String, prompt: Prompt, categoryName: String) -> Int {
        var score = 0
        let title = prompt.title.lowercased()
        let content = prompt.content.lowercased()
        let tags = prompt.tags.map { $0.lowercased() }
        let catName = categoryName.lowercased()

        // Exact prefix match on title
        if title.hasPrefix(query) { score += 100 }
        // Title contains query
        else if title.contains(query) { score += 60 }
        // Fuzzy match on title
        else if fuzzyMatch(query: query, in: title) { score += 30 }

        // Tag exact match
        if tags.contains(query) { score += 50 }
        // Tag prefix match
        if tags.contains(where: { $0.hasPrefix(query) }) { score += 30 }

        // Category match
        if catName.contains(query) { score += 20 }

        // Content contains
        if content.contains(query) { score += 10 }

        // Boost recently/frequently used
        score += min(prompt.useCount, 10)

        return score
    }

    private func fuzzyMatch(query: String, in text: String) -> Bool {
        var queryIndex = query.startIndex
        var textIndex = text.startIndex

        while queryIndex < query.endIndex && textIndex < text.endIndex {
            if query[queryIndex] == text[textIndex] {
                queryIndex = query.index(after: queryIndex)
            }
            textIndex = text.index(after: textIndex)
        }

        return queryIndex == query.endIndex
    }
}
