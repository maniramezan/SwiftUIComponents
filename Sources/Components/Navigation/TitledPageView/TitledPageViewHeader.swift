import DesignSystem
import SwiftUI

/// Internal title strip drawn above the page content of `TitledPageView`.
///
/// Renders a horizontal row of page titles offset in lockstep with the
/// underlying scroll view's content offset, optionally revealing partial
/// titles for the previous and/or next page (the "peek").
///
/// This view is **internal**; consumers customize its appearance through
/// ``PaginationStyle`` and the active ``Theme``.
struct TitledPageViewHeader: View {

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

    /// Whether the system Reduce Motion preference is currently on.
    let reduceMotion: Bool

    /// Called when the user taps a non-active title to navigate to that page.
    let onJump: (Int) -> Void

    var body: some View {
        let layout = effectiveTitleLayout
        let metrics = TitledPageViewMetrics(
            viewportWidth: viewportWidth,
            peek: effectivePeek,
            gap: resolved.titleGap,
            layout: layout
        )

        ZStack(alignment: .leading) {
            // Transparent spacer so the strip claims a sensible height even
            // when titles haven't been measured yet.
            Color.clear.frame(height: 1)

            if viewportWidth > 0, !titles.isEmpty {
                HStack(spacing: resolved.titleGap) {
                    ForEach(Array(titles.enumerated()), id: \.offset) { index, title in
                        Text(title)
                            .font(resolved.titleFont)
                            .foregroundStyle(titleColor(for: index))
                            .opacity(titleOpacity(for: index))
                            .animation(.easeInOut(duration: 0.2), value: activeIndex)
                            .lineLimit(1)
                            .minimumScaleFactor(0.85)
                            .frame(width: metrics.slotWidth, alignment: slotAlignment(for: layout))
                            .contentShape(Rectangle())
                            .onTapGesture { onJump(index) }
                            .allowsHitTesting(index != activeIndex)
                    }
                }
                .padding(.leading, resolved.titleLeadingPadding ?? metrics.leadingPadding)
                .offset(
                    x: TitledPageViewMath.headerOffset(
                        progress: effectiveProgress,
                        stride: metrics.slotStride
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
        TitledPageViewMath.effectivePeek(
            configured: resolved.peekWidth,
            layout: effectiveTitleLayout,
            reduceMotion: reduceMotion,
            usesCrossfade: resolved.reduceMotionUsesCrossfade
        )
    }

    /// Title layout also collapses to `.center` when Reduce Motion is on,
    /// preventing partial titles from sliding in.
    private var effectiveTitleLayout: TitledPageTitleLayout {
        if reduceMotion && resolved.reduceMotionUsesCrossfade {
            return .center
        }
        return TitledPageViewMath.titleLayout(
            for: resolved.titleAlignment,
            fallbackDirection: resolved.peekDirection
        ) ?? .center
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
        // In unidirectional modes, titles on the non-peek side are
        // visible but strongly dimmed to communicate they are disabled
        // (visited/previous pages in leading mode; upcoming pages in trailing mode).
        if effectiveTitleLayout == .leading && index < activeIndex { return 0.3 }
        if effectiveTitleLayout == .trailing && index > activeIndex { return 0.3 }
        return 0.6
    }

    private func slotAlignment(for layout: TitledPageTitleLayout) -> Alignment {
        switch layout {
        case .bidirectional, .leading:
            return .leading
        case .trailing:
            return .trailing
        case .center:
            return .center
        }
    }
}

// MARK: - Previews

@MainActor
private func headerPreviewStyle(theme: any Theme) -> ResolvedPaginationStyle {
    ResolvedPaginationStyle(
        titleFont: theme.typography.title2,
        titleColor: theme.colors.textPrimary,
        adjacentTitleColor: theme.colors.textSecondary,
        background: nil,
        indicatorActiveColor: theme.colors.primary,
        indicatorInactiveColor: theme.colors.disabled,
        peekDirection: .bidirectional,
        titleAlignment: .automatic,
        peekWidth: theme.spacing.fiveUnits,
        headerSpacing: theme.spacing.twoUnits,
        titleGap: theme.spacing.twoUnits,
        reduceMotionUsesCrossfade: true,
        titleLeadingPadding: nil
    )
}

private let _headerPreviewTitles = ["Best of 2025", "Spotlight: Health", "Travel Companions"]

#Preview("Snapped to first page") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: headerPreviewStyle(theme: theme),
            titles: _headerPreviewTitles,
            progress: 0,
            activeIndex: 0,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}

#Preview("Mid-swipe between pages 1 and 2") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: headerPreviewStyle(theme: theme),
            titles: _headerPreviewTitles,
            progress: 1.4,
            activeIndex: 1,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}

#Preview("Center alignment – snapped to page 1") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: {
                let s = headerPreviewStyle(theme: theme)
                return ResolvedPaginationStyle(
                    titleFont: s.titleFont,
                    titleColor: s.titleColor,
                    adjacentTitleColor: s.adjacentTitleColor,
                    background: s.background,
                    indicatorActiveColor: s.indicatorActiveColor,
                    indicatorInactiveColor: s.indicatorInactiveColor,
                    peekDirection: .bidirectional,
                    titleAlignment: .center,
                    peekWidth: s.peekWidth,
                    headerSpacing: s.headerSpacing,
                    titleGap: s.titleGap,
                    reduceMotionUsesCrossfade: s.reduceMotionUsesCrossfade,
                    titleLeadingPadding: s.titleLeadingPadding
                )
            }(),
            titles: _headerPreviewTitles,
            progress: 1,
            activeIndex: 1,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}

#Preview("Unidirectional – dimmed previous title") {
    PreviewContent { theme in
        TitledPageViewHeader(
            resolved: {
                let s = headerPreviewStyle(theme: theme)
                return ResolvedPaginationStyle(
                    titleFont: s.titleFont,
                    titleColor: s.titleColor,
                    adjacentTitleColor: s.adjacentTitleColor,
                    background: s.background,
                    indicatorActiveColor: s.indicatorActiveColor,
                    indicatorInactiveColor: s.indicatorInactiveColor,
                    peekDirection: .unidirectional,
                    titleAlignment: .leading,
                    peekWidth: s.peekWidth,
                    headerSpacing: s.headerSpacing,
                    titleGap: s.titleGap,
                    reduceMotionUsesCrossfade: s.reduceMotionUsesCrossfade,
                    titleLeadingPadding: s.titleLeadingPadding
                )
            }(),
            titles: _headerPreviewTitles,
            progress: 1,
            activeIndex: 1,
            viewportWidth: 360,
            reduceMotion: false,
            onJump: { _ in }
        )
        .frame(width: 360)
        .padding(.vertical, theme.spacing.twoUnits)
    }
}
