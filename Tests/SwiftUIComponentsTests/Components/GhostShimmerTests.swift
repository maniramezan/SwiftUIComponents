import Foundation
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
}
