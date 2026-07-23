import DesignSystem
import SwiftUI

/// Internal indicator drawn below the page content of `TitledPageView`.
///
/// Renders one of ``PaginationIndicatorStyle``'s visual treatments and
/// exposes a single AX-adjustable element to assistive technologies.
struct TitledPageViewIndicator: View {

    /// Snapshot of the merged theme + style overrides.
    let resolved: ResolvedPaginationStyle

    /// Indicator style requested by the caller.
    let style: PaginationIndicatorStyle

    /// Number of pages to represent.
    let count: Int

    /// Snapped index of the currently-active page.
    let activeIndex: Int

    /// Continuous progress (0…count-1). Used by `.bar` to scrub smoothly.
    let progress: CGFloat

    /// Display title of the current page, surfaced to VoiceOver.
    let currentTitle: String

    /// Invoked when the user taps a dot to jump to a specific page.
    let onJump: (Int) -> Void

    /// Invoked by the AX-adjustable action with a signed step (+1 / -1).
    let onAdjustableStep: (Int) -> Void

    /// Minimum hit-target diameter for indicator buttons, sourced from theme.
    let minimumHitTarget: CGFloat

    var body: some View {
        Group {
            switch style {
            case .dots:
                TitledPageViewDotsIndicator(
                    resolved: resolved,
                    count: count,
                    activeIndex: activeIndex,
                    minimumHitTarget: minimumHitTarget,
                    onJump: onJump
                )
            case .bar:
                TitledPageViewBarIndicator(
                    resolved: resolved,
                    count: count,
                    progress: progress,
                    minimumHitTarget: minimumHitTarget
                )
            case .hidden:
                EmptyView()
            }
        }
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text(Strings.Pagination.indicatorLabel))
        .accessibilityValue(
            Text(Strings.Pagination.pageOfTotal(max(1, activeIndex + 1), max(1, count), currentTitle))
        )
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment: onAdjustableStep(+1)
            case .decrement: onAdjustableStep(-1)
            default: break
            }
        }
    }
}

// MARK: - Dots

/// A row of tappable dots, one per page, used by ``TitledPageViewIndicator``
/// for ``PaginationIndicatorStyle/dots``.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the bar variant.
private struct TitledPageViewDotsIndicator: View {
    let resolved: ResolvedPaginationStyle
    let count: Int
    let activeIndex: Int
    let minimumHitTarget: CGFloat
    let onJump: (Int) -> Void

    @Environment(\.designTheme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.halfUnit) {
            ForEach(0..<count, id: \.self) { index in
                Button {
                    onJump(index)
                } label: {
                    Circle()
                        .fill(
                            index == activeIndex
                                ? resolved.indicatorActiveColor
                                : resolved.indicatorInactiveColor
                        )
                        .frame(width: theme.spacing.oneUnit, height: theme.spacing.oneUnit)
                        .frame(width: minimumHitTarget, height: minimumHitTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Bar

/// A scrubbing progress bar used by ``TitledPageViewIndicator`` for
/// ``PaginationIndicatorStyle/bar``.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the dots variant.
private struct TitledPageViewBarIndicator: View {
    let resolved: ResolvedPaginationStyle
    let count: Int
    let progress: CGFloat
    let minimumHitTarget: CGFloat

    @Environment(\.designTheme) private var theme

    // No spacing/stroke token matches 3pt exactly (`stroke.regular` is 2pt,
    // `stroke.thick` is 4pt); changing this to the nearest token would
    // visibly thicken or thin the bar, so it stays a documented literal.
    private var barThickness: CGFloat { 3 }

    var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let segmentWidth = count > 0 ? totalWidth / CGFloat(count) : totalWidth
            let clamped = min(max(progress, 0), CGFloat(max(0, count - 1)))
            let thumbX = clamped * segmentWidth

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(resolved.indicatorInactiveColor)
                    .frame(height: barThickness)

                Capsule()
                    .fill(resolved.indicatorActiveColor)
                    .frame(width: max(segmentWidth, theme.spacing.threeUnits), height: barThickness)
                    .offset(x: thumbX)
            }
            .frame(height: minimumHitTarget, alignment: .center)
        }
        .frame(height: minimumHitTarget)
    }
}

// MARK: - Previews

@MainActor
private func indicatorPreviewStyle(theme: any Theme) -> ResolvedPaginationStyle {
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

#Preview("Dots") {
    PreviewContent { theme in
        TitledPageViewIndicator(
            resolved: indicatorPreviewStyle(theme: theme),
            style: .dots,
            count: 4,
            activeIndex: 1,
            progress: 1,
            currentTitle: "Spotlight: Health",
            onJump: { _ in },
            onAdjustableStep: { _ in },
            minimumHitTarget: theme.motion.minimumHitTarget
        )
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Bar") {
    PreviewContent { theme in
        TitledPageViewIndicator(
            resolved: indicatorPreviewStyle(theme: theme),
            style: .bar,
            count: 4,
            activeIndex: 1,
            progress: 1,
            currentTitle: "Spotlight: Health",
            onJump: { _ in },
            onAdjustableStep: { _ in },
            minimumHitTarget: theme.motion.minimumHitTarget
        )
        .padding(.horizontal, theme.spacing.twoUnits)
    }
}
