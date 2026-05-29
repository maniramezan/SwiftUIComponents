import Foundation
import Testing

@testable import Components

/// Regression coverage for the localized strings introduced by the
/// accessibility pass (error banner label, typing indicator, button loading
/// value). These resolve to concrete values, so we can assert them directly
/// without view introspection.
@MainActor
@Suite("Accessibility strings")
struct AccessibilityStringsTests {

    @Test("error banner accessibility label prefixes the message with \"Error:\"")
    func errorBannerLabel() {
        let resolved = String(localized: Strings.ErrorView.accessibilityLabel("Network unavailable"))
        #expect(resolved == "Error: Network unavailable")
    }

    @Test("typing indicator label resolves to \"Typing\"")
    func typingIndicatorLabel() {
        let resolved = String(localized: Strings.Chat.typingIndicator)
        #expect(resolved == "Typing")
    }

    @Test("button loading value resolves to \"Loading\"")
    func buttonLoadingValue() {
        let resolved = String(localized: Strings.Button.loading)
        #expect(resolved == "Loading")
    }
}
