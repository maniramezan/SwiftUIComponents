import DesignSystem
import SwiftUI

/// Pure, `nonisolated` geometry/accessibility helpers shared by every
/// horizontally scrollable component that veils its edges
/// (`SegmentedPicker`, `CarouselRow`, `TitledPageView`).
///
/// Extracting this math keeps the layout logic unit-testable without rendering
/// any SwiftUI view and removes the byte-for-byte copies that previously lived
/// in each component's private math type.
enum ScrollLayoutMath {

    /// Determines which scrollable edges should fade based on the current
    /// scroll geometry. Returns `(false, false)` whenever the content fits
    /// inside the viewport.
    ///
    /// - Parameters:
    ///   - contentOffsetX: The current horizontal content offset.
    ///   - contentWidth: The total scrollable content width.
    ///   - viewportWidth: The visible width of the scroll view.
    ///   - threshold: Slop, in points, used to ignore sub-pixel offsets that
    ///     could otherwise trigger a fade as soon as the user lifts a finger.
    /// - Returns: A pair of booleans indicating whether the leading and
    ///   trailing edges, respectively, should render an indicator band.
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
}

/// A snapshot of a horizontally scrollable view's geometry, tracked via
/// `onScrollGeometryChange` to drive the edge-fade veil and accessibility
/// scrolling.
struct ScrollGeometrySnapshot: Equatable {
    var offsetX: CGFloat = 0
    var contentWidth: CGFloat = 0
    var viewportWidth: CGFloat = 0
}

/// Two trough-colored gradient bands that veil the scrollable edges and fade
/// out once that end is reached. Decorative and non-interactive.
struct ScrollEdgeVeil: View {

    let geometry: ScrollGeometrySnapshot
    let animation: Animation
    let troughColor: Color
    let bandWidth: CGFloat

    var body: some View {
        let edges = ScrollLayoutMath.edgeFade(
            contentOffsetX: geometry.offsetX,
            contentWidth: geometry.contentWidth,
            viewportWidth: geometry.viewportWidth
        )
        HStack(spacing: 0) {
            ScrollEdgeBand(visible: edges.leading, isLeading: true, troughColor: troughColor, width: bandWidth)
            Spacer(minLength: 0)
            ScrollEdgeBand(visible: edges.trailing, isLeading: false, troughColor: troughColor, width: bandWidth)
        }
        .allowsHitTesting(false)
        .animation(animation, value: edges.leading)
        .animation(animation, value: edges.trailing)
    }
}

/// A single edge-fade gradient band used by ``ScrollEdgeVeil``.
struct ScrollEdgeBand: View {

    let visible: Bool
    let isLeading: Bool
    let troughColor: Color
    let width: CGFloat

    var body: some View {
        let colors: [Color] =
            isLeading
            ? [troughColor, troughColor.opacity(0)]
            : [troughColor.opacity(0), troughColor]
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.5)
        )
        .frame(width: width)
        .opacity(visible ? 1 : 0)
    }
}

extension View {
    /// Overlays trough-colored gradient bands that veil the leading and
    /// trailing edges of a horizontal scroll view, fading out once that edge is
    /// reached.
    ///
    /// - Parameters:
    ///   - geometry: The current scroll geometry snapshot driving the fade.
    ///   - animation: The animation applied when an edge starts or stops fading.
    ///   - troughColor: The color of the scroll view's background, used as the
    ///     gradient trough.
    ///   - bandWidth: The width of each edge-fade band, in points.
    func scrollEdgeVeil(
        geometry: ScrollGeometrySnapshot,
        animation: Animation,
        troughColor: Color,
        bandWidth: CGFloat
    ) -> some View {
        overlay(
            ScrollEdgeVeil(
                geometry: geometry,
                animation: animation,
                troughColor: troughColor,
                bandWidth: bandWidth
            )
        )
    }
}
