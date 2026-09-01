import DesignSystem
import SwiftUI

/// A text chat bubble that handles the common cases — role-tinted body,
/// optional typing indicator while empty, and markdown rendering for the
/// assistant role.
///
/// ```swift
/// ChatBubbleView(role: .assistant, content: "Hello! How can I help?")
/// ChatBubbleView(role: .user, content: "Why is the sky blue?")
/// ChatBubbleView(role: .assistant, content: "", isTyping: true)
/// ```
///
/// When `isTyping == true` and `content` is empty, the body is replaced with
/// an animated `TypingDotsView`. Otherwise, content is rendered as `Text`,
/// using `AttributedString(markdown:)` for the assistant role so that bold,
/// italics, lists, and inline code render with formatting.
///
/// For richer bodies — structured sections, inline embeds, tool-call cards —
/// use `ChatBubble` and supply your own content.
public struct ChatBubbleView: View {

    private let role: ChatMessageRole
    private let content: String
    private let isTyping: Bool

    /// Creates a text chat bubble.
    ///
    /// - Parameters:
    ///   - role: Conversational role; controls alignment and tint.
    ///   - content: The message text. Rendered as markdown when `role` is
    ///     `.assistant` and the text parses successfully.
    ///   - isTyping: When `true` and `content` is empty, an animated typing
    ///     indicator is shown instead of the text. Defaults to `false`.
    public init(role: ChatMessageRole, content: String, isTyping: Bool = false) {
        self.role = role
        self.content = content
        self.isTyping = isTyping
    }

    public var body: some View {
        ChatBubble(role: role) {
            ChatBubbleContent(role: role, content: content, isTyping: isTyping)
        }
    }
}

/// The text (or typing indicator) shown inside a ``ChatBubbleView``.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update this subtree independently of the rest of
/// `ChatBubbleView`.
private struct ChatBubbleContent: View {
    let role: ChatMessageRole
    let content: String
    let isTyping: Bool

    var body: some View {
        if isTyping, content.isEmpty {
            TypingDotsView()
        } else if role == .assistant {
            Text(AttributedString(markdownOrPlainText: content))
        } else {
            Text(content)
        }
    }
}

#Preview("Chat bubbles — text") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.oneUnit) {
            ChatBubbleView(role: .user, content: "How do I use this word?")
            ChatBubbleView(
                role: .assistant,
                content: "The word *hello* is a greeting used when meeting someone."
            )
            ChatBubbleView(role: .assistant, content: "", isTyping: true)
        }
        .padding(theme.spacing.twoUnits)
    }
}
