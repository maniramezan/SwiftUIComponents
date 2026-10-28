import SwiftUI
import Testing

@testable import Components

struct SphereOrbitFrameGeometryTests {
    @Test(
        "Automatic radius follows the projection and the shorter canvas dimension", arguments: SphereOrbitStyle.allCases
    )
    func automaticRadius(style: SphereOrbitStyle) {
        let geometry = SphereOrbitFrameGeometry(
            size: CGSize(width: 320, height: 160), configuration: .init(style: style)
        )
        #expect(geometry.side == 160)
        #expect(geometry.style == style)
        #expect(abs(geometry.radius - (style == .ring ? 60.8 : 48)) < 0.0001)
        #expect(geometry.phase == -.pi / 2)
    }

    @Test("Explicit radius and phase are preserved independently of canvas size")
    func explicitGeometry() {
        let geometry = SphereOrbitFrameGeometry(
            size: CGSize(width: 120, height: 240), configuration: .init(radius: 42, phase: .degrees(30))
        )
        #expect(geometry.side == 120)
        #expect(geometry.radius == 42)
        #expect(abs(geometry.phase - .pi / 6) < 0.0001)
    }

    @Test("Invalid radius and phase use finite defaults", arguments: [Double.nan, .infinity, -.infinity])
    func invalidGeometry(value: Double) {
        let geometry = SphereOrbitFrameGeometry(
            size: CGSize(width: 200, height: 160),
            configuration: .init(style: .ring, radius: CGFloat(value), phase: .radians(value))
        )
        #expect(geometry.side == 160)
        #expect(abs(geometry.radius - 60.8) < 0.0001)
        #expect(geometry.phase == -.pi / 2)
    }

    @Test("A zero-sized proposal remains collapsed")
    func collapsedCanvas() {
        let geometry = SphereOrbitFrameGeometry(size: .zero, configuration: .init())
        #expect(geometry.side == 0)
        #expect(geometry.radius == 0)
        #expect(geometry.phase.isFinite)
    }
}
