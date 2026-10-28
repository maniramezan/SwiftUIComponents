import SwiftUI
import Testing

@testable import Components

@Suite("Sphere orbit configuration")
struct SphereOrbitConfigurationTests {
    @Test("Defaults retain spatial placement, automatic radius, top phase, and a visible guide")
    func defaults() {
        let configuration = SphereOrbitConfiguration()
        #expect(configuration.style == .spatial)
        #expect(configuration.radius == nil)
        #expect(configuration.phase == .degrees(-90))
        #expect(configuration.showsOrbit)
    }

    @Test("Canvas sizing accepts frames, single-axis constraints, and unbounded proposals")
    func proposedCanvasSize() {
        #expect(
            SphereOrbitGeometry.canvasSize(width: 320, height: 180, idealSide: 288) == CGSize(width: 320, height: 180))
        #expect(
            SphereOrbitGeometry.canvasSize(width: 240, height: nil, idealSide: 288) == CGSize(width: 240, height: 240))
        #expect(
            SphereOrbitGeometry.canvasSize(width: nil, height: 160, idealSide: 288) == CGSize(width: 160, height: 160))
        #expect(
            SphereOrbitGeometry.canvasSize(width: nil, height: nil, idealSide: 288) == CGSize(width: 288, height: 288))
        #expect(SphereOrbitGeometry.canvasSize(width: 0, height: 0, idealSide: 288) == .zero)
        for invalid in [CGFloat.nan, .infinity, -.infinity, -1] {
            #expect(
                SphereOrbitGeometry.canvasSize(width: invalid, height: invalid, idealSide: 288)
                    == CGSize(width: 288, height: 288)
            )
        }
    }

    @Test("Invalid phases fall back without discarding finite caller angles")
    func phaseValidation() {
        for invalid in [Double.nan, .infinity, -.infinity] {
            #expect(SphereOrbitGeometry.phase(invalid) == -.pi / 2)
        }
        for phase in [-10.0, 0, 10] {
            #expect(SphereOrbitGeometry.phase(phase) == phase)
        }
    }
}
