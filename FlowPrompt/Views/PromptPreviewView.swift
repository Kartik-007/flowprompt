import SwiftUI

struct PromptPreviewView: View {
    let prompt: Prompt

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(prompt.title)
                    .font(.headline)
                Spacer()
                if prompt.useCount > 0 {
                    Text("Used \(prompt.useCount)×")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Text(prompt.content)
                .font(.body)
                .foregroundColor(.primary.opacity(0.85))
                .fixedSize(horizontal: false, vertical: true)

            if !prompt.tags.isEmpty {
                HStack(spacing: 4) {
                    ForEach(prompt.tags, id: \.self) { tag in
                        Text(tag)
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15))
                            .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
    }
}
