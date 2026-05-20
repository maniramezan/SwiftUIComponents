import DesignSystem
import SwiftUI

// MARK: - Pure helpers

extension TitledPageView {

    /// Converts a raw horizontal scroll offset into a continuous page
    /// progress value (page 0 → 0, page 1 → 1, …). Guards against zero
    /// viewport widths.
    nonisolated static func progress(contentOffsetX: CGFloat, viewportWidth: CGFloat) -> CGFloat {
        guard viewportWidth > 0 else { return 0 }
        return contentOffsetX / viewportWidth
    }

    /// Returns the index `from + step` clamped to `0 ..< count`. Returns
    /// `from` unchanged when `count` is zero.
    nonisolated static func stepIndex(by step: Int, from: Int, count: Int) -> Int {
        guard count > 0 else { return from }
        let raw = from + step
        return max(0, min(count - 1, raw))
    }

    /// Converts an accessibility scroll edge into a logical page delta.
    ///
    /// Leading/trailing edges are layout-direction aware because the next page
    /// appears on the leading edge in right-to-left layouts.
    nonisolated static func accessibilityStep(for edge: Edge, layoutDirection: LayoutDirection) -> Int {
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

    /// Whether the indicator subview should render at all. Hidden styles
    /// always return `false`; visible styles require more than one page.
    nonisolated static func shouldShowIndicator(
        count: Int,
        style: PaginationIndicatorStyle
    ) -> Bool {
        switch style {
        case .hidden: return false
        case .dots, .bar: return count > 1
        }
    }

    /// Merges a ``PaginationStyle`` override with the active theme to
    /// produce a fully-resolved style snapshot. Internal — used by the
    /// header and indicator subviews.
    @MainActor
    static func resolveStyle(
        override: PaginationStyle,
        theme: any Theme,
        titleAlignment: TitledPageTitleAlignment = .automatic
    ) -> ResolvedPaginationStyle {
        let effectiveTitleAlignment =
            titleAlignment == .automatic ? override.titleAlignment : titleAlignment
        return ResolvedPaginationStyle(
            titleFont: override.titleFont ?? theme.typography.title,
            titleColor: override.titleColor ?? theme.colors.textPrimary,
            adjacentTitleColor: override.adjacentTitleColor ?? theme.colors.textTertiary,
            background: override.background,
            indicatorActiveColor: override.indicatorActiveColor ?? theme.colors.primary,
            indicatorInactiveColor: override.indicatorInactiveColor ?? theme.colors.disabled,
            peekDirection: override.peekDirection,
            titleAlignment: effectiveTitleAlignment,
            peekWidth: override.peekWidth ?? theme.spacing.fiveUnits,
            headerSpacing: override.headerSpacing ?? theme.spacing.twoUnits,
            titleGap: override.titleGap ?? theme.spacing.twoUnits,
            reduceMotionUsesCrossfade: override.reduceMotionUsesCrossfade,
            titleLeadingPadding: override.titleLeadingPadding
        )
    }
}
