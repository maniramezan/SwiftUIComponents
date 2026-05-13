import DesignSystem
import SwiftUI

/// Applies a themed input field surface.
public struct DesignInputSurface: ViewModifier {
    @Environment(\.designTheme) private var theme

    /// Creates an input surface modifier.
    public init() {}

    public func body(content: Content) -> some View {
        content
            .background(
                theme.colors.containerSecondary,
                in: RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
            )
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                    .strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
            }
    }
}
