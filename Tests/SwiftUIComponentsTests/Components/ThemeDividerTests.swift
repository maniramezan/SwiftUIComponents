import DesignSystem
import SwiftUI
import Testing

@testable import Components

@MainActor
struct ThemeDividerTests {
    @Test(arguments: [ColorScheme.light, ColorScheme.dark])
    func dividerUsesTheHairlineStroke(colorScheme: ColorScheme) {
        let stroke = DefaultStroke(hairline: 3, thin: 5)
        let divider = ThemeDivider()
            .designTheme(DefaultTheme(stroke: stroke))
            .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: divider)
        renderer.proposedSize = ProposedViewSize(width: 160, height: nil)

        var height: CGFloat?
        renderer.render { size, _ in height = size.height }
        #expect(height == stroke.hairline)
    }
}
