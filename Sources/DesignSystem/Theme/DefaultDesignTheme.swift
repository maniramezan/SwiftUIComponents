import SwiftUI

/// Default theme used when apps do not inject a custom design theme.
public struct DefaultDesignTheme: DesignTheme {
    public let spacing: any DesignSpacing
    public let radius: any DesignRadius
    public let stroke: any DesignStroke
    public let motion: any DesignMotion
    public let colors: any DesignColorTheme
    public let typography: any DesignTypography

    /// Creates a theme from token groups.
    public init(
        spacing: any DesignSpacing = DefaultDesignSpacing(),
        radius: any DesignRadius = DefaultDesignRadius(),
        stroke: any DesignStroke = DefaultDesignStroke(),
        motion: any DesignMotion = DefaultDesignMotion(),
        colors: any DesignColorTheme = DefaultDesignColors(),
        typography: any DesignTypography = DefaultDesignTypography()
    ) {
        self.spacing = spacing
        self.radius = radius
        self.stroke = stroke
        self.motion = motion
        self.colors = colors
        self.typography = typography
    }
}
