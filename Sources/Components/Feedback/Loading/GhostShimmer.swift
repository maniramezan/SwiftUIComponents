import DesignSystem
import SwiftUI

extension View {
    /// Sweeps a soft highlight band across skeleton content so loading placeholders read
    /// as in-progress rather than frozen.
    ///
    /// Apply once at the root of a skeleton layout rather than to each block. The highlight
    /// is masked to the content's own silhouette, and the sweep phase is derived from the
    /// wall clock rather than per-view animation state, so every shimmering section on
    /// screen moves in lockstep as a single band crossing the whole layout.
    ///
    /// ```swift
    /// VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
    ///     GhostLoadingBlock(width: 160, height: 16)
    ///     GhostLoadingBlock(height: 88)
    /// }
    /// .designGhostShimmer()
    /// ```
    ///
    /// Renders the static skeleton unchanged when Reduce Motion is on, and is inert for
    /// accessibility: the band never hit-tests and is hidden from assistive technology.
    public func designGhostShimmer() -> some View {
        modifier(GhostShimmerModifier())
    }
}

extension EnvironmentValues {
    /// Forces the static, non-animating skeleton, bypassing the sweep entirely.
    ///
    /// Set `.environment(\.isGhostShimmerDisabled, true)` for deterministic snapshot
    /// testing: the sweep phase derives from the wall clock, so a capture's exact pixels
    /// otherwise depend on the instant the test happens to run.
    @Entry public var isGhostShimmerDisabled: Bool = false
}

// MARK: - Implementation

private struct GhostShimmerModifier: ViewModifier {
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.isGhostShimmerDisabled) private var isDisabled
    @Environment(\.designTheme) private var theme

    func body(content: Content) -> some View {
        content
            .overlay {
                if !reduceMotion && !isDisabled {
                    GeometryReader { geometry in
                        TimelineView(.animation) { context in
                            GhostShimmerHighlightBand(
                                highlight: theme.colors.shimmerHighlight,
                                containerWidth: geometry.size.width,
                                phase: GhostShimmerMetrics.phase(at: context.date)
                            )
                        }
                    }
                    .mask(content)
                    .allowsHitTesting(false)
                    .accessibilityHidden(true)
                }
            }
    }
}

struct GhostShimmerHighlightBand: View {
    let highlight: Color
    let containerWidth: CGFloat
    let phase: CGFloat

    var body: some View {
        LinearGradient(
            colors: [.clear, highlight, .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(width: GhostShimmerMetrics.bandWidth(containerWidth: containerWidth))
        .offset(x: GhostShimmerMetrics.offset(containerWidth: containerWidth, phase: phase))
    }
}

enum GhostShimmerMetrics {
    /// Full cycle length: one sweep plus an off-screen rest.
    static let period: TimeInterval = 1.8
    /// Portion of the period spent sweeping; the remainder is idle.
    static let sweepFraction: Double = 0.65
    /// Highlight band width relative to the container width.
    static let bandWidthFraction: CGFloat = 0.45

    /// Progress of the current sweep in `0...1`.
    ///
    /// The band crosses the container during the first ``sweepFraction`` of each period and
    /// rests off-screen for the remainder, which is what produces the familiar pause
    /// between sweeps rather than a continuously travelling band.
    static func phase(at date: Date) -> CGFloat {
        let elapsed = date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: period)
        let cycle = elapsed / period
        return CGFloat(min(cycle / sweepFraction, 1))
    }

    /// Width of the highlight band for a container of the given width.
    static func bandWidth(containerWidth: CGFloat) -> CGFloat {
        containerWidth * bandWidthFraction
    }

    /// Leading offset of the highlight band for a sweep `phase` in `0...1`.
    ///
    /// At phase `0` the band sits fully off the leading edge; at phase `1` it has cleared
    /// the trailing edge, so the visible sweep spans exactly one container width plus the
    /// band on either side.
    static func offset(containerWidth: CGFloat, phase: CGFloat) -> CGFloat {
        let band = bandWidth(containerWidth: containerWidth)
        return -band + (containerWidth + 2 * band) * phase
    }
}

#Preview("Ghost shimmer") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            GhostLoadingBlock(width: 240, height: theme.spacing.twoUnits)
            GhostLoadingBlock(height: theme.spacing.sixUnits + theme.spacing.fiveUnits)
            GhostLoadingBlock(width: 160, height: theme.spacing.twoUnits)
        }
        .padding(theme.spacing.twoUnits)
        .designGhostShimmer()
    }
}
