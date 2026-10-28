import SwiftUI

/// Progressively reveals a target string one character at a time.
///
/// When `text` grows, revealing continues from the current prefix. When it
/// changes to a value that does not extend that prefix, revealing restarts
/// from the beginning. The content closure keeps rendering independent of the
/// effect, so it can drive plain text, markdown, or custom chat content.
/// Streaming extensions retain the pending reveal deadline. Disappearing pauses
/// the schedule. Reduce Motion and VoiceOver show the full current target immediately.
public struct TypewriterReveal<Content: View>: View {
    private let text: String
    private let charactersPerSecond: Int
    private let content: (String) -> Content

    @State private var reveal = TypewriterRevealState()
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOver

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

    /// Reveals text incrementally, or immediately under Reduce Motion or VoiceOver.
    public var body: some View {
        let immediate = reduceMotion || voiceOver
        content(immediate ? text : reveal.revealedText)
            .task(id: RevealTaskID(text: text, rate: charactersPerSecond, immediate: immediate)) {
                let clock = ContinuousClock()
                reveal.update(text: text, rate: charactersPerSecond, at: clock.now)
                if immediate {
                    reveal.finish()
                    return
                }
                while let deadline = reveal.deadline, !Task.isCancelled {
                    do {
                        try await clock.sleep(until: deadline)
                    } catch {
                        return
                    }
                    guard !Task.isCancelled else { return }
                    reveal.advance(at: clock.now)
                }
            }
            .onDisappear { reveal.pause() }
    }
}

private struct RevealTaskID: Hashable {
    let text: String
    let rate: Int
    let immediate: Bool
}

nonisolated struct TypewriterRevealState {
    private(set) var revealedText = ""
    private(set) var deadline: ContinuousClock.Instant?
    private var target = ""
    private var index = "".startIndex
    private var rate = 60

    mutating func update(text: String, rate: Int, at now: ContinuousClock.Instant) {
        let resumed = TypewriterRevealPacing.resumePoint(revealed: revealedText, target: text)
        let changedDirection = !text.hasPrefix(revealedText)
        let changedRate = self.rate != rate
        target = text
        revealedText = resumed
        index = target.index(target.startIndex, offsetBy: resumed.count)
        self.rate = rate
        if index == target.endIndex {
            deadline = nil
        } else if deadline == nil || changedDirection || changedRate {
            deadline = now.advanced(by: TypewriterRevealPacing.tickInterval(charactersPerSecond: rate))
        }
    }

    mutating func advance(at now: ContinuousClock.Instant) {
        guard let deadline, now >= deadline else { return }
        let step = TypewriterRevealPacing.charactersPerTick(charactersPerSecond: rate)
        index = target.index(index, offsetBy: step, limitedBy: target.endIndex) ?? target.endIndex
        revealedText = String(target[..<index])
        self.deadline =
            index == target.endIndex
            ? nil : now.advanced(by: TypewriterRevealPacing.tickInterval(charactersPerSecond: rate))
    }

    mutating func finish() {
        revealedText = target
        index = target.endIndex
        deadline = nil
    }

    mutating func pause() {
        deadline = nil
    }
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
