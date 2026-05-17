import SwiftUI

private struct ThemeKey: EnvironmentKey {
    static let defaultValue: any Theme = DefaultTheme()
}

public extension EnvironmentValues {
    /// Design theme used by shared components.
    var designTheme: any Theme {
        get { self[ThemeKey.self] }
        set { self[ThemeKey.self] = newValue }
    }
}

public extension View {
    /// Injects a design theme for this view hierarchy.
    func designTheme(_ theme: any Theme) -> some View {
        environment(\.designTheme, theme)
    }
}
