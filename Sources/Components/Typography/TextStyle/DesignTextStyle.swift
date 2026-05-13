import DesignSystem
import SwiftUI

/// Applies typography and foreground color from the active design theme.
public struct DesignTextStyle: ViewModifier {
    private let role: DesignTextRole
    @Environment(\.designTheme) private var theme

    /// Creates a text-style modifier.
    public init(_ role: DesignTextRole) {
        self.role = role
    }

    public func body(content: Content) -> some View {
        content
            .font(font)
            .foregroundStyle(color)
    }

    @MainActor private var font: Font {
        switch role {
        case .title:
            theme.typography.title2
        case .headline:
            theme.typography.headline
        case .body:
            theme.typography.body
        case .secondary:
            theme.typography.footnote
        case .caption:
            theme.typography.caption
        case .error:
            theme.typography.footnote
        }
    }

    @MainActor private var color: Color {
        switch role {
        case .title, .headline, .body:
            theme.colors.textPrimary
        case .secondary, .caption:
            theme.colors.textSecondary
        case .error:
            theme.colors.error
        }
    }
}

public extension View {
    /// Applies a themed text style.
    func designTextStyle(_ role: DesignTextRole) -> some View {
        modifier(DesignTextStyle(role))
    }
}
