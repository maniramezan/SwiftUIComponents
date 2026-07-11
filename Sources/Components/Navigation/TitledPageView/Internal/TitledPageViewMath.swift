import DesignSystem
import Foundation
import SwiftUI

/// Header title layout modes used for geometry calculations.
enum TitledPageTitleLayout: Sendable, Hashable, CaseIterable {
    case bidirectional
    case leading
    case trailing
    case center
}

/// Pure, unit-tested geometry helpers shared by the header and metrics types.
enum TitledPageViewMath {

    /// Width of one title slot in the header HStack for the given peek mode.
    nonisolated static func slotWidth(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        direction: PaginationPeekDirection
    ) -> CGFloat {
        slotWidth(
            viewportWidth: viewportWidth,
            peek: peek,
            gap: gap,
            layout: titleLayout(for: direction)
        )
    }

    /// Width of one title slot in the header HStack for the given layout.
    nonisolated static func slotWidth(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        layout: TitledPageTitleLayout
    ) -> CGFloat {
        switch layout {
        case .bidirectional, .center:
            return max(0, viewportWidth - 2 * peek - 2 * gap)
        case .leading, .trailing:
            return max(0, viewportWidth - peek - gap)
        }
    }

    /// Distance between adjacent slot leading edges (`slotWidth + gap`).
    nonisolated static func slotStride(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        direction: PaginationPeekDirection
    ) -> CGFloat {
        slotStride(
            viewportWidth: viewportWidth,
            peek: peek,
            gap: gap,
            layout: titleLayout(for: direction)
        )
    }

    /// Distance between adjacent slot leading edges (`slotWidth + gap`).
    nonisolated static func slotStride(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        layout: TitledPageTitleLayout
    ) -> CGFloat {
        let width = slotWidth(viewportWidth: viewportWidth, peek: peek, gap: gap, layout: layout)
        return width + gap
    }

    /// Leading padding the header HStack should apply so that, at
    /// `progress == 0`, the first slot sits where it visually belongs for
    /// the selected peek direction.
    nonisolated static func headerLeadingPadding(
        peek: CGFloat,
        gap: CGFloat,
        direction: PaginationPeekDirection
    ) -> CGFloat {
        headerLeadingPadding(peek: peek, gap: gap, layout: titleLayout(for: direction))
    }

    /// Leading padding the header HStack should apply for the selected layout.
    nonisolated static func headerLeadingPadding(
        peek: CGFloat,
        gap: CGFloat,
        layout: TitledPageTitleLayout
    ) -> CGFloat {
        switch layout {
        case .bidirectional, .trailing, .center: return peek + gap
        case .leading: return 0
        }
    }

    /// The horizontal offset to apply to the header HStack for a given
    /// progress value.
    ///
    /// `progress` is always logical (0 at the first page, increasing toward
    /// the last) and the returned offset is expressed in the natural,
    /// pre-mirroring coordinate space. SwiftUI mirrors `offset(x:)` (along
    /// with the surrounding `HStack`, padding, and frame alignment) in
    /// right-to-left layouts automatically, so the header must **not** flip
    /// the sign itself — doing so double-mirrors and drives the active title
    /// off-screen.
    nonisolated static func headerOffset(
        progress: CGFloat,
        stride: CGFloat
    ) -> CGFloat {
        -progress * stride
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
        // The .none direction means no peek regardless of what is configured.
        if direction == .none { return 0 }
        return effectivePeek(
            configured: configured,
            layout: titleLayout(for: direction),
            reduceMotion: reduceMotion,
            usesCrossfade: usesCrossfade
        )
    }

    /// Effective peek width after applying the Reduce Motion fallback.
    nonisolated static func effectivePeek(
        configured: CGFloat,
        layout: TitledPageTitleLayout,
        reduceMotion: Bool,
        usesCrossfade: Bool
    ) -> CGFloat {
        if reduceMotion && usesCrossfade { return 0 }
        return max(0, configured)
    }

    /// Maps the older title peek direction to the title layout model.
    nonisolated static func titleLayout(for direction: PaginationPeekDirection) -> TitledPageTitleLayout {
        switch direction {
        case .bidirectional: return .bidirectional
        case .unidirectional: return .leading
        case .none: return .center
        }
    }

    /// Resolves a public title alignment into the internal title layout.
    nonisolated static func titleLayout(
        for alignment: TitledPageTitleAlignment,
        fallbackDirection: PaginationPeekDirection
    ) -> TitledPageTitleLayout? {
        switch alignment {
        case .automatic:
            return titleLayout(for: fallbackDirection)
        case .leading:
            return .leading
        case .trailing:
            return .trailing
        case .center:
            return .center
        case .hidden:
            return nil
        }
    }

    // MARK: - Selection / paging helpers

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
    /// header, indicator, and paged-content subviews.
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
