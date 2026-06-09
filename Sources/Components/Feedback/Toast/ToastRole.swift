/// Semantic role for a ``ToastView``, controlling its accent color and icon.
///
/// The role conveys the nature of the message both visually (a tinted icon)
/// and to assistive technology (a spoken prefix such as "Success"), since the
/// color tint alone is not perceivable by VoiceOver users.
public enum ToastRole: Sendable {
    /// Neutral, informational message. Tinted with `theme.colors.primary`.
    case info
    /// Confirms an action completed successfully. Tinted with `theme.colors.success`.
    case success
    /// Cautionary message that does not block the user. Tinted with `theme.colors.warning`.
    case warning
    /// Reports a failure or problem. Tinted with `theme.colors.error`.
    case error
}
