import Foundation

/// Pre-computed widths derived from the viewport size and resolved style.
struct TitledPageViewMetrics: Equatable, Sendable {

    /// Width of a single title slot inside the HStack.
    let slotWidth: CGFloat

    /// Distance between adjacent slot leading edges (slot width plus the gap).
    let slotStride: CGFloat

    /// Leading padding applied to the HStack so slot 0 lands in the right
    /// place at `progress == 0` for the selected peek direction.
    let leadingPadding: CGFloat

    init(viewportWidth: CGFloat, peek: CGFloat, gap: CGFloat, layout: TitledPageTitleLayout) {
        self.slotWidth = TitledPageViewMath.slotWidth(
            viewportWidth: viewportWidth,
            peek: peek,
            gap: gap,
            layout: layout
        )
        self.slotStride = TitledPageViewMath.slotStride(
            viewportWidth: viewportWidth,
            peek: peek,
            gap: gap,
            layout: layout
        )
        self.leadingPadding = TitledPageViewMath.headerLeadingPadding(
            peek: peek,
            gap: gap,
            layout: layout
        )
    }
}
