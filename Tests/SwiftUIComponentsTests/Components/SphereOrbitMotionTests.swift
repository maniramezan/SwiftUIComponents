import DesignSystem
import Testing

@testable import Components

@Suite("Sphere orbit motion")
struct SphereOrbitMotionTests {
    @Test("Continuous defaults preserve theme timing and original plane motion")
    func continuousDefaults() {
        let motion = SphereOrbitMotion.continuous
        #expect(!motion.isPaused)
        #expect(motion.revolutionDuration == nil)
        #expect(motion.pitch == .defaultPitch)
        #expect(motion.roll == .defaultRoll)
        #expect(motion.animatesChanges)
        let themeMotion = DefaultMotion(orbitalRevolutionDuration: 24)
        #expect(
            SphereOrbitGeometry.positive(motion.revolutionDuration, fallback: themeMotion.orbitalRevolutionDuration)
                == 24)
    }

    @Test("Paused preset stops revolution while retaining collection transitions")
    func pausedDefaults() {
        let motion = SphereOrbitMotion.paused
        #expect(motion.isPaused)
        #expect(motion.animatesChanges)
        #expect(motion.revolutionDuration == SphereOrbitMotion.continuous.revolutionDuration)
        #expect(motion.pitch == SphereOrbitMotion.continuous.pitch)
        #expect(motion.roll == SphereOrbitMotion.continuous.roll)
    }
}
