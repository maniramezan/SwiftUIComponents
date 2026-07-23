import SwiftUI

/// Progressively reveals a target string one character at a time.
///
/// When `text` grows, revealing continues from the current prefix. When it
/// changes to a value that does not extend that prefix, revealing restarts
/// from the beginning. The content closure keeps rendering independent of the
/// effect, so it can drive plain text, markdown, or custom chat content.
public struct TypewriterReveal<Content: View>: View {
    private let text: String
    private let charactersPerSecond: Int
    private let content: (String) -> Content

    @State private var revealedText = ""

    /// Creates a progressive text reveal.
    ///
    /// - Parameters:
    ///   - text: The full target string. It may grow while a response streams.
    ///   - charactersPerSecond: Reveal speed. Values below one are treated as
    ///     one. Defaults to 60.
    ///   - content: Builds UI from the currently revealed prefix.
    public init(
        text: String,
        charactersPerSecond: Int = 60,
        @ViewBuilder content: @escaping (String) -> Content
    ) {
        self.text = text
        self.charactersPerSecond = charactersPerSecond
        self.content = content
    }

    public var body: some View {
        content(revealedText)
            .task(id: RevealTaskID(text: text, charactersPerSecond: charactersPerSecond)) {
                if !text.hasPrefix(revealedText) {
                    revealedText = ""
                }

                let delay = UInt64(1_000_000_000 / max(charactersPerSecond, 1))
                while revealedText.count < text.count, !Task.isCancelled {
                    try? await Task.sleep(nanoseconds: delay)
                    guard !Task.isCancelled else { return }
                    let nextIndex = text.index(text.startIndex, offsetBy: revealedText.count + 1)
                    revealedText = String(text[..<nextIndex])
                }
            }
    }
}

private struct RevealTaskID: Hashable {
    let text: String
    let charactersPerSecond: Int
}

#Preview("Typewriter reveal") {
    TypewriterReveal(text: "The assistant is composing a response.", charactersPerSecond: 30) { text in
        Text(text)
    }
}
