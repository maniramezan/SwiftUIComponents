import Foundation

/// Stores the shared paging lesson once per host app installation.
@MainActor
enum TitledPageSwipeHintHistory {
    static let storageKey = "com.swiftuicomponents.titledPageView.hasShownSwipeHint"

    /// Claims the hint immediately before playback, preventing concurrent appearances from replaying it.
    static func claim(in defaults: UserDefaults = .standard) -> Bool {
        guard !defaults.bool(forKey: storageKey) else { return false }
        defaults.set(true, forKey: storageKey)
        return true
    }
}
