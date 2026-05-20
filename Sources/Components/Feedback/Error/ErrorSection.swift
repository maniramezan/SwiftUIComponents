import DesignSystem
import SwiftUI

/// Error display wrapped in a `List`/`Form` section.
///
/// ```swift
/// Form {
///     ErrorSection(message: "Could not load data.")
/// }
/// ```
public struct ErrorSection: View {
    private let title: String
    private let message: String
    @Environment(\.designTheme) private var theme

    /// Creates an error section with the default "Error" header.
    public init(message: String) {
        self.title = String(localized: Strings.ErrorView.defaultTitle)
        self.message = message
    }

    /// Creates an error section with a custom header.
    public init(title: String, message: String) {
        self.title = title
        self.message = message
    }

    public var body: some View {
        Section(title) {
            Text(message)
                .font(theme.typography.footnote)
                .foregroundStyle(theme.colors.error)
        }
    }
}

#Preview("Design Error Section") {
    Form {
        ErrorSection(message: "Could not load data. Check your connection.")
    }
}
