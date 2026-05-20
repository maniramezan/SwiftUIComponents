import DesignSystem
import SwiftUI

/// Applies a themed input field surface.
public struct InputSurface: ViewModifier {
    @Environment(\.designTheme) private var theme

    /// Creates an input surface modifier.
    public init() {}

    /// Applies the input surface styling to the wrapped content.
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

#Preview("Design Input Surface") {
    PreviewContent { theme in
        Text("Input surface")
            .padding(theme.spacing.twoUnits)
            .designInputSurface()
            .padding(theme.spacing.twoUnits)
    }
}
