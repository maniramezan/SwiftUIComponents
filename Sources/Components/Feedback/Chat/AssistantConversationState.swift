import Foundation

/// The response lifecycle of one turn in an assistant conversation, shown by
/// ``AssistantConversationList``.
///
/// ```swift
/// var state: AssistantConversationState = .idle
/// state = .streaming("The word means...")   // tokens arriving
/// state = .complete("The word means \"hello\".")  // final text
/// state = .error("Something went wrong.")
/// ```
public enum AssistantConversationState: Equatable, Sendable {

    /// No request has been made for this turn yet.
    case idle

    /// A response is streaming in; associated text is the cumulative
    /// content received so far (may be empty while waiting for the first
    /// token, which renders a typing indicator).
    case streaming(String)

    /// The response finished successfully with this final text.
    case complete(String)

    /// The request failed; associated text is a user-facing error message.
    case error(String)
}
