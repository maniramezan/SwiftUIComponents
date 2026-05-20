import DesignSystem
import SwiftUI

/// Applies typography and foreground color from the active design theme.
///
/// ![All text style roles](designTextStyles)
public struct TypeStyle: ViewModifier {
    private let role: TextRole
    @Environment(\.designTheme) private var theme

    /// Creates a text-style modifier.
    public init(_ role: TextRole) {
        self.role = role
    }

    /// Applies the themed font and foreground color to the wrapped content.
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
    func designTextStyle(_ role: TextRole) -> some View {
        modifier(TypeStyle(role))
    }
}

#Preview("Design Text Styles") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            Text("Title").designTextStyle(.title)
            Text("Headline").designTextStyle(.headline)
            Text("Body text").designTextStyle(.body)
            Text("Secondary text").designTextStyle(.secondary)
            Text("Caption text").designTextStyle(.caption)
            Text("Error text").designTextStyle(.error)
        }
        .padding(theme.spacing.twoUnits)
    }
}
