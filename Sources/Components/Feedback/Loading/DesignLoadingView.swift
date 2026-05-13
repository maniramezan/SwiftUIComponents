import DesignSystem
import SwiftUI

/// Themed loading indicator with optional message.
public struct DesignLoadingView: View {
    private let message: String?
    @Environment(\.designTheme) private var theme

    /// Creates a loading view.
    public init(_ message: String? = nil) {
        self.message = message
    }

    public var body: some View {
        VStack(spacing: theme.spacing.oneAndHalfUnits) {
            ProgressView()
            if let message {
                Text(message)
                    .font(theme.typography.footnote)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.threeUnits)
        .accessibilityElement(children: .combine)
    }
}
