import SwiftUI

/// Reusable revolution, tilt, and collection transition settings for ``OrbitingSphere``.
///
/// Apply with `sphereOrbitMotion(_:)`. Pause continuous motion with `sphereOrbitPaused(_:)`;
/// collection transitions remain independent. Accessibility and scene state can also pause motion.
public struct SphereOrbitMotion: Sendable, Hashable {
    /// Whether continuous revolution and tilt are paused, preserving elapsed time. Defaults to `false`.
    public var isPaused: Bool

    /// Seconds per revolution. `nil` uses `theme.motion.orbitalRevolutionDuration`.
    /// Nonpositive or nonfinite values log a fault and use that token.
    public var revolutionDuration: TimeInterval?

    /// Spatial up/down tilt range and timing. Defaults to ``SphereOrbitTilt/defaultPitch``; ignored for a ring.
    public var pitch: SphereOrbitTilt

    /// Spatial in-plane tilt range and timing. Defaults to ``SphereOrbitTilt/defaultRoll``; ignored for a ring.
    public var roll: SphereOrbitTilt

    /// Whether insertion, removal, and redistribution animate. Defaults to `true`, even while paused.
    /// Timing uses `theme.motion.animation(reducingMotion:)`; Reduce Motion uses fades and immediate spacing.
    public var animatesChanges: Bool

    /// The default continuous revolution, tilt, and animated collection changes.
    public static let continuous = SphereOrbitMotion()

    /// Stationary satellites with animated collection changes, suitable for interactive controls.
    public static let paused = SphereOrbitMotion(isPaused: true)

    /// Creates motion settings with theme-derived revolution timing by default.
    ///
    /// - Parameters:
    ///   - isPaused: Whether to pause revolution and tilt without resetting elapsed time.
    ///   - revolutionDuration: Optional positive, finite seconds per revolution; `nil` resolves from the theme.
    ///   - pitch: Up/down tilt of the spatial plane.
    ///   - roll: In-plane tilt of the spatial plane.
    ///   - animatesChanges: Whether collection changes animate independently of continuous motion.
    public init(
        isPaused: Bool = false,
        revolutionDuration: TimeInterval? = nil,
        pitch: SphereOrbitTilt = .defaultPitch,
        roll: SphereOrbitTilt = .defaultRoll,
        animatesChanges: Bool = true
    ) {
        self.isPaused = isPaused
        self.revolutionDuration = revolutionDuration
        self.pitch = pitch
        self.roll = roll
        self.animatesChanges = animatesChanges
    }
}
