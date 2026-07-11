import DesignSystem
import SwiftUI

/// Button style used by `ThemeButton` and native SwiftUI buttons.
///
/// ```swift
/// Button("Continue") { next() }
///     .buttonStyle(ThemeButtonStyle(role: .secondary))
/// ```
public struct ThemeButtonStyle: ButtonStyle {
    private let role: ThemeButtonRole
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.designTheme) private var theme

    /// Creates a themed button style.
    public init(role: ThemeButtonRole = .primary) {
        self.role = role
    }

    public func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(theme.typography.button)
            .foregroundStyle(foregroundColor)
            .frame(minHeight: theme.motion.minimumHitTarget)
            .padding(.horizontal, theme.spacing.twoUnits)
            .background(
                backgroundColor, in: RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                    .strokeBorder(borderColor, lineWidth: borderWidth)
            }
            .opacity(
                isEnabled ? (configuration.isPressed ? theme.motion.pressedOpacity : 1) : theme.motion.disabledOpacity
            )
            .animation(theme.motion.standardAnimation, value: configuration.isPressed)
    }
}

private extension ThemeButtonStyle {
    @MainActor var backgroundColor: Color {
        switch role {
        case .primary:
            theme.colors.primary
        case .secondary:
            Color.clear
        case .tertiary:
            Color.clear
        case .destructive:
            theme.colors.error
        }
    }

    @MainActor var foregroundColor: Color {
        switch role {
        case .primary:
            theme.colors.onPrimary
        case .secondary, .tertiary:
            theme.colors.primary
        case .destructive:
            theme.colors.onError
        }
    }

    @MainActor var borderColor: Color {
        switch role {
        case .secondary:
            theme.colors.primary
        case .primary, .tertiary, .destructive:
            Color.clear
        }
    }

    var borderWidth: CGFloat {
        role == .secondary ? theme.stroke.thin : 0
    }
}
