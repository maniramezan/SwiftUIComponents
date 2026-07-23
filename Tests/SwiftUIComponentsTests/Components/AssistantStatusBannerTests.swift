import Components
import SwiftUI
import Testing

@MainActor
@Suite("AssistantStatusBanner")
struct AssistantStatusBannerTests {

    @Test("constructs with a localized message")
    func constructs() {
        _ = AssistantStatusBanner(message: "The assistant is temporarily unavailable.")
    }

    @Test("renders")
    func renders() {
        renderForCoverage(AssistantStatusBanner(message: "The assistant is temporarily unavailable."))
    }
}
