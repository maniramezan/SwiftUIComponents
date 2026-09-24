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
    }
}
