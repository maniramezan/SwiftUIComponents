import Components
import SwiftUI
import Testing

@MainActor
@Suite("AssistantLimitPromptCard")
struct AssistantLimitPromptCardTests {

    @Test("constructs with primary and secondary actions")
    func constructs() {
        _ = AssistantLimitPromptCard(
            message: "You've reached today's assistant limit.",
            supportingText: "Upgrade for unlimited help.",
            primaryActionTitle: "Upgrade",
            secondaryActionTitle: "Not now",
            onPrimaryAction: {},
            onSecondaryAction: {}
        )
    }

    @Test("renders")
    func renders() {
        renderForCoverage(
            AssistantLimitPromptCard(
                message: "You've reached today's assistant limit.",
                supportingText: "Upgrade for unlimited help.",
                primaryActionTitle: "Upgrade",
                secondaryActionTitle: "Not now",
                onPrimaryAction: {},
                onSecondaryAction: {}
            )
        )
    }
}
