import Components
import SwiftUI
import Testing

private enum PreviewAction: String, CaseIterable, Identifiable {
    case translate, explain, examples, grammar
    var id: String { rawValue }
}

@MainActor
@Suite("AssistantQuickActionChipRow")
struct AssistantQuickActionChipRowTests {

    @Test("action states support use, disable, hide, and renewal")
    func actionStates() {
        var states: [PreviewAction: AssistantQuickActionState] = [
            .translate: .available,
            .explain: .disabled,
            .examples: .hidden,
        ]

        states[.translate] = .used
        #expect(states[.translate] == .used)
        #expect(states[.explain] == .disabled)
        #expect(states[.examples] == .hidden)

        states[.translate] = .available
        #expect(states[.translate] == .available)
    }

    @Test("row accepts a dynamic action collection and state resolver")
    func dynamicActions() {
        _ = AssistantQuickActionChipRow<PreviewAction>(
            actions: [.translate, .explain, .examples, .grammar],
            isInteractionEnabled: true,
            state: {
                switch $0 {
                case .translate: .used
                case .explain: .available
                case .examples: .disabled
                case .grammar: .hidden
                }
            },
            label: { $0.rawValue.capitalized },
            systemImage: { _ in "text.book.closed" },
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
                    case .translate: .used
                    case .explain: .available
                    case .examples: .disabled
                    case .grammar: .hidden
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
                actions: [.translate],
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
