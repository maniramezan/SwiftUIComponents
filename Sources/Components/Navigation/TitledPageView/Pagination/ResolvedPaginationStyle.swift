import SwiftUI

/// Plain (non-optional) style values produced by merging
/// ``PaginationStyle`` overrides with the active ``Theme``.
///
/// Held by ``TitledPageViewHeader`` and ``TitledPageViewIndicator`` so
/// they don't need to re-resolve theme tokens at every layout pass.
struct ResolvedPaginationStyle {
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

}
