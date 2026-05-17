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
public struct ChatBubble<Content: View>: View {

    private let role: ChatMessageRole
    private let content: Content
    @Environment(\.designTheme) private var theme

    /// Creates a chat bubble around custom content.
    ///
    /// - Parameters:
    ///   - role: Conversational role; controls alignment and tint.
    ///   - content: Bubble body builder.
    public init(role: ChatMessageRole, @ViewBuilder content: () -> Content) {
        self.role = role
        self.content = content()
    }

    public var body: some View {
        HStack(spacing: 0) {
            if role == .user { Spacer(minLength: theme.spacing.sixUnits) }

            content
                .padding(theme.spacing.oneAndHalfUnits)
                .background(bubbleShape.fill(backgroundColor))
                .overlay(bubbleShape.strokeBorder(borderColor, lineWidth: theme.stroke.hairline))
                .foregroundStyle(foregroundColor)

            if role != .user { Spacer(minLength: theme.spacing.sixUnits) }
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
