import DesignSystem
import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("Orbiting sphere")
struct OrbitingSphereTests {
    private struct Item: Identifiable {
        let id: Int
    }

    @Test("Ring items stay on the radius without depth or scaling")
    func ringGeometry() {
        let orientation = SphereOrbitGeometry.orientation(elapsed: 0, revolutionDuration: 12)
        let geometry = SphereOrbitFrameGeometry(
            size: CGSize(width: 300, height: 300), configuration: .init(style: .ring, radius: 100, phase: .zero)
        )
        for index in 0..<8 {
            let placement = SphereOrbitPlacement(
                position: Double(index) / 8, geometry: geometry, pose: .init(turns: 0, orientation: orientation)
            ).placement
            #expect(abs(hypot(placement.offset.x, placement.offset.y) - 100) < 0.0001)
            #expect(placement.scale == 1)
            #expect(placement.depth == 0)
        }
    }

    @Test("Spatial items scale with depth and pass behind the center")
    func spatialDepth() {
        let orientation = SphereOrbitGeometry.orientation(elapsed: 0, revolutionDuration: 12)
        let front = SphereOrbitGeometry.placement(
            angle: .pi / 2, radius: 100, style: .spatial, orientation: orientation)
        let back = SphereOrbitGeometry.placement(
            angle: -.pi / 2, radius: 100, style: .spatial, orientation: orientation)
        #expect(front.depth > 0)
        #expect(back.depth < 0)
        #expect(front.scale > 1)
        #expect(back.scale < 1)
    }

    @Test("Ring repeats after a revolution while the spatial plane keeps tilting")
    func revolution() {
        let initialOrientation = SphereOrbitGeometry.orientation(elapsed: 0, revolutionDuration: 12)
        let nextOrientation = SphereOrbitGeometry.orientation(elapsed: 12, revolutionDuration: 12)
        let ring = SphereOrbitFrameGeometry(
            size: CGSize(width: 300, height: 300), configuration: .init(style: .ring, radius: 100, phase: .zero)
        )
        let first = SphereOrbitPlacement(
            position: 0, geometry: ring, pose: .init(turns: 0, orientation: initialOrientation)
        ).placement
        let last = SphereOrbitPlacement(
            position: 0, geometry: ring, pose: .init(turns: 1, orientation: nextOrientation)
        ).placement
        #expect(abs(first.offset.x - last.offset.x) < 0.0001)
        #expect(abs(first.offset.y - last.offset.y) < 0.0001)
        let spatial = SphereOrbitFrameGeometry(
            size: CGSize(width: 300, height: 300), configuration: .init(radius: 100, phase: .zero)
        )
        let tilted = SphereOrbitPlacement(
            position: 0, geometry: spatial, pose: .init(turns: 1, orientation: nextOrientation)
        ).placement
        #expect(abs(tilted.offset.y) > 0.01)
    }

    @Test("Invalid dimensions and timing degrade to a finite frame")
    func invalidInputs() {
        #expect(SphereOrbitGeometry.positive(nil, fallback: 100) == 100)
        for invalid in [CGFloat.nan, .infinity, -10, 0] {
            #expect(SphereOrbitGeometry.positive(invalid, fallback: 100) == 100)
        }
        #expect(SphereOrbitGeometry.turns(elapsed: 6, duration: 12) == 0.5)
        #expect(SphereOrbitGeometry.turns(elapsed: -1, duration: 12) == 0)
        #expect(SphereOrbitGeometry.turns(elapsed: .infinity, duration: 12) == 0)
        #expect(SphereOrbitGeometry.turns(elapsed: 1, duration: 0) == 0)
        #expect(DefaultMotion().orbitalRevolutionDuration == 12)
    }

    @Test("Duplicate identities are ignored without replacing the first item")
    func duplicateIdentity() {
        let items = SphereOrbitGeometry.uniqueItems([Item(id: 1), Item(id: 2), Item(id: 1)])
        #expect(items.map(\.id) == [1, 2])
    }

    @Test("Insertion and removal redistribute along the ring instead of cutting through it", arguments: [4, 6])
    func redistributionFollowsOrbit(newCount: Int) {
        let initialPosition = 3.0 / 5
        let targetPosition = 3.0 / Double(newCount)
        var modifier = SphereOrbitPlacement(
            position: initialPosition,
            geometry: .init(size: CGSize(width: 300, height: 300), configuration: .init(style: .ring, radius: 100)),
            pose: .init(turns: 2.25, orientation: .init(pitch: 0, roll: 0))
        )
        #expect(modifier.animatableData == initialPosition)
        let start = modifier.placement
        for progress in [0.0, 0.25, 0.5, 0.75, 1.0] {
            modifier.animatableData = initialPosition + (targetPosition - initialPosition) * progress
            let placement = modifier.placement
            #expect(abs(hypot(placement.offset.x, placement.offset.y) - 100) < 0.0001)
            #expect(placement.scale == 1)
            #expect(placement.depth == 0)
        }
        #expect(modifier.position == targetPosition)
        #expect(abs(modifier.placement.offset.x - start.offset.x) > 1)
        #expect(modifier.pose.turns == 2.25)
    }

    @Test("Spatial redistribution preserves perspective and crosses behind the center")
    func redistributionPreservesDepth() {
        var modifier = SphereOrbitPlacement(
            position: 0.25,
            geometry: .init(size: CGSize(width: 300, height: 300), configuration: .init(radius: 100, phase: .zero)),
            pose: .init(turns: 3, orientation: .init(pitch: -.pi / 4, roll: .pi / 6))
        )
        #expect(modifier.placement.depth > 0)
        #expect(modifier.placement.scale > 1)
        modifier.animatableData = 0.5
        #expect(abs(modifier.placement.depth) < 0.0001)
        #expect(abs(modifier.placement.scale - 1) < 0.0001)
        modifier.animatableData = 0.75
        #expect(modifier.placement.depth < 0)
        #expect(modifier.placement.scale < 1)
        #expect(modifier.pose.turns == 3)
    }

