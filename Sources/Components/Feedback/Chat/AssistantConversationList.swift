import DesignSystem
import SwiftUI

/// A chat-style conversation log for assistant-style features: one
/// user-aligned bubble per turn (typically a tapped quick action's label),
/// followed by the assistant's reply — a typing indicator while streaming,
/// structured or plain text once complete, or an error bubble with its own
/// retry affordance.
///
/// Generic over any `Identifiable & Equatable` turn type so callers can
/// share one conversation-log implementation across multiple assistant
/// features (e.g. a word-help assistant and a grammar-help assistant), each
/// supplying its own turn model, user-facing label, and response state via
/// closures.
///
/// ```swift
/// AssistantConversationList(
///     turns: viewModel.turns,
///     isInteractionEnabled: !viewModel.isBusy,
///     idleHint: "Tap an action below to get started.",
///     userLabel: { $0.actionLabel },
///     responseState: { $0.state },
///     retryTitle: "Retry",
///     onRetry: { viewModel.retry(turnId: $0.id) }
/// )
/// ```
public struct AssistantConversationList<Turn: Identifiable & Equatable>: View {
    private let turns: [Turn]
    private let isInteractionEnabled: Bool
    private let idleHint: String?
    private let userLabel: (Turn) -> String
    private let responseState: (Turn) -> AssistantConversationState
    private let retryTitle: String
    private let onRetry: (Turn) -> Void
    private let autoPromotingHeadings: [String]

    /// Creates an assistant conversation list.
    ///
    /// - Parameters:
    ///   - turns: The conversation's turns, in display order.
    ///   - isInteractionEnabled: Gates the retry button on error turns —
    ///     `false` while another request is in flight or the provider is
    ///     unavailable.
    ///   - idleHint: Text shown in place of the list when `turns` is empty.
    ///     Pass `nil` to show nothing.
    ///   - userLabel: Resolves the user-aligned bubble's text for a turn
    ///     (e.g. the tapped quick action's display name).
    ///   - responseState: Resolves a turn's current response lifecycle.
    ///   - retryTitle: Button title shown on error turns.
    ///   - onRetry: Called when the caller taps retry on an error turn.
    ///   - autoPromotingHeadings: Literal phrases promoted into `## `
    ///     headings so completed responses can render as structured
    ///     sections. See ``StructuredMessageParser``. Defaults to empty,
    ///     which renders completed responses as plain markdown text.
    public init(
        turns: [Turn],
        isInteractionEnabled: Bool,
        idleHint: String? = nil,
        userLabel: @escaping (Turn) -> String,
        responseState: @escaping (Turn) -> AssistantConversationState,
        retryTitle: String,
        onRetry: @escaping (Turn) -> Void,
        autoPromotingHeadings: [String] = []
    ) {
        self.turns = turns
        self.isInteractionEnabled = isInteractionEnabled
        self.idleHint = idleHint
        self.userLabel = userLabel
        self.responseState = responseState
        self.retryTitle = retryTitle
        self.onRetry = onRetry
        self.autoPromotingHeadings = autoPromotingHeadings
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        if turns.isEmpty {
            if let idleHint {
                Text(idleHint)
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical, theme.spacing.threeUnits)
            }
        } else {
            VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
                ForEach(turns) { turn in
                    AssistantConversationTurnView(
                        userLabel: userLabel(turn),
                        state: responseState(turn),
                        isRetryEnabled: isInteractionEnabled,
                        retryTitle: retryTitle,
                        autoPromotingHeadings: autoPromotingHeadings,
                        onRetry: { onRetry(turn) }
                    )
                    .id(turn.id)
                }
            }
        }
    }
}

/// One turn's user bubble + assistant reply, shown inside an
/// ``AssistantConversationList``.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update each turn independently as the list grows.
private struct AssistantConversationTurnView: View {
    let userLabel: String
    let state: AssistantConversationState
    let isRetryEnabled: Bool
    let retryTitle: String
    let autoPromotingHeadings: [String]
    let onRetry: () -> Void

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            ChatBubbleView(role: .user, content: userLabel)
            switch state {
            case .idle:
                EmptyView()
            case .streaming(let text):
                ChatBubbleView(role: .assistant, content: text, isTyping: true)
            case .complete(let text):
                StructuredChatBubbleView(
                    role: .assistant,
                    content: text,
                    autoPromotingHeadings: autoPromotingHeadings
                )
            case .error(let message):
                AssistantConversationErrorTurnBubble(
                    message: message,
                    isRetryEnabled: isRetryEnabled,
                    retryTitle: retryTitle,
                    onRetry: onRetry
                )
            }
        }
    }
}

/// The error bubble + retry button shown when a turn's response failed.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the turn's user bubble.
private struct AssistantConversationErrorTurnBubble: View {
    let message: String
    let isRetryEnabled: Bool
    let retryTitle: String
    let onRetry: () -> Void

    @Environment(\.designTheme) private var theme

    var body: some View {
        ChatBubble(role: .assistant) {
            VStack(alignment: .leading, spacing: theme.spacing.oneAndHalfUnits) {
                Text(message)
                    .font(theme.typography.subheadline)
                Button(retryTitle, action: onRetry)
                    .font(theme.typography.subheadline.weight(.medium))
                    .buttonStyle(.bordered)
                    .controlSize(.small)
                    .disabled(!isRetryEnabled)
            }
        }
    }
}

private struct PreviewTurn: Identifiable, Equatable {
    let id = UUID()
    let label: String
    let state: AssistantConversationState
}

#Preview("Assistant conversation list") {
    PreviewContent { theme in
        AssistantConversationList(
            turns: [
                PreviewTurn(label: "Translate", state: .complete("Hola")),
                PreviewTurn(label: "Explain", state: .streaming("This word means...")),
            ],
            isInteractionEnabled: true,
            idleHint: "Tap an action below to get started.",
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { _ in }
        )
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Assistant conversation list — empty") {
    PreviewContent { theme in
        AssistantConversationList(
            turns: [PreviewTurn](),
            isInteractionEnabled: true,
            idleHint: "Tap an action below to get started.",
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { _ in }
        )
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Assistant conversation list — error") {
    PreviewContent { theme in
        AssistantConversationList(
            turns: [PreviewTurn(label: "Explain", state: .error("Something went wrong."))],
            isInteractionEnabled: true,
            userLabel: { $0.label },
            responseState: { $0.state },
            retryTitle: "Retry",
            onRetry: { _ in }
        )
        .padding(theme.spacing.twoUnits)
    }
}
