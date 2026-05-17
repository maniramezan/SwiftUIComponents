import DesignSystem
import SwiftUI

/// Internal title strip drawn above the page content of `DesignPagedView`.
///
/// Renders a horizontal row of page titles offset in lockstep with the
/// underlying scroll view's content offset, optionally revealing partial
/// titles for the previous and/or next page (the "peek").
///
/// This view is **internal**; consumers customize its appearance through
/// ``DesignPaginationStyle`` and the active ``DesignTheme``.
struct DesignPaginationHeader: View {

    /// Resolved (theme-merged) configuration used to draw the strip.
    let resolved: ResolvedPaginationStyle

    /// Page titles in display order.
    let titles: [String]

    /// Continuous progress through the page set. Integer values mean a page
    /// is exactly snapped; fractional values represent in-flight drags.
    let progress: CGFloat

    /// Snapped index of the most-active page (used to color the active title).
    let activeIndex: Int

    /// Current viewport width, in points. The strip degrades gracefully if 0.
    let viewportWidth: CGFloat

    /// Layout direction sign: `+1` for LTR, `-1` for RTL.
    let layoutSign: CGFloat

    /// Whether the system Reduce Motion preference is currently on.
    let reduceMotion: Bool

    var body: some View {
        let effectiveGap: CGFloat = effectiveDirection == .none ? 0 : resolved.titleGap
        let metrics = DesignPaginationMetrics(
            viewportWidth: viewportWidth,
            peek: effectivePeek,
            gap: effectiveGap,
            direction: effectiveDirection
        )

        ZStack(alignment: .leading) {
            // Transparent spacer so the strip claims a sensible height even
            // when titles haven't been measured yet.
            Color.clear.frame(height: 1)

            if viewportWidth > 0, !titles.isEmpty {
                HStack(spacing: effectiveGap) {
                    ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                        Text(title)
                            .font(resolved.titleFont)
                            .foregroundStyle(titleColor(for: index))
                            .opacity(titleOpacity(for: index))
                            .animation(.easeInOut(duration: 0.2), value: activeIndex)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .frame(width: metrics.slotWidth, alignment: .leading)
                    }
                }
                .padding(.leading, metrics.leadingPadding)
                .offset(
                    x: DesignPaginationMath.headerOffset(
                        progress: effectiveProgress,
                        stride: metrics.slotStride,
                        layoutSign: layoutSign
                    )
                )
                .animation(reduceMotion ? .easeInOut(duration: 0.15) : nil, value: activeIndex)
                .frame(width: viewportWidth, alignment: .leading)
                .clipped()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .accessibilityHidden(true)
    }

    // MARK: - Resolved per-frame values

    /// Peek collapses to zero under Reduce Motion when crossfade fallback is
    /// enabled, so the strip cross-fades between titles rather than
    /// parallax-sliding them.
    private var effectivePeek: CGFloat {
        DesignPaginationMath.effectivePeek(
            configured: resolved.peekWidth,
            direction: resolved.peekDirection,
            reduceMotion: reduceMotion,
            usesCrossfade: resolved.reduceMotionUsesCrossfade
        )
    }

    /// Peek direction also collapses to `.none` when Reduce Motion is on,
    /// preventing partial titles from sliding in.
    private var effectiveDirection: DesignPaginationPeekDirection {
        if reduceMotion && resolved.reduceMotionUsesCrossfade {
            return .none
        }
        return resolved.peekDirection
    }

    /// Under Reduce Motion + crossfade, the strip snaps to the nearest
    /// integer progress so there is no continuous slide between titles.
    private var effectiveProgress: CGFloat {
        if reduceMotion && resolved.reduceMotionUsesCrossfade {
            return CGFloat(activeIndex)
        }
        return progress
    }

    private func titleColor(for index: Int) -> Color {
        index == activeIndex ? resolved.titleColor : resolved.adjacentTitleColor
    }

    private func titleOpacity(for index: Int) -> Double {
        if index == activeIndex { return 1.0 }
        // In next-only mode, previous titles must be fully invisible.
        // The opacity change is animated via .animation(value: activeIndex) on the Text.
        if effectiveDirection == .unidirectional && index < activeIndex { return 0.0 }
        return 0.6
    }
}

// MARK: - Metrics

/// Pre-computed widths derived from the viewport size and resolved style.
struct DesignPaginationMetrics: Equatable, Sendable {

    /// Width of a single title slot inside the HStack.
    let slotWidth: CGFloat

    /// Distance between adjacent slot leading edges (slot width plus the gap).
    let slotStride: CGFloat

    /// Leading padding applied to the HStack so slot 0 lands in the right
    /// place at `progress == 0` for the selected peek direction.
    let leadingPadding: CGFloat

    init(viewportWidth: CGFloat, peek: CGFloat, gap: CGFloat, direction: DesignPaginationPeekDirection) {
        self.slotWidth = DesignPaginationMath.slotWidth(
            viewportWidth: viewportWidth,
            peek: peek,
            gap: gap,
            direction: direction
        )
        self.slotStride = DesignPaginationMath.slotStride(
            viewportWidth: viewportWidth,
            peek: peek,
            gap: gap,
            direction: direction
        )
        self.leadingPadding = DesignPaginationMath.headerLeadingPadding(
            peek: peek,
            gap: gap,
            direction: direction
        )
    }
}

// MARK: - Previews

private let _headerPreviewStyle = ResolvedPaginationStyle(
    titleFont: .title2.bold(),
    titleColor: .primary,
    adjacentTitleColor: .secondary,
    background: nil,
    indicatorActiveColor: .blue,
    indicatorInactiveColor: Color.secondary.opacity(0.5),
    peekDirection: .bidirectional,
    peekWidth: 40,
    headerSpacing: 16,
    titleGap: 16,
    reduceMotionUsesCrossfade: true
)

private let _headerPreviewTitles = ["Best of 2025", "Spotlight: Health", "Travel Companions"]

#Preview("Snapped to first page") {
    DesignPaginationHeader(
        resolved: _headerPreviewStyle,
        titles: _headerPreviewTitles,
        progress: 0,
        activeIndex: 0,
        viewportWidth: 360,
        layoutSign: 1,
        reduceMotion: false
    )
    .frame(width: 360)
    .padding(.vertical)
}

#Preview("Mid-swipe between pages 1 and 2") {
    DesignPaginationHeader(
        resolved: _headerPreviewStyle,
        titles: _headerPreviewTitles,
        progress: 1.4,
        activeIndex: 1,
        viewportWidth: 360,
        layoutSign: 1,
        reduceMotion: false
    )
    .frame(width: 360)
    .padding(.vertical)
}

// MARK: - Resolved style snapshot

/// Plain (non-optional) style values produced by merging
/// ``DesignPaginationStyle`` overrides with the active ``DesignTheme``.
///
/// Held by ``DesignPaginationHeader`` and ``DesignPaginationIndicator`` so
/// they don't need to re-resolve theme tokens at every layout pass.
struct ResolvedPaginationStyle: Equatable {
    let titleFont: Font
    let titleColor: Color
    let adjacentTitleColor: Color
    let background: AnyShapeStyle?
    let indicatorActiveColor: Color
    let indicatorInactiveColor: Color
    let peekDirection: DesignPaginationPeekDirection
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
