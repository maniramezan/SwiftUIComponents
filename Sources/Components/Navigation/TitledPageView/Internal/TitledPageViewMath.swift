import Foundation

/// Pure, unit-tested geometry helpers shared by the header and metrics types.
enum TitledPageViewMath {

    /// Width of one title slot in the header HStack for the given peek mode.
    nonisolated static func slotWidth(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        direction: PaginationPeekDirection
    ) -> CGFloat {
        switch direction {
        case .bidirectional:
            return max(0, viewportWidth - 2 * peek - 2 * gap)
        case .unidirectional:
            return max(0, viewportWidth - peek - gap)
        case .none:
            return max(0, viewportWidth)
        }
    }

    /// Distance between adjacent slot leading edges (`slotWidth + gap`).
    nonisolated static func slotStride(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        direction: PaginationPeekDirection
    ) -> CGFloat {
        let width = slotWidth(viewportWidth: viewportWidth, peek: peek, gap: gap, direction: direction)
        switch direction {
        case .bidirectional, .unidirectional:
            return width + gap
        case .none:
            return width
        }
    }

    /// Leading padding the header HStack should apply so that, at
    /// `progress == 0`, the first slot sits where it visually belongs for
    /// the selected peek direction.
    nonisolated static func headerLeadingPadding(
        peek: CGFloat,
        gap: CGFloat,
        direction: PaginationPeekDirection
    ) -> CGFloat {
        switch direction {
        case .bidirectional: return peek + gap
        case .unidirectional, .none: return 0
        }
    }

    /// The horizontal offset to apply to the header HStack for a given
    /// progress value. `layoutSign` is `+1` for left-to-right layouts and
    /// `-1` for right-to-left.
    nonisolated static func headerOffset(
        progress: CGFloat,
        stride: CGFloat,
        layoutSign: CGFloat
    ) -> CGFloat {
        layoutSign * (-progress * stride)
    }

    /// Effective peek width after applying the Reduce Motion fallback.
    ///
    /// When Reduce Motion is on and the style opts into cross-fade behavior,
    /// peek collapses to zero so the strip cross-fades rather than slides
    /// fractional titles.
    nonisolated static func effectivePeek(
        configured: CGFloat,
        direction: PaginationPeekDirection,
        reduceMotion: Bool,
        usesCrossfade: Bool
    ) -> CGFloat {
        if reduceMotion && usesCrossfade { return 0 }
        if direction == .none { return 0 }
        return max(0, configured)
    }
}
