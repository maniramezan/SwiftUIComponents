import DesignSystem
import SwiftUI
import Testing

@testable import Components

@MainActor
@Test("Every TypographySlot resolves to the matching Typography member")
func typographySlotResolvesToMatchingMember() {
    let typography = DefaultTypography()

    let expected: [TypographySlot: Font] = [
        .largeTitle: typography.largeTitle,
        .title: typography.title,
        .title2: typography.title2,
        .title3: typography.title3,
        .headline: typography.headline,
        .body: typography.body,
        .callout: typography.callout,
        .subheadline: typography.subheadline,
        .footnote: typography.footnote,
        .caption: typography.caption,
        .caption2: typography.caption2,
        .button: typography.button,
        .control: typography.control,
        .badge: typography.badge,
        .field: typography.field,
        .largeTitleBold: typography.largeTitleBold,
        .title2Bold: typography.title2Bold,
        .title2Semibold: typography.title2Semibold,
        .title3Bold: typography.title3Bold,
        .title3Semibold: typography.title3Semibold,
        .headlineSemibold: typography.headlineSemibold,
        .bodySemibold: typography.bodySemibold,
        .bodyMedium: typography.bodyMedium,
        .subheadlineMedium: typography.subheadlineMedium,
        .subheadlineSemibold: typography.subheadlineSemibold,
        .footnoteSemibold: typography.footnoteSemibold,
        .captionSemibold: typography.captionSemibold,
        .captionBold: typography.captionBold,
        .caption2Bold: typography.caption2Bold,
    ]

    #expect(expected.count == TypographySlot.allCases.count)

    for slot in TypographySlot.allCases {
        #expect(slot.font(typography) == expected[slot])
    }
}

@MainActor
@Test("captionSemibold slot matches the caption-at-semibold ladder token")
func captionSemiboldSlotMatchesLadderToken() {
    let typography = DefaultTypography()

    #expect(TypographySlot.captionSemibold.font(typography) == typography.captionSemibold)
    #expect(typography.captionSemibold == typography.caption.weight(.semibold))
}

@MainActor
@Test("A custom font family flows through the slot resolver")
func customFontFamilyFlowsThroughSlot() {
    let typography = DefaultTypography(fontFamily: "Menlo")

    for slot in TypographySlot.allCases {
        #expect(slot.font(typography) == expectedFont(for: slot, in: typography))
    }
}

@MainActor
private func expectedFont(for slot: TypographySlot, in typography: some Typography) -> Font {
    switch slot {
    case .largeTitle: typography.largeTitle
    case .title: typography.title
    case .title2: typography.title2
    case .title3: typography.title3
    case .headline: typography.headline
    case .body: typography.body
    case .callout: typography.callout
    case .subheadline: typography.subheadline
    case .footnote: typography.footnote
    case .caption: typography.caption
    case .caption2: typography.caption2
    case .button: typography.button
    case .control: typography.control
    case .badge: typography.badge
    case .field: typography.field
    case .largeTitleBold: typography.largeTitleBold
    case .title2Bold: typography.title2Bold
    case .title2Semibold: typography.title2Semibold
    case .title3Bold: typography.title3Bold
    case .title3Semibold: typography.title3Semibold
    case .headlineSemibold: typography.headlineSemibold
    case .bodySemibold: typography.bodySemibold
    case .bodyMedium: typography.bodyMedium
    case .subheadlineMedium: typography.subheadlineMedium
    case .subheadlineSemibold: typography.subheadlineSemibold
    case .footnoteSemibold: typography.footnoteSemibold
    case .captionSemibold: typography.captionSemibold
    case .captionBold: typography.captionBold
    case .caption2Bold: typography.caption2Bold
    }
}
