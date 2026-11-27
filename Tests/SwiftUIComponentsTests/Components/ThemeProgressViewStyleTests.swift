import DesignSystem
import Foundation
import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("ThemeProgressViewStyle")
struct ThemeProgressViewStyleTests {

    @Test("clamps out-of-range and non-finite fractions")
    func clampsFractions() {
        #expect(ThemeProgressMetrics.clamped(-0.5) == 0)
        #expect(ThemeProgressMetrics.clamped(0.25) == 0.25)
        #expect(ThemeProgressMetrics.clamped(1.5) == 1)
        #expect(ThemeProgressMetrics.clamped(.nan) == 0)
    }

    @Test("indeterminate segment starts off the leading edge and ends past the trailing edge")
    func sweepOffsetSpansTrack() {
        #expect(ThemeProgressMetrics.sweepOffset(trackWidth: 100, phase: 0) == -30)
        #expect(ThemeProgressMetrics.sweepOffset(trackWidth: 100, phase: 1) == 100)
    }

    @Test("sweep phase stays within one period")
    func phaseIsBounded() {
        let phase = ThemeProgressMetrics.phase(at: Date(timeIntervalSinceReferenceDate: 12_345.6))
        #expect(phase >= 0)
        #expect(phase < 1)
    }

    @Test(arguments: [ColorScheme.light, ColorScheme.dark])
    func progressTrackUsesTheThickStrokeInsteadOfSpacing(colorScheme: ColorScheme) {
        let stroke = DefaultStroke(thick: 7)
        let progress = ProgressView(value: 0.5)
            .progressViewStyle(ThemeProgressViewStyle())
            .designTheme(DefaultTheme(spacing: DefaultSpacing(halfUnit: 12), stroke: stroke))
            .environment(\.colorScheme, colorScheme)
        let renderer = ImageRenderer(content: progress)
        renderer.proposedSize = ProposedViewSize(width: 160, height: nil)

        var height: CGFloat?
        renderer.render { size, _ in height = size.height }
        #expect(height == stroke.thick)
    }

    @Test("renders determinate, labelled, and indeterminate progress")
    func rendersVariants() {
        renderForCoverage(
            VStack {
                ProgressView(value: 0.4)
                ProgressView("Uploading", value: 2, total: 4)
                ProgressView(value: 0.75) {
                    Text("Syncing")
                } currentValueLabel: {
                    Text("3 of 4")
                }
                ProgressView()
            }
            .progressViewStyle(ThemeProgressViewStyle())
        )
        renderForCoverage(ProgressView(value: 0.5).progressViewStyle(ThemeProgressViewStyle(tint: .green)))
    }
}
