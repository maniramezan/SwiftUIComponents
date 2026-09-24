import SwiftUI

/// Plain (non-optional) style values produced by merging
/// ``PaginationStyle`` overrides with the active ``Theme``.
///
/// Held by ``TitledPageViewHeader`` and ``TitledPageViewIndicator`` so
/// they don't need to re-resolve theme tokens at every layout pass.
struct ResolvedPaginationStyle: Equatable {
    let titleFont: Font
    let titleColor: Color
    let adjacentTitleColor: Color
    let background: AnyShapeStyle?
    let indicatorActiveColor: Color
    let indicatorInactiveColor: Color
    let peekDirection: PaginationPeekDirection
    let titleAlignment: TitledPageTitleAlignment
    let peekWidth: CGFloat
    let headerSpacing: CGFloat
    let titleGap: CGFloat
    let reduceMotionUsesCrossfade: Bool
    /// Explicit leading padding for the title strip. `nil` means use the
    /// computed value (`peekWidth + titleGap` for bidirectional, `0` for
    /// unidirectional/none).
    let titleLeadingPadding: CGFloat?

    /// Compares every stored value except `background`, which is an `AnyShapeStyle`
    /// and not `Equatable`.
    ///
    /// SwiftUI may use this to decide whether the header and indicator need to
    /// re-render, so leaving out a value (a color, the font, the leading inset)
    /// would let an override change at runtime without the strip updating.
    static func == (lhs: ResolvedPaginationStyle, rhs: ResolvedPaginationStyle) -> Bool {
        lhs.titleFont == rhs.titleFont
            && lhs.titleColor == rhs.titleColor
            && lhs.adjacentTitleColor == rhs.adjacentTitleColor
            && lhs.indicatorActiveColor == rhs.indicatorActiveColor
            && lhs.indicatorInactiveColor == rhs.indicatorInactiveColor
            && lhs.titleLeadingPadding == rhs.titleLeadingPadding
            && lhs.peekDirection == rhs.peekDirection
            && lhs.titleAlignment == rhs.titleAlignment
            && lhs.peekWidth == rhs.peekWidth
            && lhs.headerSpacing == rhs.headerSpacing
            && lhs.titleGap == rhs.titleGap
            && lhs.reduceMotionUsesCrossfade == rhs.reduceMotionUsesCrossfade
    }
}
