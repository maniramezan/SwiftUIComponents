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
///     autoPromotingHeadings: ["Main Idea", "Examples", "Common Mistakes"]
/// )
/// ```
///
/// Structured parsing only ever applies to the `.assistant` role; `.user`
/// and `.system` content always renders through ``ChatBubbleView``.
public struct StructuredChatBubbleView: View {

    private let role: ChatMessageRole
    private let content: String
    private let isTyping: Bool
    private let autoPromotingHeadings: [String]
    private let minimumSectionCount: Int

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
    public init(
        role: ChatMessageRole,
        content: String,
        isTyping: Bool = false,
        autoPromotingHeadings: [String] = [],
        minimumSectionCount: Int = 2
    ) {
        self.role = role
        self.content = content
        self.isTyping = isTyping
        self.autoPromotingHeadings = autoPromotingHeadings
        self.minimumSectionCount = minimumSectionCount
    }

    public var body: some View {
        if role == .assistant,
            !isTyping,
            let sections = StructuredMessageParser.sections(
                from: content,
                autoPromotingHeadings: autoPromotingHeadings,
                minimumSectionCount: minimumSectionCount
            )
        {
            ChatBubble(role: .assistant) {
                StructuredChatBubbleContent(sections: sections)
            }
        } else {
            ChatBubbleView(role: role, content: content, isTyping: isTyping)
        }
    }
}

/// The titled-section body shown inside a ``StructuredChatBubbleView`` when
/// its content parses into structured sections.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update this subtree independently of the rest of
/// `StructuredChatBubbleView`.
private struct StructuredChatBubbleContent: View {
    let sections: [StructuredMessageParser.Section]
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(Array(sections.enumerated()), id: \.element.id) { index, section in
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    Text(section.title)
                        .font(theme.typography.headline)
                        .foregroundStyle(theme.colors.textPrimary)
                    Text(attributedBody(section.body))
                        .font(theme.typography.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                        .lineSpacing(theme.spacing.halfUnit)
                        .fixedSize(horizontal: false, vertical: true)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.vertical, theme.spacing.oneUnit)

                if index < sections.count - 1 {
                    Divider().padding(.vertical, theme.spacing.halfUnit)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func attributedBody(_ text: String) -> AttributedString {
        (try? AttributedString(
            markdown: text,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        )) ?? AttributedString(text)
    }
}

#Preview("Structured chat bubble") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            ChatBubbleView(role: .user, content: "Explain the present perfect tense")
            StructuredChatBubbleView(
                role: .assistant,
                content: """
                    ## Main Idea
                    Used for actions that happened at an unspecified time before now.

                    ## Examples
                    - I have visited Paris.
                    - She has finished her homework.
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
