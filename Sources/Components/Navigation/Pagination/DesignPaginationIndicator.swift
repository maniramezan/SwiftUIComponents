import DesignSystem
import SwiftUI

/// Internal indicator drawn below the page content of `DesignPagedView`.
///
/// Renders one of ``DesignPaginationIndicatorStyle``'s visual treatments and
/// exposes a single AX-adjustable element to assistive technologies.
struct DesignPaginationIndicator: View {

    /// Snapshot of the merged theme + style overrides.
    let resolved: ResolvedPaginationStyle

    /// Indicator style requested by the caller.
    let style: DesignPaginationIndicatorStyle

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

private let _indicatorPreviewStyle = ResolvedPaginationStyle(
    titleFont: .title2,
    titleColor: .primary,
    adjacentTitleColor: .secondary,
    background: nil,
    indicatorActiveColor: .blue,
    indicatorInactiveColor: Color(white: 0.85),
    peekDirection: .bidirectional,
    peekWidth: 40,
    headerSpacing: 16,
    titleGap: 16,
    reduceMotionUsesCrossfade: true
)

#Preview("Dots") {
    DesignPaginationIndicator(
        resolved: _indicatorPreviewStyle,
        style: .dots,
        count: 4,
        activeIndex: 1,
        progress: 1,
        currentTitle: "Spotlight: Health",
        onJump: { _ in },
        onAdjustableStep: { _ in },
        minimumHitTarget: 44
    )
    .padding()
}

#Preview("Bar") {
    DesignPaginationIndicator(
        resolved: _indicatorPreviewStyle,
        style: .bar,
        count: 4,
        activeIndex: 1,
        progress: 1,
        currentTitle: "Spotlight: Health",
        onJump: { _ in },
        onAdjustableStep: { _ in },
        minimumHitTarget: 44
    )
    .padding(.horizontal)
}
