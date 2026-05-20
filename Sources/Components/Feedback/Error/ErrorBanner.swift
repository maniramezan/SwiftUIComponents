import DesignSystem
import SwiftUI

/// Inline error banner with a theme-colored background.
///
/// ```swift
/// ErrorBanner("Something went wrong. Please try again.")
/// ```
public struct ErrorBanner: View {
    private let message: String
    @Environment(\.designTheme) private var theme

    /// Creates an error banner.
    public init(_ message: String) {
        self.message = message
    }

    public var body: some View {
        Text(message)
            .lineLimit(2)
            .font(theme.typography.footnote)
            .foregroundStyle(theme.colors.error)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(theme.spacing.oneAndHalfUnits)
            .background(
                theme.colors.error.opacity(0.08),
                in: RoundedRectangle(cornerRadius: theme.radius.oneUnit, style: .continuous)
            )
    }
}

#Preview("Design Error Banner") {
    PreviewContent { theme in
        ErrorBanner("Something went wrong. Please try again.")
            .padding(theme.spacing.twoUnits)
    }
}
