import SwiftUI

/// Default theme used when apps do not inject a custom design theme.
public struct DefaultTheme: Theme {
    public let spacing: any Spacing
    public let radius: any Radius
    public let stroke: any Stroke
    public let motion: any Motion
    public let colors: any ColorTheme
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
