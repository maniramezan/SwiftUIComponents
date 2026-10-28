import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("Sphere orbit modifiers")
struct SphereOrbitModifiersTests {
    @Test("Configuration modifiers propagate through containers and allow local overrides")
    func hierarchyOverrides() throws {
        let sharedConfiguration = SphereOrbitConfiguration(radius: 72, phase: .degrees(30), showsOrbit: false)
        let sharedMotion = SphereOrbitMotion(revolutionDuration: 24, animatesChanges: false)
        var inherited: (SphereOrbitConfiguration, SphereOrbitMotion)?
        var overridden: (SphereOrbitConfiguration, SphereOrbitMotion)?

        renderForCoverage(
            VStack {
                OrbitEnvironmentProbe { inherited = ($0, $1) }
                OrbitEnvironmentProbe { overridden = ($0, $1) }
                    .sphereOrbitStyle(.ring)
                    .sphereOrbitPaused()
            }
            .sphereOrbitConfiguration(sharedConfiguration)
            .sphereOrbitMotion(sharedMotion)
        )

        let inheritedValues = try #require(inherited)
        #expect(inheritedValues.0 == sharedConfiguration)
        #expect(inheritedValues.1 == sharedMotion)
        let overriddenValues = try #require(overridden)
        var expectedConfiguration = sharedConfiguration
        expectedConfiguration.style = .ring
        var expectedMotion = sharedMotion
        expectedMotion.isPaused = true
        #expect(overriddenValues.0 == expectedConfiguration)
        #expect(overriddenValues.1 == expectedMotion)
    }

    @Test("Nearest complete configuration wins and explicit resume preserves inherited settings")
    func nearestConfigurationAndResume() throws {
        let configuration = SphereOrbitConfiguration(style: .ring, radius: 60, showsOrbit: false)
        let motion = SphereOrbitMotion(isPaused: true, revolutionDuration: 20, animatesChanges: false)
        var observed: (SphereOrbitConfiguration, SphereOrbitMotion)?
        renderForCoverage(
            OrbitEnvironmentProbe { observed = ($0, $1) }
                .sphereOrbitConfiguration(configuration)
                .sphereOrbitPaused(false)
                .sphereOrbitConfiguration(.init(radius: 100))
                .sphereOrbitMotion(motion)
        )
        let values = try #require(observed)
        #expect(values.0 == configuration)
        var expectedMotion = motion
        expectedMotion.isPaused = false
        #expect(values.1 == expectedMotion)
    }
}

private struct OrbitEnvironmentProbe: View {
    @Environment(\.sphereOrbitConfiguration) private var configuration
    @Environment(\.sphereOrbitMotion) private var motion
    let observe: (SphereOrbitConfiguration, SphereOrbitMotion) -> Void

    var body: some View {
        Color.clear.onAppear { observe(configuration, motion) }
    }
}
