import Foundation

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
}
