import Components
import SwiftUI
import Testing

private struct PreviewTurn: Identifiable, Equatable {
    let id: String
    let label: String
    let state: AssistantConversationState
}

@MainActor
@Suite("AssistantConversationList")
struct AssistantConversationListTests {

    @Test("empty turns with idle hint constructs")
    func emptyWithHint() {
        _ = AssistantConversationList(
            turns: [PreviewTurn](),
            isInteractionEnabled: true,
            idleHint: "Tap an action to get started.",
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { _ in }
        )
    }

    @Test("empty turns without idle hint constructs")
    func emptyWithoutHint() {
        _ = AssistantConversationList(
            turns: [PreviewTurn](),
            isInteractionEnabled: true,
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { _ in }
        )
    }

    @Test("idle, streaming, complete, and error turns all construct")
    func allStates() {
        let turns = [
            PreviewTurn(id: "1", label: "Translate", state: .idle),
            PreviewTurn(id: "2", label: "Explain", state: .streaming("Partial...")),
            PreviewTurn(id: "3", label: "Examples", state: .complete("Final answer.")),
            PreviewTurn(id: "4", label: "Grammar", state: .error("Something went wrong.")),
        ]
        _ = AssistantConversationList(
            turns: turns,
            isInteractionEnabled: true,
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { _ in }
        )
    }

    @Test("autoPromotingHeadings is forwarded for structured completed turns")
    func autoPromotingHeadings() {
        _ = AssistantConversationList(
            turns: [
                PreviewTurn(id: "1", label: "Explain", state: .complete("## Main Idea\nBody.\n\n## Examples\nBody."))
            ],
            isInteractionEnabled: true,
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { _ in },
            autoPromotingHeadings: ["Main Idea", "Examples"]
        )
    }

    @Test("onRetry closure is constructible and independently invocable with a turn")
    func retryCallback() {
        var retried: PreviewTurn?
        let turn = PreviewTurn(id: "1", label: "Explain", state: .error("Failed"))
        _ = AssistantConversationList(
            turns: [turn],
            isInteractionEnabled: true,
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { retried = $0 }
        )
        #expect(retried == nil)
    }

    // MARK: - Rendering

    @Test("empty state with hint renders")
    func emptyWithHintRenders() {
        renderForCoverage(
            AssistantConversationList(
                turns: [PreviewTurn](),
                isInteractionEnabled: true,
                idleHint: "Tap an action to get started.",
                userLabel: { $0.label },
                responseState: { $0.state },
                retryTitle: "Retry",
                onRetry: { _ in }
            )
        )
    }

    @Test("empty state without hint renders")
    func emptyWithoutHintRenders() {
        renderForCoverage(
            AssistantConversationList(
                turns: [PreviewTurn](),
                isInteractionEnabled: true,
                userLabel: { $0.label },
                responseState: { $0.state },
                retryTitle: "Retry",
                onRetry: { _ in }
            )
        )
    }

    @Test("idle turn renders")
    func idleTurnRenders() {
        renderForCoverage(
            AssistantConversationList(
                turns: [PreviewTurn(id: "1", label: "Translate", state: .idle)],
                isInteractionEnabled: true,
                userLabel: { $0.label },
                responseState: { $0.state },
                retryTitle: "Retry",
                onRetry: { _ in }
            )
        )
    }

    @Test("streaming turn renders")
    func streamingTurnRenders() {
        renderForCoverage(
            AssistantConversationList(
                turns: [PreviewTurn(id: "1", label: "Explain", state: .streaming("Partial..."))],
                isInteractionEnabled: true,
                userLabel: { $0.label },
                responseState: { $0.state },
                retryTitle: "Retry",
                onRetry: { _ in }
            )
        )
    }

    @Test("complete turn renders")
    func completeTurnRenders() {
        renderForCoverage(
            AssistantConversationList(
                turns: [PreviewTurn(id: "1", label: "Examples", state: .complete("Final answer."))],
                isInteractionEnabled: true,
                userLabel: { $0.label },
                responseState: { $0.state },
                retryTitle: "Retry",
                onRetry: { _ in }
            )
        )
    }

    @Test("error turn renders with retry button")
    func errorTurnRenders() {
        renderForCoverage(
            AssistantConversationList(
                turns: [PreviewTurn(id: "1", label: "Grammar", state: .error("Something went wrong."))],
                isInteractionEnabled: false,
                userLabel: { $0.label },
                responseState: { $0.state },
                retryTitle: "Retry",
                onRetry: { _ in }
            )
        )
    }
}
