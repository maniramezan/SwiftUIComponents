import SwiftUI

/// Default adaptive colors backed by platform semantic colors where available.
public struct DefaultDesignColors: DesignColorTheme {
    /// Creates the default color theme.
    public init() {}

    @MainActor public var background: Color { platformColor(systemBackground: .background) }
    @MainActor public var backgroundSecondary: Color { platformColor(systemBackground: .secondaryBackground) }
    @MainActor public var container: Color { platformColor(systemBackground: .secondaryBackground) }
    @MainActor public var containerSecondary: Color { platformColor(systemBackground: .tertiaryBackground) }
    @MainActor public var primary: Color { .accentColor }
    @MainActor public var onPrimary: Color { .white }
    @MainActor public var textPrimary: Color { .primary }
    @MainActor public var textSecondary: Color { .secondary }
    @MainActor public var textTertiary: Color { .secondary.opacity(0.7) }
    @MainActor public var border: Color { .secondary.opacity(0.25) }
    @MainActor public var separator: Color { .secondary.opacity(0.2) }
    @MainActor public var error: Color { .red }
    @MainActor public var onError: Color { .white }
    @MainActor public var success: Color { .green }
    @MainActor public var warning: Color { .orange }
    @MainActor public var disabled: Color { .secondary.opacity(0.5) }
}

private enum SystemBackground {
    case background
    case secondaryBackground
    case tertiaryBackground
}

@MainActor
private func platformColor(systemBackground: SystemBackground) -> Color {
    #if canImport(UIKit)
        switch systemBackground {
        case .background:
            Color(uiColor: .systemBackground)
        case .secondaryBackground:
            Color(uiColor: .secondarySystemBackground)
        case .tertiaryBackground:
            Color(uiColor: .tertiarySystemBackground)
        }
    #elseif canImport(AppKit)
        switch systemBackground {
        case .background:
            Color(nsColor: .windowBackgroundColor)
        case .secondaryBackground:
            Color(nsColor: .controlBackgroundColor)
        case .tertiaryBackground:
            Color(nsColor: .underPageBackgroundColor)
        }
    #else
        switch systemBackground {
        case .background:
            Color(.sRGB, white: 1, opacity: 1)
        case .secondaryBackground:
            Color(.sRGB, white: 0.96, opacity: 1)
        case .tertiaryBackground:
            Color(.sRGB, white: 0.92, opacity: 1)
        }
    #endif
}
