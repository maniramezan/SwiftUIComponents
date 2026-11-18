import SwiftUI

/// Optional accessibility metadata a caller attaches to a control that a component renders
/// internally (a toolbar button, a retry button), where the caller cannot apply modifiers itself.
///
/// Every field is optional: a `nil` value leaves the control's default untouched, so adding this
/// to a component never changes existing behavior.
struct ControlAccessibility: Equatable, Sendable {
    /// A stable identifier for UI automation; independent of localized text.
    var identifier: String?
    /// A VoiceOver hint describing the result of activating the control.
    var hint: String?
}

/// Applies only the ``ControlAccessibility`` values that are set.
struct ControlAccessibilityModifier: ViewModifier {
    let accessibility: ControlAccessibility

    func body(content: Content) -> some View {
        content
            .modifier(OptionalAccessibilityIdentifier(identifier: accessibility.identifier))
            .modifier(OptionalAccessibilityHint(hint: accessibility.hint))
    }
}

private struct OptionalAccessibilityIdentifier: ViewModifier {
    let identifier: String?

    func body(content: Content) -> some View {
        if let identifier {
            content.accessibilityIdentifier(identifier)
        } else {
            content
        }
    }
}

private struct OptionalAccessibilityHint: ViewModifier {
    let hint: String?

    func body(content: Content) -> some View {
        if let hint {
            content.accessibilityHint(hint)
        } else {
            content
        }
    }
}
