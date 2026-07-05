import SwiftUI

/// Pure, `nonisolated` geometry helpers for ``CarouselRow``.
///
/// Extracting this math keeps the layout logic unit-testable without rendering
/// any SwiftUI view, mirroring the approach used by `SegmentedPicker`.
enum CarouselRowMath {

    /// The width each item should occupy for a given sizing strategy, or `nil`
    /// when the item should use its intrinsic width (or fall back to a
    /// container-relative frame because the viewport has not been measured yet).
    ///
    /// - Parameters:
    ///   - viewportWidth: The measured visible width of the scroll view. `0`
    ///     before the first layout pass.
    ///   - sizing: The requested sizing strategy.
    ///   - spacing: The inter-item spacing (also the leading/trailing content
    ///     margin), in points.
    /// - Returns: A concrete width in points, or `nil` to let the item size
    ///   itself / use a container-relative fallback.
    nonisolated static func itemWidth(
        viewportWidth: CGFloat,
        sizing: CarouselItemSizing,
        spacing: CGFloat
    ) -> CGFloat? {
        switch sizing.kind {
        case let .peek(visibleCount, peek):
            // Not yet measured — caller falls back to a container-relative frame
            // so items never collapse to zero width on the first frame.
            guard viewportWidth > 0 else { return nil }
            let count = max(1, visibleCount)
            // Reserve the peek sliver plus one spacing gap per visible item.
            let available = viewportWidth - peek - spacing * CGFloat(count)
            return max(0, available / CGFloat(count))
        case let .fixedWidth(width):
            return max(0, width)
        case .fitContent:
            return nil
        }
    }

    /// Determines which scrollable edges should fade based on the current scroll
    /// geometry. Returns `(false, false)` whenever the content fits inside the
    /// viewport.
    ///
    /// - Parameters:
    ///   - contentOffsetX: The current horizontal content offset.
    ///   - contentWidth: The total scrollable content width.
    ///   - viewportWidth: The visible width of the scroll view.
    ///   - threshold: Slop, in points, used to ignore sub-pixel offsets.
    /// - Returns: Whether the leading and trailing edges, respectively, should
    ///   render a fade band.
    nonisolated static func edgeFade(
        contentOffsetX: CGFloat,
        contentWidth: CGFloat,
        viewportWidth: CGFloat,
        threshold: CGFloat = 1
    ) -> (leading: Bool, trailing: Bool) {
        guard contentWidth > viewportWidth + threshold else { return (false, false) }
        let canScrollLeading = contentOffsetX > threshold
        let canScrollTrailing = contentOffsetX + viewportWidth < contentWidth - threshold
        return (canScrollLeading, canScrollTrailing)
    }

    /// Converts an accessibility scroll edge into a logical index delta.
    /// Leading/trailing flip under right-to-left layout so VoiceOver always
    /// advances forward through the items.
    ///
    /// - Parameters:
    ///   - edge: The edge the user scrolled toward.
    ///   - layoutDirection: The active layout direction.
    /// - Returns: `-1` to move toward the start, `+1` toward the end.
    nonisolated static func accessibilityStep(
        for edge: Edge,
        layoutDirection: LayoutDirection
    ) -> Int {
        switch edge {
        case .leading:
            return layoutDirection == .rightToLeft ? +1 : -1
        case .trailing:
            return layoutDirection == .rightToLeft ? -1 : +1
        case .top:
            return -1
        case .bottom:
            return +1
        @unknown default:
            return +1
        }
    }

    /// Clamps an index into the valid `0..<count` range. Returns `0` for an
    /// empty collection.
    ///
    /// - Parameters:
    ///   - index: The candidate index.
    ///   - count: The number of items.
    /// - Returns: The clamped index.
    nonisolated static func clampedIndex(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return min(max(0, index), count - 1)
    }

    /// The number of items an accessibility scroll action advances by — one page
    /// of visible items for a peeking row, otherwise a single item.
    ///
    /// - Parameter sizing: The active sizing strategy.
    /// - Returns: The per-action index stride, at least `1`.
    nonisolated static func pageStride(sizing: CarouselItemSizing) -> Int {
        switch sizing.kind {
        case let .peek(visibleCount, _):
            return max(1, visibleCount)
        case .fixedWidth, .fitContent:
            return 1
        }
    }
}
