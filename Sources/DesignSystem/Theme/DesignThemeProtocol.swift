/// Complete design theme consumed by reusable SwiftUI components.
public protocol DesignTheme: Sendable {
    /// Spacing scale.
    var spacing: any DesignSpacing { get }
    /// Corner-radius scale.
    var radius: any DesignRadius { get }
    /// Stroke-width scale.
    var stroke: any DesignStroke { get }
    /// Motion and interaction tokens.
    var motion: any DesignMotion { get }
    /// Semantic color theme.
    var colors: any DesignColorTheme { get }
    /// Semantic typography theme.
    var typography: any DesignTypography { get }
}
