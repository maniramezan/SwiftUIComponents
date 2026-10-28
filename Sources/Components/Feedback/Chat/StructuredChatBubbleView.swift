import DesignSystem
import SwiftUI

/// A chat bubble that renders assistant text as titled sections when it
/// parses into two or more `## ` headings, falling back to a plain
/// ``ChatBubbleView`` otherwise.
///
/// Useful for LLM responses that are sometimes structured (multiple labeled
/// sections) and sometimes a single free-form paragraph — the caller doesn't
/// need to branch on the shape of the response themselves.
///
/// ```swift
/// StructuredChatBubbleView(
///     role: .assistant,
///     content: llmResponse,
///     autoPromotingHeadings: ["Summary", "Details", "Caveats"]
/// )
/// ```
///
/// Structured parsing only ever applies to the `.assistant` role; `.user`
/// and `.system` content always renders as plain text.
/// A retained presentation model prepares Markdown on appearance and input changes.
/// Unchanged inputs reuse the prepared result; the current source text appears until preparation finishes.
public struct StructuredChatBubbleView: View {

    private let role: ChatMessageRole
    private let content: String
    private let isTyping: Bool
    private let request: StructuredChatRequest
    private let contentLayoutDirection: LayoutDirection?
    @State private var presentation = StructuredChatPresentation()

    /// Creates a structured-or-plain chat bubble.
    ///
    /// - Parameters:
    ///   - role: Conversational role; controls alignment, tint, and whether
    ///     structured parsing is attempted (`.assistant` only).
    ///   - content: The message text, evaluated by
    ///     ``StructuredMessageParser`` before falling back to plain markdown.
    ///   - isTyping: When `true` and `content` is empty, an animated typing
    ///     indicator is shown instead. Defaults to `false`.
    ///   - autoPromotingHeadings: Literal phrases to promote into `## `
    ///     headings when the model emits them as bare leading labels. See
    ///     ``StructuredMessageParser``. Defaults to empty.
    ///   - minimumSectionCount: The smallest number of parsed sections that
    ///     justifies structured rendering. Defaults to `2`.
    ///   - contentLayoutDirection: Lays the sections (or the plain fallback
    ///     text) out in this direction regardless of the surrounding
    ///     interface — pass `.rightToLeft` for a right-to-left reply inside a
    ///     left-to-right app. The bubble's side-of-screen alignment is
    ///     unaffected. See ``ChatBubble``. Defaults to `nil`, which inherits
    ///     the ambient layout direction.
    public init(
        role: ChatMessageRole,
        content: String,
        isTyping: Bool = false,
        autoPromotingHeadings: [String] = [],
        minimumSectionCount: Int = 2,
        contentLayoutDirection: LayoutDirection? = nil
    ) {
        self.role = role
        self.content = content
        self.isTyping = isTyping
        self.request = StructuredChatRequest(
            role: role, content: content, isTyping: isTyping,
            autoPromotingHeadings: autoPromotingHeadings, minimumSectionCount: minimumSectionCount
        )
        self.contentLayoutDirection = contentLayoutDirection
    }

    /// Renders cached Markdown, preparing it only when the message or parsing policy changes.
    public var body: some View {
        ChatBubble(role: role, contentLayoutDirection: contentLayoutDirection) {
            if isTyping && content.isEmpty {
                TypingDotsView()
            } else if presentation.request == request, let sections = presentation.sections {
                StructuredChatBubbleContent(sections: sections)
            } else if presentation.request == request, let text = presentation.text {
                Text(text)
            } else {
                Text(content)
            }
        }
        .task(id: request) { presentation.update(request) }
    }
}

/// The titled-section body shown inside a ``StructuredChatBubbleView`` when
/// its content parses into structured sections.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update this subtree independently of the rest of
/// `StructuredChatBubbleView`.
private struct StructuredChatBubbleContent: View {
    let sections: [StructuredChatSection]
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(sections) { section in
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    Text(section.title)
                        .font(theme.typography.headline)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(section.body)
                        .font(theme.typography.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineSpacing(theme.spacing.halfUnit)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, theme.spacing.oneUnit)

                if section.id != sections.last?.id {
                    Divider().padding(.vertical, theme.spacing.halfUnit)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

}

#Preview("Structured chat bubble") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            ChatBubbleView(role: .user, content: "Summarize this section")
            StructuredChatBubbleView(
                role: .assistant,
                content: """
                    ## Summary
                    A short overview of the item you asked about.

                    ## Details
                    - The first supporting point.
                    - The second supporting point.
                    """
            )
            StructuredChatBubbleView(
                role: .assistant,
                content: "A single unstructured reply falls back to plain markdown."
            )
        }
        .padding(theme.spacing.twoUnits)
    }
}
