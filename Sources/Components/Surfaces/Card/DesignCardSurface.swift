import DesignSystem
import SwiftUI

/// Applies a themed card surface.
public struct DesignCardSurface: ViewModifier {
    private let showStroke: Bool
    @Environment(\.designTheme) private var theme

    /// Creates a card surface modifier.
    public init(showStroke: Bool = true) {
        self.showStroke = showStroke
    }

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
    Text("Card surface")
        .padding()
        .designCardSurface()
        .padding()
}
