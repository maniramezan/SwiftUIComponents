import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("TypewriterReveal")
struct TypewriterRevealTests {

    @Test("constructs with the default reveal rate")
    func defaultRate() {
        _ = TypewriterReveal(text: "Streaming text") { Text($0) }
    }

    @Test("renders with a custom reveal rate")
    func customRateRenders() {
        renderForCoverage(TypewriterReveal(text: "Streaming text", charactersPerSecond: 1) { Text($0) })
    }

    @Test("resumes from the revealed prefix when the target grows")
    func resumesWhenTextGrows() {
        #expect(TypewriterRevealPacing.resumePoint(revealed: "Hel", target: "Hello") == "Hel")
    }

    @Test("clamps to the target when it shrinks to a prefix of what is shown")
    func clampsWhenTextShrinks() {
        #expect(TypewriterRevealPacing.resumePoint(revealed: "Hello", target: "Hel") == "Hel")
    }

    @Test("restarts when the target diverges from what is shown")
    func restartsWhenTextDiverges() {
        #expect(TypewriterRevealPacing.resumePoint(revealed: "Hello", target: "World").isEmpty)
    }

    @Test("reveals one character per tick at or below the display cadence")
    func oneCharacterPerTickAtLowRates() {
        #expect(TypewriterRevealPacing.charactersPerTick(charactersPerSecond: 30) == 1)
        #expect(TypewriterRevealPacing.charactersPerTick(charactersPerSecond: 60) == 1)
        #expect(TypewriterRevealPacing.charactersPerTick(charactersPerSecond: 0) == 1)
        #expect(TypewriterRevealPacing.tickInterval(charactersPerSecond: 30) == .seconds(1.0 / 30.0))
    }

    @Test("batches characters instead of exceeding the display cadence")
    func batchesAtHighRates() {
        #expect(TypewriterRevealPacing.charactersPerTick(charactersPerSecond: 600) == 10)
        #expect(TypewriterRevealPacing.tickInterval(charactersPerSecond: 600) == .seconds(10.0 / 600.0))
        #expect(TypewriterRevealPacing.charactersPerTick(charactersPerSecond: .max) > 0)
    }
}

@Test("Streaming target extensions preserve the pending production reveal deadline")
func streamingRevealDoesNotStarve() throws {
    let start = ContinuousClock.now
    var state = TypewriterRevealState()
    state.update(text: "A", rate: 1, at: start)
    let deadline = try #require(state.deadline)
    for tick in 1...9 {
        state.update(
            text: String(repeating: "A", count: tick + 1), rate: 1,
            at: start.advanced(by: .milliseconds(tick * 100)))
        #expect(state.deadline == deadline)
    }
    state.advance(at: deadline)
    #expect(state.revealedText == "A")
    #expect(state.deadline == deadline.advanced(by: .seconds(1)))
}

@Test("Production reveal state handles divergence, shrinking, rate changes, pause, and immediate completion")
func revealStateUpdates() throws {
    let start = ContinuousClock.now
    var state = TypewriterRevealState()
    state.update(text: "AB", rate: 1, at: start)
    state.advance(at: start.advanced(by: .seconds(1)))
    #expect(state.revealedText == "A")
    state.update(text: "Z", rate: 2, at: start)
    #expect(state.revealedText.isEmpty)
    #expect(state.deadline == start.advanced(by: .milliseconds(500)))
    state.finish()
    #expect(state.revealedText == "Z")
    state.update(text: "", rate: 2, at: start)
    #expect(state.revealedText.isEmpty)
    #expect(state.deadline == nil)
    state.update(text: "ABC", rate: 1, at: start)
    state.pause()
    state.update(text: "ABCD", rate: 1, at: start.advanced(by: .seconds(10)))
    #expect(state.deadline == start.advanced(by: .seconds(11)))
}

@Test("Editing an unrevealed suffix retains the next deadline")
func revealSuffixEditsKeepDeadline() {
    let start = ContinuousClock.now
    var state = TypewriterRevealState()
    state.update(text: "ABC", rate: 1, at: start)
    state.advance(at: start.advanced(by: .seconds(1)))
    let deadline = state.deadline
    state.update(text: "AXY", rate: 1, at: start.advanced(by: .milliseconds(1500)))
    #expect(state.revealedText == "A")
    #expect(state.deadline == deadline)
}
