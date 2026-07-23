import Components
import SwiftUI
import Testing

@MainActor
@Suite("AssistantDisclaimerFooter")
struct AssistantDisclaimerFooterTests {

    @Test("constructs with text")
    func constructs() {
        _ = AssistantDisclaimerFooter(text: "AI responses can be inaccurate.")
    }

    @Test("renders")
    func renders() {
        renderForCoverage(AssistantDisclaimerFooter(text: "AI responses can be inaccurate."))
    }
}
