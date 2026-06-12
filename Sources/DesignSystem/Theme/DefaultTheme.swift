import SwiftUI

/// Default theme used when apps do not inject a custom design theme.
public struct DefaultTheme: Theme {
    /// Spacing scale used by layout and component padding.
    public let spacing: any Spacing
    /// Corner-radius scale used by controls, cards, and surfaces.
    public let radius: any Radius
    /// Stroke widths used by borders, separators, and selected states.
    public let stroke: any Stroke
    /// Motion and interaction tokens such as hit targets and disabled opacity.
    public let motion: any Motion
    /// Semantic color palette used by components.
    public let colors: any ColorTheme
    /// Typography scale used by text styles and themed labels.
    public let typography: any Typography

    /// Creates a theme from token groups.
    public init(
        spacing: any Spacing = DefaultSpacing(),
        radius: any Radius = DefaultRadius(),
        stroke: any Stroke = DefaultStroke(),
        motion: any Motion = DefaultMotion(),
        colors: any ColorTheme = DefaultColors(),
        typography: any Typography = DefaultTypography()
    ) {
        self.spacing = spacing
        self.radius = radius
        self.stroke = stroke
        self.motion = motion
        self.colors = colors
        self.typography = typography
    }
}
