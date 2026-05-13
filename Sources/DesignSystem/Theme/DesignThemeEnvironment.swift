import SwiftUI

private struct DesignThemeKey: EnvironmentKey {
    static let defaultValue: any DesignTheme = DefaultDesignTheme()
}

public extension EnvironmentValues {
    /// Design theme used by shared components.
    var designTheme: any DesignTheme {
        get { self[DesignThemeKey.self] }
        set { self[DesignThemeKey.self] = newValue }
    }
}

public extension View {
    /// Injects a design theme for this view hierarchy.
    func designTheme(_ theme: any DesignTheme) -> some View {
        environment(\.designTheme, theme)
    }
}
