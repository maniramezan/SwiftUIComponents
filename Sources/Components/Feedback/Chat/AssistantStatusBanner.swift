import DesignSystem
import SwiftUI

/// A blocking assistant-status banner for unavailable providers, degraded
/// service, or errors that prevent the assistant from responding.
///
/// The caller supplies localized text; the banner applies the theme's error
/// and on-error tokens.
public struct AssistantStatusBanner: View {
    private let message: String

    /// Creates a blocking assistant-status banner.
    ///
    /// - Parameter message: Localized status text explaining the problem.
    public init(message: String) {
        self.message = message
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        Text(message)
            .font(theme.typography.subheadline)
            .foregroundStyle(theme.colors.onError)
            .designNoticeCard(background: theme.colors.error)
    }
}

#Preview("Assistant status banner") {
    PreviewContent { theme in
        AssistantStatusBanner(message: "The assistant is temporarily unavailable.")
            .padding(theme.spacing.twoUnits)
    }
}
