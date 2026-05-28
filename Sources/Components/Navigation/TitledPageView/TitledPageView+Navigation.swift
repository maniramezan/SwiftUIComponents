import SwiftUI

// MARK: - Navigation state helpers

extension TitledPageView {

    /// The index in `pages` whose id currently matches `selection`. Falls
    /// back to the nearest integer of the scroll progress when the binding
    /// is mid-update, which keeps the indicator and header in sync during
    /// in-flight drags.
    var activeIndex: Int {
        if let idx = pages.firstIndex(where: { $0[keyPath: idKeyPath] == selection }) {
            return idx
        }
        let progress = Self.progress(contentOffsetX: scrollOffsetX, viewportWidth: viewportWidth)
        return Self.stepIndex(by: 0, from: Int(progress.rounded()), count: pages.count)
    }

    /// Bridges the `ID?` shape required by `scrollPosition(id:)` to the
    /// non-optional `Binding<ID>` API. In unidirectional mode, backward
    /// scroll-position updates are rejected since previous pages have been
    /// removed from the scroll content.
    var scrollPositionBinding: Binding<ID?> {
        Binding(
            get: { selection },
            set: { newValue in
                guard let newValue else { return }
                selection = newValue
            }
        )
    }

    func jump(to index: Int, reduceMotion: Bool) {
        guard pages.indices.contains(index) else { return }
        if styleOverride.peekDirection == .unidirectional {
            guard index >= activeIndex else { return }
        }
        let newID = pages[index][keyPath: idKeyPath]
        let animation: Animation =
            reduceMotion ? .easeInOut(duration: 0.15) : theme.motion.standardAnimation
        withAnimation(animation) {
            selection = newID
        }
    }
}
