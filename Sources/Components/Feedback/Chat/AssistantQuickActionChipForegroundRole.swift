/// Which semantic foreground color an ``AssistantQuickActionChipRow`` chip
/// should use, resolved as a pure function so the decision table is
/// unit-testable without rendering a view.
///
/// Halving the whole button's opacity (background + text together) when
/// disabled leaves the title nearly unreadable against its pill background.
/// A used (selected) chip stays fully legible — `onSelectedFill` is already
/// designed to contrast with the primary fill; a not-yet-usable chip
/// switches its text to the dedicated disabled-but-legible label color
/// instead of dimming it.
public enum AssistantQuickActionChipForegroundRole: Equatable, Sendable {
    /// Text drawn on the selected (used) chip's primary fill — `theme.colors.onPrimary`.
    case onSelectedFill
    /// Text on an available chip — `theme.colors.textPrimary`.
    case primaryText
    /// Text on a chip that cannot currently be selected — `theme.colors.disabled`.
    case disabledText

    /// Resolves the chip's foreground role from its selection/enablement.
    public static func resolve(isSelected: Bool, isEnabled: Bool) -> AssistantQuickActionChipForegroundRole {
        if isSelected { return .onSelectedFill }
        return isEnabled ? .primaryText : .disabledText
    }
}
