import SwiftUI

extension EnvironmentValues {
    @Entry var sphereOrbitConfiguration = SphereOrbitConfiguration()
    @Entry var sphereOrbitMotion = SphereOrbitMotion.continuous
}

public extension View {
    /// Sets reusable placement and guide settings for orbits in this hierarchy.
    ///
    /// The nearest configuration wins. Use `sphereOrbitStyle(_:)` to override only the projection,
    /// and SwiftUI's `frame` modifiers to size each canvas.
    /// - Parameter configuration: Placement settings; a `nil` radius scales with the available canvas.
    func sphereOrbitConfiguration(_ configuration: SphereOrbitConfiguration) -> some View {
        environment(\.sphereOrbitConfiguration, configuration)
    }

    /// Sets revolution, tilt, and collection transition settings for orbits in this hierarchy.
    ///
    /// The nearest motion settings win. Reduce Motion, VoiceOver, and inactive scenes pause
    /// continuous motion regardless of the requested settings.
    /// - Parameter motion: Reusable settings, such as `.continuous` or `.paused`.
    func sphereOrbitMotion(_ motion: SphereOrbitMotion) -> some View {
        environment(\.sphereOrbitMotion, motion)
    }

    /// Overrides only the projection of orbits in this hierarchy, preserving other inherited settings.
    /// - Parameter style: A flat `.ring` for controls or a tilting `.spatial` projection.
    func sphereOrbitStyle(_ style: SphereOrbitStyle) -> some View {
        transformEnvironment(\.sphereOrbitConfiguration) { configuration in
            configuration.style = style
        }
    }

    /// Pauses revolution and tilt for orbits in this hierarchy without changing collection transitions.
    ///
    /// Resuming preserves elapsed time. This overrides only `isPaused` in the inherited motion settings.
    /// - Parameter paused: Whether to pause continuous motion. Defaults to `true`.
    func sphereOrbitPaused(_ paused: Bool = true) -> some View {
        transformEnvironment(\.sphereOrbitMotion) { motion in
            motion.isPaused = paused
        }
    }
}
