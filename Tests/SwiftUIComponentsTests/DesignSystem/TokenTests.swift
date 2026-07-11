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
    #expect(motion.pressedOpacity == 0.82)
}

@Test("DefaultMotion supports custom reduced-motion and pressed-opacity overrides")
@MainActor
func defaultMotionSupportsOverrides() {
    let motion = DefaultMotion(pressedOpacity: 0.5, reducedMotionDuration: 0.1)
    #expect(motion.pressedOpacity == 0.5)

    let defaults = DefaultMotion()
    #expect(defaults.reducedMotionAnimation == .easeInOut(duration: 0.15))
    #expect(motion.reducedMotionAnimation == .easeInOut(duration: 0.1))
}

@Test("A minimal Motion conformer inherits pressedOpacity and reducedMotionAnimation defaults")
@MainActor
func motionProtocolExtensionProvidesDefaults() {
    let motion = MinimalMotion()
    #expect(motion.pressedOpacity == 0.82)
    #expect(motion.reducedMotionAnimation == .easeInOut(duration: 0.15))
}

@Test("A minimal ColorTheme conformer inherits the shadow default")
@MainActor
func colorThemeExtensionProvidesShadowDefault() {
    let colors = MinimalColorTheme()
    #expect(colors.shadow == .black)
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

// MARK: - Fixtures

/// A `Motion` conformer supplying only the original three requirements, to
/// prove `pressedOpacity` and `reducedMotionAnimation` fall back to the
/// protocol extension's defaults for any pre-existing custom conformer.
private struct MinimalMotion: Motion {
    let minimumHitTarget: CGFloat = 44
    let disabledOpacity: Double = 0.45
    @MainActor var standardAnimation: Animation { .easeInOut(duration: 0.2) }
}

/// A `ColorTheme` conformer supplying only the required members, to prove
/// `shadow` (and `segmentUnselectedBackground`) fall back to the protocol
/// extension's defaults for any pre-existing custom conformer.
private struct MinimalColorTheme: ColorTheme {
    @MainActor var background: Color { .white }
    @MainActor var backgroundSecondary: Color { .white }
    @MainActor var container: Color { .white }
    @MainActor var containerSecondary: Color { .white }
    @MainActor var primary: Color { .blue }
    @MainActor var onPrimary: Color { .white }
    @MainActor var textPrimary: Color { .black }
    @MainActor var textSecondary: Color { .gray }
    @MainActor var textTertiary: Color { .gray }
    @MainActor var border: Color { .gray }
    @MainActor var separator: Color { .gray }
    @MainActor var error: Color { .red }
    @MainActor var onError: Color { .white }
    @MainActor var success: Color { .green }
    @MainActor var warning: Color { .orange }
    @MainActor var disabled: Color { .gray }
}
