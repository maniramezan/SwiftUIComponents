import DesignSystem
import SwiftUI

/// A linear progress style drawn from the active design theme: a capsule track in
/// `containerSecondary` with a fill in `primary` (or a caller-supplied tint).
///
/// Determinate progress fills proportionally and animates between values with the
/// theme's motion tokens. Indeterminate progress (`fractionCompleted == nil`) sweeps a
/// short segment across the track, and holds it still under Reduce Motion. A
/// `ProgressView` label is shown above the track and a current-value label below it.
///
/// ```swift
/// ProgressView("Uploading", value: uploaded, total: size)
///     .progressViewStyle(ThemeProgressViewStyle())
///
/// ProgressView()      // indeterminate
///     .progressViewStyle(ThemeProgressViewStyle(tint: theme.colors.success))
/// ```
///
/// VoiceOver reads the label together with the completed percentage.
public struct ThemeProgressViewStyle: ProgressViewStyle {
    private let tint: Color?

    /// Creates a themed linear progress style.
    ///
    /// - Parameter tint: The fill color. When `nil` (the default), the theme's
    ///   `colors.primary` is used.
    public init(tint: Color? = nil) {
        self.tint = tint
    }

    /// Builds the themed track, fill, and labels for a `ProgressView`.
    ///
    /// - Parameter configuration: The progress value and labels supplied by the `ProgressView`.
    public func makeBody(configuration: Configuration) -> some View {
        ThemeProgressBar(
            fractionCompleted: configuration.fractionCompleted,
            tint: tint,
            label: configuration.label,
            currentValueLabel: configuration.currentValueLabel
        )
    }
}

// MARK: - Implementation

/// Labels stacked around a ``ThemeProgressTrack``.
private struct ThemeProgressBar: View {
    let fractionCompleted: Double?
    let tint: Color?
    let label: ProgressViewStyleConfiguration.Label?
    let currentValueLabel: ProgressViewStyleConfiguration.CurrentValueLabel?

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
            if let label {
                label
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.textPrimary)
            }
            ThemeProgressTrack(
                fractionCompleted: fractionCompleted.map(ThemeProgressMetrics.clamped),
                tint: tint ?? theme.colors.primary
            )
            if let currentValueLabel {
                currentValueLabel
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .accessibilityElement(children: .combine)
        .accessibilityValue(valueText)
    }

    /// The spoken value: a rounded percentage, or "Loading" while indeterminate.
    private var valueText: Text {
        guard let fractionCompleted else { return Text(Strings.Button.loading) }
        return Text(ThemeProgressMetrics.clamped(fractionCompleted), format: .percent.precision(.fractionLength(0)))
    }
}

/// The capsule track and its determinate fill or indeterminate sweep.
private struct ThemeProgressTrack: View {
    let fractionCompleted: Double?
    let tint: Color

    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        GeometryReader { proxy in
            let width = proxy.size.width
            ZStack(alignment: .leading) {
                Capsule(style: .continuous)
                    .fill(theme.colors.containerSecondary)
                if let fractionCompleted {
                    Capsule(style: .continuous)
                        .fill(tint)
                        .frame(width: width * CGFloat(fractionCompleted))
                        .animation(theme.motion.animation(reducingMotion: reduceMotion), value: fractionCompleted)
                } else if reduceMotion {
                    Capsule(style: .continuous)
                        .fill(tint)
                        .frame(width: width * ThemeProgressMetrics.sweepWidthFraction)
                } else {
                    TimelineView(.animation) { context in
                        Capsule(style: .continuous)
                            .fill(tint)
                            .frame(width: width * ThemeProgressMetrics.sweepWidthFraction)
                            .offset(
                                x: ThemeProgressMetrics.sweepOffset(
                                    trackWidth: width,
                                    phase: ThemeProgressMetrics.phase(at: context.date)
                                )
                            )
                    }
                }
            }
            .clipShape(Capsule(style: .continuous))
        }
        .frame(height: theme.spacing.halfUnit)
    }
}

/// Pure geometry for ``ThemeProgressViewStyle``, kept separate for unit testing.
enum ThemeProgressMetrics {
    /// One full indeterminate sweep, in seconds.
    static let sweepPeriod: TimeInterval = 1.4
    /// Width of the indeterminate segment relative to the track.
    static let sweepWidthFraction: CGFloat = 0.3

    /// Clamps a reported fraction into `0...1`, treating NaN as `0`.
    nonisolated static func clamped(_ fraction: Double) -> Double {
        guard fraction.isFinite else { return 0 }
        return min(max(fraction, 0), 1)
    }

    /// Progress through the current sweep, in `0..<1`.
    nonisolated static func phase(at date: Date) -> CGFloat {
        CGFloat(date.timeIntervalSinceReferenceDate.truncatingRemainder(dividingBy: sweepPeriod) / sweepPeriod)
    }

    /// Leading offset of the indeterminate segment: fully off the leading edge at phase
    /// `0`, fully past the trailing edge at phase `1`.
    nonisolated static func sweepOffset(trackWidth: CGFloat, phase: CGFloat) -> CGFloat {
        let segment = trackWidth * sweepWidthFraction
        return -segment + (trackWidth + segment) * phase
    }
}

#Preview("Theme progress") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.threeUnits) {
            ProgressView("Uploading", value: 0.4)
            ProgressView(value: 0.75) {
                Text("Syncing")
            } currentValueLabel: {
                Text("3 of 4")
            }
            ProgressView()
        }
        .progressViewStyle(ThemeProgressViewStyle())
        .padding(theme.spacing.twoUnits)
    }
}
