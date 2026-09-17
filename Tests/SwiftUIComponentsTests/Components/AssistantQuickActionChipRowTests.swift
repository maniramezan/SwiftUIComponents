import Components
import SwiftUI
import Testing

private enum PreviewAction: String, CaseIterable, Identifiable {
    case summarize, expand, rephrase, share
    var id: String { rawValue }
}

@MainActor
@Suite("AssistantQuickActionChipRow")
struct AssistantQuickActionChipRowTests {

    @Test("action states support use, disable, hide, and renewal")
    func actionStates() {
        var states: [PreviewAction: AssistantQuickActionState] = [
            .summarize: .available,
            .expand: .disabled,
            .rephrase: .hidden,
        ]

        states[.summarize] = .used
        #expect(states[.summarize] == .used)
        #expect(states[.expand] == .disabled)
        #expect(states[.rephrase] == .hidden)

        states[.summarize] = .available
        #expect(states[.summarize] == .available)
    }

    @Test("row accepts a dynamic action collection and state resolver")
    func dynamicActions() {
        _ = AssistantQuickActionChipRow<PreviewAction>(
            actions: [.summarize, .expand, .rephrase, .share],
            isInteractionEnabled: true,
            state: {
                switch $0 {
                case .summarize: .used
                case .expand: .available
                case .rephrase: .disabled
                case .share: .hidden
                }
            },
            label: { $0.rawValue.capitalized },
            systemImage: { _ in "sparkles" },
            onSelect: { _ in }
        )
    }

    @Test("row renders every visible action state")
    func visibleStatesRender() {
        renderForCoverage(
            AssistantQuickActionChipRow<PreviewAction>(
                actions: PreviewAction.allCases,
                isInteractionEnabled: true,
                state: {
                    switch $0 {
                    case .summarize: .used
                    case .expand: .available
                    case .rephrase: .disabled
                    case .share: .hidden
                    }
                },
                label: { $0.rawValue.capitalized },
                onSelect: { _ in }
            )
        )
    }

    @Test("row renders with global interaction disabled")
    func globallyDisabledRenders() {
        renderForCoverage(
            AssistantQuickActionChipRow<PreviewAction>(
                actions: [.summarize],
                isInteractionEnabled: false,
                label: { $0.rawValue.capitalized },
                onSelect: { _ in }
            )
        )
    }
}

@MainActor
@Suite("AssistantQuickActionChipForegroundRole")
struct AssistantQuickActionChipForegroundRoleTests {

    @Test("selected always resolves to onSelectedFill regardless of enablement")
    func selectedResolvesToOnSelectedFill() {
        #expect(AssistantQuickActionChipForegroundRole.resolve(isSelected: true, isEnabled: true) == .onSelectedFill)
        #expect(AssistantQuickActionChipForegroundRole.resolve(isSelected: true, isEnabled: false) == .onSelectedFill)
    }

    @Test("not selected and enabled resolves to primaryText")
    func enabledResolvesToPrimaryText() {
        #expect(AssistantQuickActionChipForegroundRole.resolve(isSelected: false, isEnabled: true) == .primaryText)
    }

    @Test("not selected and disabled resolves to disabledText")
    func disabledResolvesToDisabledText() {
        #expect(AssistantQuickActionChipForegroundRole.resolve(isSelected: false, isEnabled: false) == .disabledText)
    }
}
