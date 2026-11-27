import DesignSystem
import SwiftUI

/// A decorative horizontal rule that uses the active theme's separator color
/// and hairline stroke width. Place it in a vertical stack to separate content.
///
/// ```swift
/// VStack {
///     Text("First section")
///     ThemeDivider()
///     Text("Second section")
/// }
/// ```
public struct ThemeDivider: View {
    @Environment(\.designTheme) private var theme

    /// Creates a horizontal separator.
    public init() {}

    /// The decorative rule.
    public var body: some View {
        Rectangle()
            .fill(theme.colors.separator)
            .frame(height: theme.stroke.hairline)
            .accessibilityHidden(true)
    }
}

#Preview {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.oneUnit) {
            Text("First section")
            ThemeDivider()
            Text("Second section")
        }
        .foregroundStyle(theme.colors.textPrimary)
    }
}
