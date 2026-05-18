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
                dotsBody
            case .bar:
                barBody
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

    // MARK: - Dots

    private var dotsBody: some View {
        HStack(spacing: dotSpacing) {
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
                        .frame(width: dotDiameter, height: dotDiameter)
                        .frame(width: minimumHitTarget, height: minimumHitTarget)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .accessibilityHidden(true)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var dotDiameter: CGFloat { 8 }
    private var dotSpacing: CGFloat { 4 }

    // MARK: - Bar

    private var barBody: some View {
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
                    .frame(width: max(segmentWidth, minimumThumbWidth), height: barThickness)
                    .offset(x: thumbX)
            }
            .frame(height: minimumHitTarget, alignment: .center)
        }
        .frame(height: minimumHitTarget)
    }

    private var barThickness: CGFloat { 3 }
    private var minimumThumbWidth: CGFloat { 24 }
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
