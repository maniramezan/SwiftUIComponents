import DesignSystem
import SwiftUI
import Testing

@Test("Default spacing follows the approved 4/8-point scale")
func defaultSpacingUsesApprovedScale() {
    let spacing = DefaultSpacing()

    #expect(spacing.halfUnit == 4)
    #expect(spacing.oneUnit == 8)
    #expect(spacing.oneAndHalfUnits == 12)
    #expect(spacing.twoUnits == 16)
    #expect(spacing.twoAndHalfUnits == 20)
    #expect(spacing.threeUnits == 24)
    #expect(spacing.fourUnits == 32)
    #expect(spacing.fiveUnits == 40)
    #expect(spacing.sixUnits == 48)
}

@Test("Default shape and interaction tokens expose standard component values")
func defaultShapeAndInteractionTokens() {
    let radius = DefaultRadius()
    let stroke = DefaultStroke()
    let motion = DefaultMotion()

    #expect(radius.oneUnit == 8)
    #expect(radius.oneAndHalfUnits == 12)
    #expect(radius.twoUnits == 16)
    #expect(radius.threeUnits == 24)
    #expect(radius.pill == 999)
    #expect(stroke.hairline == 0.5)
    #expect(stroke.thin == 1)
    #expect(stroke.regular == 2)
    #expect(stroke.thick == 4)
    #expect(motion.minimumHitTarget == 44)
    #expect(motion.disabledOpacity == 0.45)
}

@Test("Default theme exposes overrideable public token groups")
func defaultThemeExposesTokenGroups() {
    let theme = DefaultTheme(spacing: DefaultSpacing(twoUnits: 18))

    #expect(theme.spacing.twoUnits == 18)
    #expect(theme.radius.oneAndHalfUnits == 12)
    #expect(theme.stroke.thin == 1)
    #expect(theme.motion.minimumHitTarget == 44)
}

@Test("Default colors expose segmented control unselected background")
@MainActor
func defaultColorsExposeSegmentUnselectedBackground() {
    let colors = DefaultColors()

    _ = colors.segmentUnselectedBackground
}

@Test("Typography can be initialized with custom font family")
func typographySupportsCustomFamily() {
    _ = DefaultTypography(fontFamily: "Avenir Next")
}
