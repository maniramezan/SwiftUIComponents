import Foundation

nonisolated struct SphereOrbitClock {
    private var accumulated: TimeInterval = 0
    private var startedAt: Date?
    private var isVisible = false
    private var isAnimationRequested = false

    func elapsed(at date: Date) -> TimeInterval {
        accumulated + (startedAt.map { max(0, date.timeIntervalSince($0)) } ?? 0)
    }

    mutating func setAnimating(_ isAnimating: Bool, at date: Date) {
        isAnimationRequested = isAnimating
        update(at: date)
    }

    mutating func setVisible(_ isVisible: Bool, at date: Date) {
        self.isVisible = isVisible
        update(at: date)
    }

    private mutating func update(at date: Date) {
        if isVisible && isAnimationRequested {
            guard startedAt == nil else { return }
            startedAt = date
        } else if startedAt != nil {
            accumulated = elapsed(at: date)
            startedAt = nil
        }
    }
}
