import Foundation
import SwiftUI

/// The parameters of an interactive spring animation.
///
/// A `MotionSpring` carries the *parameters* rather than a pre-built `Animation`, which keeps it a plain
/// `Sendable`/`Equatable` value that can be stored on a token type, compared in tests, and scaled
/// by a theme. Call ``animation`` at the point of use to materialize the `Animation`.
///
/// Use these tokens for gesture-driven transitions. For simple state changes, use
/// ``Motion/animation(reducingMotion:)``. Spring animations can also animate noninteractive changes.
///
/// - Important: ``animation`` does not consult the system Reduce Motion setting. Read
///   `accessibilityReduceMotion` from the environment and suppress the spring when it is enabled.
public struct MotionSpring: Hashable, Sendable {
    /// The approximate duration of one undamped oscillation, in seconds.
    ///
    /// Larger values feel slower; the spring is not guaranteed to be at rest after
    /// this interval.
    public var response: TimeInterval

    /// How much the spring resists overshooting.
    ///
    /// `1` settles without overshooting, values below `1` bounce past the target, and values above
    /// `1` are overdamped and approach the target without oscillation.
    public var dampingFraction: Double

    /// Duration over which response values blend between successive spring animations.
    ///
    /// Successive springs on the same property preserve velocity independently of this value.
    public var blendDuration: TimeInterval

    /// Creates parameters forwarded to `Animation.interactiveSpring`.
    ///
    /// - Parameters:
    ///   - response: Approximate duration of one undamped oscillation, in seconds.
    ///   - dampingFraction: Damping relative to critical damping; `1` is critically damped.
    ///   - blendDuration: Time in seconds used to blend response values between successive springs.
    public init(response: TimeInterval, dampingFraction: Double, blendDuration: TimeInterval) {
        self.response = response
        self.dampingFraction = dampingFraction
        self.blendDuration = blendDuration
    }

    /// The `interactiveSpring` animation these parameters describe.
    ///
    /// Suppress this animation when the system Reduce Motion setting is enabled.
    public var animation: Animation {
        .interactiveSpring(
            response: response,
            dampingFraction: dampingFraction,
            blendDuration: blendDuration
        )
    }
}

extension MotionSpring {
    /// Spring that commits a gesture-driven page transition.
    ///
    /// Snappy with a small overshoot, so a page change reads as responsive rather than instant.
    public static let paging = MotionSpring(response: 0.32, dampingFraction: 0.88, blendDuration: 0.12)

    /// Spring that returns content to rest after a gesture ends without committing.
    ///
    /// Faster and more damped than ``paging``: a cancelled gesture is not a navigation, so it
    /// should not draw attention to itself.
    public static let snapBack = MotionSpring(response: 0.24, dampingFraction: 0.9, blendDuration: 0.08)
}
