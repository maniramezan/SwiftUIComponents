import SwiftUI
import Testing

@testable import Components

@Suite("Sphere orbit tilt")
struct SphereOrbitTiltTests {
    @Test("Default tilts preserve the original angle ranges and timing")
    func originalMotion() {
        #expect(SphereOrbitTilt.defaultPitch.center.radians == -0.65)
        #expect(SphereOrbitTilt.defaultPitch.amplitude.radians == 0.30)
        #expect(SphereOrbitTilt.defaultRoll.center == .zero)
        #expect(SphereOrbitTilt.defaultRoll.amplitude.radians == 0.50)
        #expect(SphereOrbitTilt.defaultPitch.cycleDuration == nil)
        #expect(SphereOrbitTilt.defaultRoll.cycleDuration == nil)
        let initial = SphereOrbitGeometry.orientation(elapsed: 0, revolutionDuration: 12)
        #expect(initial.pitch == -0.65)
        #expect(initial.roll == 0)
        let pitchMaximum = SphereOrbitGeometry.orientation(elapsed: 12 / 0.37 / 4, revolutionDuration: 12)
        let pitchMinimum = SphereOrbitGeometry.orientation(elapsed: 12 / 0.37 * 0.75, revolutionDuration: 12)
        let rollMaximum = SphereOrbitGeometry.orientation(elapsed: 12 / 0.23 / 4, revolutionDuration: 12)
        #expect(abs(pitchMaximum.pitch - (-0.35)) < 0.0001)
        #expect(abs(pitchMinimum.pitch - (-0.95)) < 0.0001)
        #expect(abs(rollMaximum.roll - 0.50) < 0.0001)
    }

    @Test("Custom cycles reach both angle limits and return to the center", arguments: [0.0, 0.25, 0.5, 0.75, 1.0])
    func cycleLimits(progress: Double) {
        let tilt = SphereOrbitTilt(center: .degrees(-30), amplitude: .degrees(20), cycleDuration: 8)
        let angle = SphereOrbitGeometry.tiltAngle(tilt, elapsed: progress * 8, fallbackDuration: 100)
        let expectedDegrees =
            switch progress {
            case 0.25: -10.0
            case 0.75: -50.0
            default: -30.0
            }
        #expect(abs(angle * 180 / .pi - expectedDegrees) < 0.0001)
    }

    @Test("Explicit pitch and roll periods are independent of revolution timing and each other")
    func independentTiming() {
        let pitch = SphereOrbitTilt(center: .degrees(-30), amplitude: .degrees(20), cycleDuration: 8)
        let roll = SphereOrbitTilt(center: .degrees(10), amplitude: .degrees(30), cycleDuration: 16)
        let first = SphereOrbitGeometry.orientation(elapsed: 2, revolutionDuration: 12, pitch: pitch, roll: roll)
        let slower = SphereOrbitGeometry.orientation(elapsed: 2, revolutionDuration: 24, pitch: pitch, roll: roll)
        #expect(first.pitch == slower.pitch)
        #expect(first.roll == slower.roll)
        #expect(abs(first.pitch * 180 / .pi - (-10)) < 0.0001)
        #expect(abs(first.roll * 180 / .pi - (10 + 30 / sqrt(2))) < 0.0001)
        let changedRoll = SphereOrbitGeometry.orientation(
            elapsed: 2, revolutionDuration: 12, pitch: pitch,
            roll: SphereOrbitTilt(center: roll.center, amplitude: roll.amplitude, cycleDuration: 8)
        )
        #expect(first.pitch == changedRoll.pitch)
        #expect(abs(changedRoll.roll * 180 / .pi - 40) < 0.0001)
    }

    @Test("Unspecified cycle durations scale with revolution timing")
    func relativeTiming() {
        let first = SphereOrbitGeometry.orientation(elapsed: 3, revolutionDuration: 12)
        let slower = SphereOrbitGeometry.orientation(elapsed: 6, revolutionDuration: 24)
        #expect(abs(first.pitch - slower.pitch) < 0.0001)
        #expect(abs(first.roll - slower.roll) < 0.0001)
    }

    @Test("A zero amplitude fixes a tilted plane across time")
    func fixedTilt() {
        let fixed = SphereOrbitTilt(center: .degrees(35))
        for elapsed in [0.0, 3, 500] {
            #expect(SphereOrbitGeometry.tiltAngle(fixed, elapsed: elapsed, fallbackDuration: 8) == fixed.center.radians)
        }
    }

    @Test("Invalid angles and durations safely fall back")
    func invalidInputs() {
        for invalid in [Double.nan, .infinity, -.infinity] {
            #expect(SphereOrbitTilt(center: .radians(invalid)).center == .zero)
        }
        for invalid in [Double.nan, .infinity, -.infinity, -1] {
            #expect(SphereOrbitTilt(amplitude: .radians(invalid)).amplitude == .zero)
        }
        for invalid in [Double.nan, .infinity, -.infinity, -1, 0] {
            #expect(SphereOrbitTilt(cycleDuration: invalid).cycleDuration == nil)
        }
        let tilt = SphereOrbitTilt(center: .degrees(10), amplitude: .degrees(20))
        for elapsed in [Double.nan, .infinity, -.infinity, -1] {
            #expect(SphereOrbitGeometry.tiltAngle(tilt, elapsed: elapsed, fallbackDuration: 8) == tilt.center.radians)
        }
        #expect(SphereOrbitGeometry.tiltAngle(tilt, elapsed: 3, fallbackDuration: 0) == tilt.center.radians)
        let shortCycle = SphereOrbitTilt(amplitude: .degrees(20), cycleDuration: .leastNormalMagnitude)
        #expect(SphereOrbitGeometry.tiltAngle(shortCycle, elapsed: 1, fallbackDuration: 8).isFinite)
    }

    @Test("Custom pitch and roll reach the spatial projection while a ring ignores them")
    func projectedOrientation() {
        let flat = SphereOrbitGeometry.Orientation(pitch: 0, roll: 0)
        let tilted = SphereOrbitGeometry.Orientation(pitch: .pi / 2, roll: .pi / 2)
        let firstRing = SphereOrbitGeometry.placement(angle: .pi / 2, radius: 100, style: .ring, orientation: flat)
        let nextRing = SphereOrbitGeometry.placement(angle: .pi / 2, radius: 100, style: .ring, orientation: tilted)
        #expect(firstRing.offset == nextRing.offset)
        #expect(firstRing.scale == nextRing.scale)
        #expect(firstRing.depth == nextRing.depth)
        let spatial = SphereOrbitGeometry.placement(angle: .pi / 2, radius: 100, style: .spatial, orientation: tilted)
        #expect(abs(spatial.offset.x - 100) < 0.0001)
        #expect(abs(spatial.offset.y) < 0.0001)
        #expect(abs(spatial.depth) < 0.0001)
    }
}
