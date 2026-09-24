/// The presentation state of one action in an
/// ``AssistantQuickActionChipRow``.
public enum AssistantQuickActionState: Equatable, Sendable {
    /// The action is visible and can be selected when row interaction is enabled.
    case available
    /// The action is visible, highlighted as already used, and disabled.
    case used
    /// The action remains visible but cannot currently be selected.
    case disabled
    /// The action is omitted from the row.
    case hidden
}
