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
    #expect(motion.animation(reducingMotion: true) == motion.reducedMotionAnimation)
    #expect(motion.animation(reducingMotion: false) == motion.standardAnimation)
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

@Test("Default typography exposes every weight variant")
@MainActor
func defaultTypographyExposesWeightVariants() {
    let typography = DefaultTypography()

    _ = typography.largeTitleBold
    _ = typography.title2Bold
    _ = typography.title2Semibold
    _ = typography.title3Bold
    _ = typography.title3Semibold
    _ = typography.headlineSemibold
    _ = typography.bodySemibold
    _ = typography.bodyMedium
    _ = typography.subheadlineMedium
    _ = typography.subheadlineSemibold
    _ = typography.footnoteSemibold
    _ = typography.captionSemibold
    _ = typography.captionBold
    _ = typography.caption2Bold
}

@Test("Weight variants derive from the conformer's own base slots")
@MainActor
func weightVariantsDeriveFromBaseSlots() {
    let typography = MinimalTypography()

    // A conformer's own slot, re-weighted — not a hard-coded system font. Proves a custom
    // font family or text-style mapping flows through the whole ladder.
    #expect(typography.bodySemibold == typography.body.weight(.semibold))
    #expect(typography.captionBold == typography.caption.bold())
    #expect(typography.title3Semibold == typography.title3.weight(.semibold))
}

@Test("Default colors expose every overlay, interactive-tint and skeleton role")
@MainActor
func defaultColorsExposeRoleTokens() {
    let colors = DefaultColors()

    _ = colors.interactiveSubtle
    _ = colors.overlaySubtle
    _ = colors.overlayMedium
    _ = colors.overlayHeavy
    _ = colors.onOverlay
    _ = colors.overlayShadowStart
    _ = colors.overlayShadowEnd
    _ = colors.overlayBottomTint
    _ = colors.shimmerHighlight
}

@Test("Role tokens derive from the conformer's own base colors")
@MainActor
func roleTokensDeriveFromBaseColors() {
    let colors = MinimalColorTheme()

    // Derived from this conformer's own primary/shadow, not a hard-coded black or blue,
    // so a theme that overrides either gets a consistent scrim and tint for free.
    #expect(colors.interactiveSubtle == colors.primary.opacity(0.15))
    #expect(colors.overlayHeavy == colors.shadow.opacity(0.75))
    #expect(colors.shimmerHighlight == colors.shadow.opacity(0.07))
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

/// A `Typography` conformer supplying only the original fifteen requirements, to prove the
/// weight variants fall back to the protocol extension's defaults for any pre-existing
/// custom conformer.
private struct MinimalTypography: Typography {
    @MainActor var largeTitle: Font { .largeTitle }
    @MainActor var title: Font { .title }
    @MainActor var title2: Font { .title2 }
    @MainActor var title3: Font { .title3 }
    @MainActor var headline: Font { .headline }
    @MainActor var body: Font { .body }
    @MainActor var callout: Font { .callout }
    @MainActor var subheadline: Font { .subheadline }
    @MainActor var footnote: Font { .footnote }
    @MainActor var caption: Font { .caption }
    @MainActor var caption2: Font { .caption2 }
    @MainActor var button: Font { .body.weight(.semibold) }
    @MainActor var control: Font { .body.weight(.medium) }
    @MainActor var badge: Font { .caption.weight(.semibold) }
    @MainActor var field: Font { .body }
}
