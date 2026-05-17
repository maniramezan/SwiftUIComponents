/// Complete design theme consumed by reusable SwiftUI components.
public protocol Theme: Sendable {
    /// Spacing scale.
    var spacing: any Spacing { get }
    /// Corner-radius scale.
    var radius: any Radius { get }
    /// Stroke-width scale.
    var stroke: any Stroke { get }
    /// Motion and interaction tokens.
    var motion: any Motion { get }
    /// Semantic color theme.
    var colors: any ColorTheme { get }
    /// Semantic typography theme.
    var typography: any Typography { get }
}
