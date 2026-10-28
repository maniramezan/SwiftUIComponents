import Foundation
import Testing

@testable import Components

struct SphereOrbitClockTests {
    private let start = Date(timeIntervalSinceReferenceDate: 0)

    @Test("A requested animation waits until the view appears")
    func startsWhenVisible() {
        var clock = SphereOrbitClock()
        clock.setAnimating(true, at: start)
        #expect(clock.elapsed(at: start.addingTimeInterval(5)) == 0)
        clock.setVisible(true, at: start.addingTimeInterval(5))
        #expect(clock.elapsed(at: start.addingTimeInterval(7)) == 2)
    }

    @Test("Pausing freezes elapsed time and resuming preserves the accumulated progress")
    func pauseAndResume() {
        var clock = SphereOrbitClock()
        clock.setVisible(true, at: start)
        clock.setAnimating(true, at: start)
        clock.setAnimating(false, at: start.addingTimeInterval(7))
        #expect(clock.elapsed(at: start.addingTimeInterval(20)) == 7)
        clock.setAnimating(true, at: start.addingTimeInterval(20))
        #expect(clock.elapsed(at: start.addingTimeInterval(23)) == 10)
    }

    @Test("Repeated lifecycle notifications do not reset a running clock")
    func repeatedNotifications() {
        var clock = SphereOrbitClock()
        clock.setVisible(true, at: start)
        clock.setAnimating(true, at: start)
        clock.setVisible(true, at: start.addingTimeInterval(1))
        clock.setAnimating(true, at: start.addingTimeInterval(2))
        #expect(clock.elapsed(at: start.addingTimeInterval(5)) == 5)
    }

    @Test("Scene changes cannot restart an offscreen orbit before it reappears")
    func staysPausedWhileHidden() {
        var clock = SphereOrbitClock()
        clock.setVisible(true, at: start)
        clock.setAnimating(true, at: start)
        clock.setVisible(false, at: start.addingTimeInterval(6))
        clock.setAnimating(false, at: start.addingTimeInterval(10))
        clock.setAnimating(true, at: start.addingTimeInterval(12))
        #expect(clock.elapsed(at: start.addingTimeInterval(20)) == 6)
        clock.setVisible(true, at: start.addingTimeInterval(21))
        #expect(clock.elapsed(at: start.addingTimeInterval(25)) == 10)
    }

    @Test("A backwards wall clock cannot produce negative accumulated animation time")
    func backwardsTime() {
        var clock = SphereOrbitClock()
        clock.setVisible(true, at: start.addingTimeInterval(10))
        clock.setAnimating(true, at: start.addingTimeInterval(10))
        #expect(clock.elapsed(at: start) == 0)
        clock.setAnimating(false, at: start)
        #expect(clock.elapsed(at: start.addingTimeInterval(20)) == 0)
    }
}
