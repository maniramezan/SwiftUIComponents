import SwiftUI

/// The center angle, maximum deviation, and timing of one spatial orbit tilt.
///
/// Use separate values for ``SphereOrbitMotion`` pitch and roll. A zero amplitude fixes
/// the angle at `center`. Explicit cycle durations are independent of satellite speed.
///
/// ```swift
/// let pitch = SphereOrbitTilt(
///     center: .degrees(-35), amplitude: .degrees(20), cycleDuration: 24
/// )
/// ```
public struct SphereOrbitTilt: Sendable, Hashable {
    /// The angle around which this tilt oscillates.
    public let center: Angle

    /// The maximum angular deviation on either side of ``center``.
    public let amplitude: Angle

    /// Seconds for a complete oscillation, or `nil` to follow satellite revolution timing.
    ///
    /// With `nil`, pitch takes `revolutionDuration / 0.37` seconds and roll takes
    /// `revolutionDuration / 0.23` seconds per cycle.
    public let cycleDuration: TimeInterval?

    /// The original pitch: a center of −0.65 radians and an amplitude of 0.30 radians.
    public static let defaultPitch = SphereOrbitTilt(center: .radians(-0.65), amplitude: .radians(0.30))

    /// The original roll: a center of zero and an amplitude of 0.50 radians.
    public static let defaultRoll = SphereOrbitTilt(center: .zero, amplitude: .radians(0.50))

    /// Creates a sinusoidal tilt, starting at its center and moving toward its positive limit.
    ///
    /// - Parameters:
    ///   - center: A finite center angle. Nonfinite angles log a fault and use zero.
    ///   - amplitude: A finite, nonnegative maximum deviation. Zero disables oscillation.
    ///     Invalid values log a fault and use zero.
    ///   - cycleDuration: Positive, finite seconds per oscillation. `nil` follows satellite timing
    ///     at the pitch or roll rate. Invalid values log a fault and use `nil`.
    public init(center: Angle = .zero, amplitude: Angle = .zero, cycleDuration: TimeInterval? = nil) {
        if center.radians.isFinite {
            self.center = center
        } else {
            SphereOrbitGeometry.logger.fault("Invalid orbit tilt center; using zero")
            self.center = .zero
        }
        if amplitude.radians.isFinite, amplitude.radians >= 0 {
            self.amplitude = amplitude
        } else {
            SphereOrbitGeometry.logger.fault("Invalid orbit tilt amplitude; using zero")
            self.amplitude = .zero
        }
        if let cycleDuration, !cycleDuration.isFinite || cycleDuration <= 0 {
            SphereOrbitGeometry.logger.fault("Invalid orbit tilt cycle duration; using revolution timing")
            self.cycleDuration = nil
        } else {
            self.cycleDuration = cycleDuration
        }
    }
}
