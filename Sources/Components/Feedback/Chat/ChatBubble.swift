import DesignSystem
import SwiftUI

/// A chat-bubble container that wraps arbitrary content in a role-aligned,
/// theme-tinted rounded surface.
///
/// `ChatBubble` is the primitive shared by `ChatBubbleView` (text content
/// convenience) and any custom bubble where the caller wants to compose
/// their own body — for example, a structured-section renderer, a rich
/// embed, an inline image, or a tool-call view.
///
/// ```swift
/// ChatBubble(role: .assistant) {
///     StructuredSectionsView(sections: parsed)
/// }
/// ```
///
/// Role determines the side-of-screen alignment:
/// - `.user` → trailing, prominent fill (`theme.colors.primary`)
/// - `.assistant` → leading, soft fill (`theme.colors.container`)
/// - `.system` → leading, neutral fill (`theme.colors.containerSecondary`)
///
/// Those edges are leading/trailing, not left/right, so a right-to-left
/// *interface* mirrors the conversation as a whole. To render right-to-left
/// *content* inside a left-to-right interface — a reply in the reader's
/// native language, say — pass `contentLayoutDirection: .rightToLeft` rather
/// than mirroring the surrounding hierarchy, which would flip which side of
/// the screen each role lands on:
///
/// ```swift
/// ChatBubble(role: .assistant, contentLayoutDirection: .rightToLeft) {
///     Text(reply)
/// }
/// ```
///
/// Accessibility groups content under the speaker label while preserving the
/// message and any custom controls as navigable children.
public struct ChatBubble<Content: View>: View {

    private let role: ChatMessageRole
    private let contentLayoutDirection: LayoutDirection?
    private let content: Content
    @Environment(\.designTheme) private var theme
    @Environment(\.layoutDirection) private var ambientLayoutDirection

    /// Creates a chat bubble around custom content.
    ///
    /// - Parameters:
    ///   - role: Conversational role; controls alignment and tint.
    ///   - contentLayoutDirection: Lays `content` out in this direction
    ///     regardless of the surrounding interface — pass `.rightToLeft` to
    ///     render a right-to-left reply inside a left-to-right app. The
    ///     bubble's own side-of-screen alignment is unaffected. Defaults to
    ///     `nil`, which inherits the ambient layout direction.
    ///   - content: Bubble body builder.
    public init(
        role: ChatMessageRole,
        contentLayoutDirection: LayoutDirection? = nil,
        @ViewBuilder content: () -> Content
    ) {
        self.role = role
        self.contentLayoutDirection = contentLayoutDirection
        self.content = content()
    }

    public var body: some View {
        // Role alignment is expressed in leading/trailing terms and follows
        // the ambient layout direction, so a right-to-left *interface*
        // mirrors the whole conversation the way the system messaging apps
        // do. Content direction is resolved separately, per bubble: a caller
        // rendering a right-to-left reply inside a left-to-right app
        // overrides it here instead of mirroring the row, which would
        // otherwise flip which side of the screen each role lands on (e.g.
        // an assistant bubble landing on top of the user's).
        HStack(spacing: 0) {
            if ChatBubbleLayout.hugsTrailingEdge(for: role) { Spacer(minLength: theme.spacing.sixUnits) }

            content
                .environment(\.layoutDirection, resolvedContentDirection)
                .padding(theme.spacing.oneAndHalfUnits)
                .background(bubbleShape.fill(backgroundColor))
                .overlay(bubbleShape.strokeBorder(borderColor, lineWidth: theme.stroke.hairline))
                .foregroundStyle(foregroundColor)

            if !ChatBubbleLayout.hugsTrailingEdge(for: role) { Spacer(minLength: theme.spacing.sixUnits) }
        }
        .accessibilityElement(children: .contain)
        .accessibilityLabel(Text(accessibilityRolePrefix))
    }

    private var resolvedContentDirection: LayoutDirection {
        ChatBubbleLayout.contentDirection(override: contentLayoutDirection, ambient: ambientLayoutDirection)
    }
}

// MARK: - Accessibility

extension ChatBubble {

    @MainActor fileprivate var accessibilityRolePrefix: String {
        switch role {
        case .user: "You"
        case .assistant: "Assistant"
        case .system: "System"
        }
    }
}

// MARK: - Theming

extension ChatBubble {

    @MainActor fileprivate var bubbleShape: RoundedRectangle {
        RoundedRectangle(cornerRadius: theme.radius.twoUnits, style: .continuous)
    }

    @MainActor fileprivate var backgroundColor: Color {
        switch role {
        case .user: theme.colors.primary
        case .assistant: theme.colors.container
        case .system: theme.colors.containerSecondary
        }
    }

    @MainActor fileprivate var foregroundColor: Color {
        switch role {
        case .user: theme.colors.onPrimary
        case .assistant, .system: theme.colors.textPrimary
        }
    }

    @MainActor fileprivate var borderColor: Color {
        switch role {
        case .user: .clear
        case .assistant, .system: theme.colors.border
        }
    }
}

#Preview("Chat Bubbles — custom content") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.oneUnit) {
            ChatBubble(role: .assistant) {
                VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
                    Text("Custom content").font(theme.typography.headline)
                    Text("With anything inside.").font(theme.typography.subheadline)
                }
            }
            ChatBubble(role: .user) {
                Text("Got it.")
            }
        }
        .padding(theme.spacing.twoUnits)
    }
}