    @Test("Accessibility, scene state, and caller pause requests stop motion")
    func motionPolicy() {
        #expect(
            SphereOrbitGeometry.shouldAnimate(
                requested: true, reduceMotion: false, voiceOver: false, sceneActive: true, hasItems: true))
        #expect(
            !SphereOrbitGeometry.shouldAnimate(
                requested: false, reduceMotion: false, voiceOver: false, sceneActive: true, hasItems: true))
        #expect(
            !SphereOrbitGeometry.shouldAnimate(
                requested: true, reduceMotion: true, voiceOver: false, sceneActive: true, hasItems: true))
        #expect(
            !SphereOrbitGeometry.shouldAnimate(
                requested: true, reduceMotion: false, voiceOver: true, sceneActive: true, hasItems: true))
        #expect(
            !SphereOrbitGeometry.shouldAnimate(
                requested: true, reduceMotion: false, voiceOver: false, sceneActive: false, hasItems: true))
        #expect(
            !SphereOrbitGeometry.shouldAnimate(
                requested: true, reduceMotion: false, voiceOver: false, sceneActive: true, hasItems: false))
    }

    @Test("Renders both projections, empty input, and custom content")
    func rendering() {
        for style in SphereOrbitStyle.allCases {
            renderForCoverage(
                OrbitingSphere([Item(id: 1), Item(id: 2)]) {
                    SphereView { Text("Center") }
                } satellite: { item in
                    SphereView(diameter: 44, tint: .purple) { Text(item.id.formatted()) }
                }
                .sphereOrbitStyle(style)
                .sphereOrbitPaused(),
                size: CGSize(width: 320, height: 320)
            )
        }
        renderForCoverage(
            OrbitingSphere([Item(id: 1), Item(id: 2)]) {
                SphereView { Text("Center") }
            } satellite: { item in
                SphereView { Text(item.id.formatted()) }
            }
            .sphereOrbitMotion(
                .init(
                    isPaused: true,
                    pitch: .init(center: .degrees(-45), amplitude: .degrees(15), cycleDuration: 20),
                    roll: .init(center: .degrees(25))
                )
            ),
            size: CGSize(width: 320, height: 320)
        )
        renderForCoverage(
            OrbitingSphere([Item]()) {
                SphereView { EmptyView() }
            } satellite: { _ in
                EmptyView()
            }
            .sphereOrbitConfiguration(.init(showsOrbit: false)),
            size: CGSize(width: 320, height: 320)
        )
    }

    @Test("Renders with collection animations enabled or disabled", arguments: [true, false])
    func changeAnimationSettings(animatesChanges: Bool) {
        renderForCoverage(
            OrbitingSphere([Item(id: 1), Item(id: 2)]) {
                Text("Center")
            } satellite: { item in
                Text(item.id.formatted())
            }
            .sphereOrbitStyle(.ring)
            .sphereOrbitMotion(.init(isPaused: true, animatesChanges: animatesChanges)),
            size: CGSize(width: 320, height: 320)
        )
    }

    @Test(
        "Native frames size the orbit and automatic radius fits the shorter side",
        arguments: [CGFloat?.none, .some(.nan)])
    func nativeFrameControlsRadius(radius: CGFloat?) throws {
        var centerPoint: CGPoint?
        var satellitePoint: CGPoint?
        renderForCoverage(
            OrbitingSphere([Item(id: 1)]) {
                OrbitGeometryMarker { centerPoint = $0 }
            } satellite: { _ in
                OrbitGeometryMarker { satellitePoint = $0 }
            }
            .sphereOrbitStyle(.ring)
            .sphereOrbitPaused()
            .sphereOrbitConfiguration(.init(radius: radius))
            .frame(width: 240, height: 160)
            .coordinateSpace(name: "OrbitFrameTest")
        )
        let center = try #require(centerPoint)
        let satellite = try #require(satellitePoint)
        #expect(abs(hypot(satellite.x - center.x, satellite.y - center.y) - 60.8) < 1)
    }

    @Test("The rendered frame uses inherited radius and phase", arguments: [0.0, 90, 180])
    func inheritedFrameGeometry(phase: Double) throws {
        var centerPoint: CGPoint?
        var satellitePoint: CGPoint?
        renderForCoverage(
            OrbitingSphere([Item(id: 1)]) {
                OrbitGeometryMarker { centerPoint = $0 }
            } satellite: { _ in
                OrbitGeometryMarker { satellitePoint = $0 }
            }
            .frame(width: 240, height: 160)
            .sphereOrbitConfiguration(.init(style: .ring, radius: 48, phase: .degrees(phase), showsOrbit: false))
            .sphereOrbitPaused()
            .coordinateSpace(name: "OrbitFrameTest")
        )
        let center = try #require(centerPoint)
        let satellite = try #require(satellitePoint)
        let radians = phase * .pi / 180
        #expect(abs(satellite.x - center.x - cos(radians) * 48) < 1)
        #expect(abs(satellite.y - center.y - sin(radians) * 48) < 1)
    }
}

private struct OrbitGeometryMarker: View {
    let observe: (CGPoint) -> Void

    var body: some View {
        Color.clear
            .frame(width: 1, height: 1)
            .onGeometryChange(for: CGPoint.self) { geometry in
                let frame = geometry.frame(in: .named("OrbitFrameTest"))
                return CGPoint(x: frame.midX, y: frame.midY)
            } action: { point in
                observe(point)
            }
    }
}
