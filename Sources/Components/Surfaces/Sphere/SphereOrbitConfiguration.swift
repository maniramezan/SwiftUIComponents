import SwiftUI

/// Reusable placement and guide settings for ``OrbitingSphere``.
///
/// Apply with `sphereOrbitConfiguration(_:)`. Size the canvas with SwiftUI's `frame` modifiers.
/// Item models and content remain inputs to the orbit's initializer.
public struct SphereOrbitConfiguration: Sendable, Hashable {
    /// Flat ring or spatial projection. Defaults to `.spatial`.
    public var style: SphereOrbitStyle

    /// Orbit radius in points. `nil` uses 38% of the canvas's shorter side for a ring or 30% for spatial.
    /// Invalid values log a fault and use that default. Content is not clipped to the canvas.
    public var radius: CGFloat?

    /// Starting satellite angle. Defaults to the top of the orbit; nonfinite values log a fault and use that angle.
    public var phase: Angle

    /// Whether to draw the decorative orbit guide. Defaults to `true`.
    public var showsOrbit: Bool

    /// Creates placement settings; omitted values retain the themed radius and default projection.
    ///
    /// - Parameters:
    ///   - style: The projection used to place satellites.
    ///   - radius: Optional radius override; `nil` scales with the available canvas.
    ///   - phase: Starting angle, defaulting to −90 degrees.
    ///   - showsOrbit: Whether the decorative guide is visible.
    public init(
        style: SphereOrbitStyle = .spatial,
        radius: CGFloat? = nil,
        phase: Angle = .degrees(-90),
        showsOrbit: Bool = true
    ) {
        self.style = style
        self.radius = radius
        self.phase = phase
        self.showsOrbit = showsOrbit
    }
}
