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
                revealedText = TypewriterRevealPacing.resumePoint(revealed: revealedText, target: text)

                let step = TypewriterRevealPacing.charactersPerTick(charactersPerSecond: charactersPerSecond)
                let delay = TypewriterRevealPacing.tickInterval(charactersPerSecond: charactersPerSecond)
                // Walk a `String.Index` forward instead of re-deriving it from a character count
                // each tick, which kept a long streamed reply quadratic in its length.
                var index = text.index(text.startIndex, offsetBy: revealedText.count)
                while index < text.endIndex, !Task.isCancelled {
                    try? await Task.sleep(for: delay)
                    guard !Task.isCancelled else { return }
                    index = text.index(index, offsetBy: step, limitedBy: text.endIndex) ?? text.endIndex
                    revealedText = String(text[..<index])
                }
            }
    }
}

private struct RevealTaskID: Hashable {
    let text: String
    let charactersPerSecond: Int
}

/// Pure pacing rules for ``TypewriterReveal``, kept separate so they can be
/// unit-tested without driving the async reveal loop.
enum TypewriterRevealPacing {

    /// The highest number of state updates per second the reveal performs. Faster
    /// rates reveal several characters per update instead of updating more often
    /// than the display can show.
    static let maximumTicksPerSecond = 60

    /// The already-revealed prefix to continue from when the target text changes.
    ///
    /// - Parameters:
    ///   - revealed: The text revealed so far.
    ///   - target: The new full text.
    /// - Returns: `revealed` when the target extends it, the target itself when the
    ///   target is a shorter prefix of what is already shown (never re-hides text the
    ///   reader has seen), and an empty string when the two diverge.
    nonisolated static func resumePoint(revealed: String, target: String) -> String {
        if target.hasPrefix(revealed) { return revealed }
        if revealed.hasPrefix(target) { return target }
        return ""
    }

    /// Characters revealed on each update for the requested rate, at least one.
    nonisolated static func charactersPerTick(charactersPerSecond: Int) -> Int {
        let rate = max(charactersPerSecond, 1)
        // Ceiling division without adding to `rate`, which could overflow for Int.max.
        return 1 + (rate - 1) / maximumTicksPerSecond
    }

    /// Time between updates, chosen so `charactersPerTick` characters per update
    /// averages out to the requested rate.
    nonisolated static func tickInterval(charactersPerSecond: Int) -> Duration {
        let rate = max(charactersPerSecond, 1)
        return .seconds(Double(charactersPerTick(charactersPerSecond: rate)) / Double(rate))
    }
}

#Preview("Typewriter reveal") {
    TypewriterReveal(text: "The assistant is composing a response.", charactersPerSecond: 30) { text in
        Text(text)
    }
}
