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
        for index in 0..<8 {
            let angle = SphereOrbitGeometry.angle(index: index, count: 8, turns: 0, phase: 0)
            let placement = SphereOrbitGeometry.placement(angle: angle, turns: 0, radius: 100, style: .ring)
            #expect(abs(hypot(placement.offset.x, placement.offset.y) - 100) < 0.0001)
            #expect(placement.scale == 1)
            #expect(placement.depth == 0)
        }
    }

    @Test("Spatial items scale with depth and pass behind the center")
    func spatialDepth() {
        let front = SphereOrbitGeometry.placement(angle: .pi / 2, turns: 0, radius: 100, style: .spatial)
        let back = SphereOrbitGeometry.placement(angle: -.pi / 2, turns: 0, radius: 100, style: .spatial)
        #expect(front.depth > 0)
        #expect(back.depth < 0)
        #expect(front.scale > 1)
        #expect(back.scale < 1)
    }

    @Test("Ring repeats after a revolution while the spatial plane keeps tilting")
    func revolution() {
        let angle = SphereOrbitGeometry.angle(index: 0, count: 4, turns: 0, phase: 0)
        let next = SphereOrbitGeometry.angle(index: 0, count: 4, turns: 1, phase: 0)
        let first = SphereOrbitGeometry.placement(angle: angle, turns: 0, radius: 100, style: .ring)
        let last = SphereOrbitGeometry.placement(angle: next, turns: 1, radius: 100, style: .ring)
        #expect(abs(first.offset.x - last.offset.x) < 0.0001)
        #expect(abs(first.offset.y - last.offset.y) < 0.0001)
        let tilted = SphereOrbitGeometry.placement(angle: next, turns: 1, radius: 100, style: .spatial)
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
        #expect(SphereOrbitGeometry.angle(index: 0, count: 0, turns: 0, phase: 1) == 1)
        #expect(DefaultMotion().orbitalRevolutionDuration == 12)
    }

    @Test("Duplicate identities are ignored without replacing the first item")
    func duplicateIdentity() {
        let items = SphereOrbitGeometry.uniqueItems([Item(id: 1), Item(id: 2), Item(id: 1)])
        #expect(items.map(\.id) == [1, 2])
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
                OrbitingSphere([Item(id: 1), Item(id: 2)], style: style, isAnimating: false) {
                    SphereView { Text("Center") }
                } satellite: { item in
                    SphereView(diameter: 44, tint: .purple) { Text(item.id.formatted()) }
                },
                size: CGSize(width: 320, height: 320)
            )
        }
        renderForCoverage(
            OrbitingSphere([Item](), showsOrbit: false) {
                SphereView { EmptyView() }
            } satellite: { _ in
                EmptyView()
            },
            size: CGSize(width: 320, height: 320)
        )
    }
}
