import DesignSystem
import SwiftUI

/// A standalone chat bubble showing only an animated typing indicator,
/// pre-aligned for the assistant role.
///
/// Use as a placeholder row before the first token of an assistant response
/// arrives — once the response begins, swap in a real `ChatBubbleView` (or
/// `ChatBubble` with custom content). Equivalent to:
///
/// ```swift
/// ChatBubble(role: .assistant) { TypingDotsView() }
/// ```
///
/// but ships as its own type so list/`ForEach` switching reads more clearly.
public struct TypingIndicatorBubbleView: View {

    /// Creates an assistant-aligned typing placeholder.
    public init() {}

    public var body: some View {
        ChatBubble(role: .assistant) {
            TypingDotsView()
        }
    }
}

#Preview("Typing indicator bubble") {
    PreviewContent { theme in
        TypingIndicatorBubbleView().padding(theme.spacing.twoUnits)
    }
}
