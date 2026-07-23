import Components
import SwiftUI
import Testing

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
}
