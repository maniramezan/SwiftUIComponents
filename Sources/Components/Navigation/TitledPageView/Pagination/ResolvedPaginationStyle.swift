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
    let peekWidth: CGFloat
    let headerSpacing: CGFloat
    let titleGap: CGFloat
    let reduceMotionUsesCrossfade: Bool

    static func == (lhs: ResolvedPaginationStyle, rhs: ResolvedPaginationStyle) -> Bool {
        lhs.peekDirection == rhs.peekDirection
            && lhs.peekWidth == rhs.peekWidth
            && lhs.headerSpacing == rhs.headerSpacing
            && lhs.titleGap == rhs.titleGap
            && lhs.reduceMotionUsesCrossfade == rhs.reduceMotionUsesCrossfade
    }
}
