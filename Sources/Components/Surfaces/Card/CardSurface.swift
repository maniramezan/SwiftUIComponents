import DesignSystem
import SwiftUI

/// Applies a themed card surface.
public struct CardSurface: ViewModifier {
    private let showStroke: Bool
    @Environment(\.designTheme) private var theme

    /// Creates a card surface modifier.
    public init(showStroke: Bool = true) {
        self.showStroke = showStroke
    }

    /// Applies the card surface styling to the wrapped content.
    public func body(content: Content) -> some View {
        content
            .background(
                theme.colors.container,
                in: RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
            )
            .overlay {
                if showStroke {
                    RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                        .strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
                }
            }
    }
}

#Preview("Design Card Surface") {
    PreviewContent { theme in
        Text("Card surface")
            .padding(theme.spacing.twoUnits)
            .designCardSurface()
            .padding(theme.spacing.twoUnits)
    }
}
