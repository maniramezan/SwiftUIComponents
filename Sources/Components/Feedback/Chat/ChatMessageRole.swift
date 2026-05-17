import Foundation

/// The conversational role attached to a chat message.
///
/// Used by `ChatBubble`, `ChatBubbleView`, and `TypingIndicatorBubbleView` to
/// pick a side-of-screen alignment and a theme-driven background tint.
public enum ChatMessageRole: String, Sendable, Hashable, Codable {

    /// A message sent by the human user. Aligns to the trailing edge with a
    /// prominent background.
    case user

    /// A message produced by an AI assistant or bot. Aligns to the leading
    /// edge with a softer background and supports markdown rendering in the
    /// text-content convenience initializer.
    case assistant

    /// A system message such as a tool call result or an automated notice.
    /// Aligns to the leading edge with a neutral background.
    case system
}
