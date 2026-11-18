import SwiftUI
import Testing

@testable import Components

private struct SampleTurn: Identifiable, Equatable {
    let id: String
    let state: AssistantConversationState
}

@MainActor
@Suite("Control accessibility")
struct ControlAccessibilityTests {

    @Test("toolbar buttons default to no identifier or hint")
    func toolbarDefaultsAreEmpty() {
        #expect(DismissToolbarButton {}.accessibility == ControlAccessibility())
        #expect(ConfirmToolbarButton(accessibilityLabel: "Save") {}.accessibility == ControlAccessibility())
    }

    @Test("toolbar initializers accept an identifier")
    func toolbarInitializersSetIdentifier() {
        #expect(
            DismissToolbarButton(accessibilityIdentifier: "sheet.close") {}.accessibility.identifier == "sheet.close"
        )
        #expect(
            ConfirmToolbarButton(accessibilityLabel: "Save", accessibilityIdentifier: "sheet.save") {}
                .accessibility.identifier == "sheet.save"
        )
    }

    @Test("builder methods set and clear identifier and hint")
    func toolbarBuildersSetAndClear() {
        let dismiss = DismissToolbarButton {}
            .accessibilityIdentifier("sheet.close")
            .accessibilityHint("Discards changes")
        #expect(dismiss.accessibility == ControlAccessibility(identifier: "sheet.close", hint: "Discards changes"))
        #expect(dismiss.accessibilityIdentifier(nil).accessibility.identifier == nil)

        let confirm = ConfirmToolbarButton(accessibilityLabel: "Save") {}
            .accessibilityIdentifier("sheet.save")
            .accessibilityHint("Saves changes")
        #expect(confirm.accessibility == ControlAccessibility(identifier: "sheet.save", hint: "Saves changes"))
        #expect(confirm.accessibilityHint(nil).accessibility.hint == nil)
    }

    @Test("conversation list retry accessibility comes from the initializer and builders")
    func conversationRetryAccessibility() {
        let list = AssistantConversationList(
            turns: [SampleTurn](),
            isInteractionEnabled: true,
            userLabel: { $0.id },
            responseState: { $0.state },
            retryTitle: "Retry",
            retryAccessibilityIdentifier: "chat.retry",
            onRetry: { _ in }
        )
        #expect(list.retryAccessibility.identifier == "chat.retry")

        let hinted = list.retryAccessibilityIdentifier("chat.retry.other").retryAccessibilityHint("Asks again")
        #expect(hinted.retryAccessibility == ControlAccessibility(identifier: "chat.retry.other", hint: "Asks again"))
    }

    @Test("renders toolbar buttons and a retry button with accessibility applied")
    func rendersWithAccessibility() {
        renderForCoverage(
            NavigationStack {
                Text("Content")
                    .toolbar {
                        DismissToolbarButton(accessibilityIdentifier: "sheet.close") {}
                            .accessibilityHint("Discards changes")
                        ConfirmToolbarButton(accessibilityLabel: "Save") {}
                            .accessibilityIdentifier("sheet.save")
                    }
            }
        )
        renderForCoverage(
            AssistantConversationList(
                turns: [SampleTurn(id: "1", state: .error("Something went wrong."))],
                isInteractionEnabled: true,
                userLabel: { $0.id },
                responseState: { $0.state },
                retryTitle: "Retry",
                onRetry: { _ in }
            )
            .retryAccessibilityIdentifier("chat.retry")
            .retryAccessibilityHint("Asks again")
        )
    }

    @Test("modifier applies each combination of identifier and hint")
    func modifierCombinations() {
        let combinations = [
            ControlAccessibility(),
            ControlAccessibility(identifier: "control"),
            ControlAccessibility(hint: "Does something"),
            ControlAccessibility(identifier: "control", hint: "Does something"),
        ]
        for accessibility in combinations {
            renderForCoverage(
                Text("Control").modifier(ControlAccessibilityModifier(accessibility: accessibility))
            )
        }
    }
}
