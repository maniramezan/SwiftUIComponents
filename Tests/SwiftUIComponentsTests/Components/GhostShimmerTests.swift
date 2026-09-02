import DesignSystem
import Foundation
import SwiftUI
import Testing

@testable import Components

@Suite("Ghost shimmer timing")
struct GhostShimmerTests {

    /// The band must finish its crossing partway through the period and then rest, which is
    /// what produces the pause between sweeps rather than a continuously travelling band.
    @Test func phaseCompletesEarlyThenRests() {
        let start = Date(timeIntervalSinceReferenceDate: 0)
        let sweepEnd = Date(
            timeIntervalSinceReferenceDate: GhostShimmerMetrics.period
                * GhostShimmerMetrics.sweepFraction
        )
        let periodEnd = Date(
            timeIntervalSinceReferenceDate: GhostShimmerMetrics.period * 0.999
        )

        #expect(GhostShimmerMetrics.phase(at: start) == 0)
        #expect(GhostShimmerMetrics.phase(at: sweepEnd) == 1)
        #expect(GhostShimmerMetrics.phase(at: periodEnd) == 1)
    }

    /// Phase is a pure function of the wall clock, so every shimmering section on screen
    /// resolves to the same offset and they sweep as one band.
    @Test func phaseIsIdenticalAcrossPeriods() {
        let first = Date(timeIntervalSinceReferenceDate: GhostShimmerMetrics.period * 0.25)
        let later = Date(timeIntervalSinceReferenceDate: GhostShimmerMetrics.period * 5.25)

        // Compared with a tolerance: the phase is computed from an absolute time interval,
        // so the same point in a later period accumulates floating-point drift.
        let drift = abs(
            GhostShimmerMetrics.phase(at: first) - GhostShimmerMetrics.phase(at: later)
        )
        #expect(drift < 0.0001)
    }

    /// The band spans a fixed fraction of the container so the sweep reads the same at any
    /// width.
    @Test func bandWidthIsAFractionOfTheContainer() {
        #expect(GhostShimmerMetrics.bandWidth(containerWidth: 200) == 200 * GhostShimmerMetrics.bandWidthFraction)
        #expect(GhostShimmerMetrics.bandWidth(containerWidth: 0) == 0)
    }

    /// At phase 0 the band sits fully off the leading edge; at phase 1 it has cleared the
    /// trailing edge by its own width.
    @Test func offsetSweepsFromOffscreenToOffscreen() {
        let width: CGFloat = 300
        let band = GhostShimmerMetrics.bandWidth(containerWidth: width)

        #expect(GhostShimmerMetrics.offset(containerWidth: width, phase: 0) == -band)
        #expect(GhostShimmerMetrics.offset(containerWidth: width, phase: 1) == width + band)
    }

    /// Renders `GhostShimmerHighlightBand` directly — the gradient, frame, and offset run
    /// even offscreen, unlike the `TimelineView` that drives it in the modifier.
    @Test @MainActor func highlightBandRenders() {
        renderForCoverage(
            GhostShimmerHighlightBand(highlight: .white, containerWidth: 320, phase: 0.5)
        )
    }

    /// Exercises the animating path: the masked highlight band and its gradient are built
    /// only when Reduce Motion is off and the sweep is not force-disabled.
    @Test @MainActor func rendersAnimatingSweep() {
        renderForCoverage(
            skeleton
                .designGhostShimmer()
                .designTheme(DefaultTheme())
        )
    }

    /// Exercises the static path: `\.isGhostShimmerDisabled` (the same gate Reduce Motion
    /// trips) skips the band entirely so a snapshot never captures a clock-dependent frame.
    @Test @MainActor func rendersStaticWhenDisabled() {
        renderForCoverage(
            skeleton
                .designGhostShimmer()
                .environment(\.isGhostShimmerDisabled, true)
                .designTheme(DefaultTheme())
        )
    }

    @MainActor private var skeleton: some View {
        VStack(alignment: .leading, spacing: 8) {
            GhostLoadingBlock(width: 160, height: 16)
            GhostLoadingBlock(height: 88)
        }
        .padding()
    }
}
