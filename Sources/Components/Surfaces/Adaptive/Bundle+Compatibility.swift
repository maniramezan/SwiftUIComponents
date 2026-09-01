import Foundation

extension Bundle {
    /// Whether the hosting app's `UIDesignRequiresCompatibility` Info.plist key
    /// is set to `true`, forcing design-compatible (non-glass) fallbacks
    /// regardless of OS version.
    ///
    /// Shared by every adaptive surface/button so the decision is resolved in
    /// one place instead of duplicated per component.
    static var requiresDesignCompatibility: Bool {
        main.object(forInfoDictionaryKey: "UIDesignRequiresCompatibility") as? Bool ?? false
    }
}
