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
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.oneUnit) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(theme.typography.footnote)
                .accessibilityHidden(true)
            Text(message)
                .font(theme.typography.footnote)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .foregroundStyle(theme.colors.error)
        .designNoticeCard(
            background: theme.colors.error.opacity(0.08),
            cornerRadius: theme.radius.oneUnit,
            padding: theme.spacing.oneAndHalfUnits
        )
        .accessibilityElement(children: .combine)
        .accessibilityLabel(Text(Strings.ErrorView.accessibilityLabel(message)))
    }
}

#Preview("Design Error Banner") {
    PreviewContent { theme in
        ErrorBanner("Something went wrong. Please try again.")
            .padding(theme.spacing.twoUnits)
    }
}
