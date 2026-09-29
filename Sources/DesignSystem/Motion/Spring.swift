import Foundation
import SwiftUI

/// The parameters of an interactive spring animation.
///
/// A `Spring` carries the *parameters* rather than a pre-built `Animation`, which keeps it a plain
/// `Sendable`/`Equatable` value that can be stored on a token type, compared in tests, and scaled
/// by a theme. Call ``animation`` at the point of use to materialize the `Animation`.
///
/// - Note: Only springs meant to track a *gesture* belong here. Time-based motion (fades, standard
///   state changes) is expressed as a duration on ``Motion/standardAnimation`` instead — a spring
///   is the wrong tool when there is no interactive velocity to carry.
public struct Spring: Hashable, Sendable {
    /// Approximate time the spring takes to settle.
    ///
    /// Larger values feel slower and heavier; the spring is not guaranteed to be at rest after
    /// this interval.
    public var response: TimeInterval

    /// How much the spring resists overshooting.
    ///
    /// `1` settles without overshooting, values below `1` bounce past the target, and values above
    /// `1` approach it critically damped.
    public var dampingFraction: Double

    /// Duration over which the spring's initial velocity blends into the animation.
    ///
    /// A non-zero value stops a spring that inherits a fast gesture from looking like a jump cut.
    public var blendDuration: TimeInterval

    /// Creates spring parameters.
    public init(response: TimeInterval, dampingFraction: Double, blendDuration: TimeInterval) {
        self.response = response
        self.dampingFraction = dampingFraction
        self.blendDuration = blendDuration
    }

    /// The `interactiveSpring` animation these parameters describe.
    public var animation: Animation {
        .interactiveSpring(
            response: response,
            dampingFraction: dampingFraction,
            blendDuration: blendDuration
        )
    }
}

extension Spring {
    /// Spring that commits a gesture-driven page transition.
    ///
    /// Snappy with a small overshoot, so a page change reads as responsive rather than instant.
    public static let paging = Spring(response: 0.32, dampingFraction: 0.88, blendDuration: 0.12)

    /// Spring that returns content to rest after a gesture ends without committing.
    ///
    /// Faster and more damped than ``paging``: a cancelled gesture is not a navigation, so it
    /// should not draw attention to itself.
    public static let snapBack = Spring(response: 0.24, dampingFraction: 0.9, blendDuration: 0.08)
}
