import DesignSystem
import SwiftUI

/// Themed empty state for list and content placeholders.
public struct DesignEmptyStateView<Action: View>: View {
    private let title: String
    private let message: String?
    private let systemImage: String?
    @ViewBuilder private let action: Action
    @Environment(\.designTheme) private var theme

    /// Creates an empty state view.
    public init(
        title: String,
        message: String? = nil,
        systemImage: String? = nil,
        @ViewBuilder action: () -> Action
    ) {
        self.title = title
        self.message = message
        self.systemImage = systemImage
        self.action = action()
    }

    public var body: some View {
        VStack(spacing: theme.spacing.oneAndHalfUnits) {
            if let systemImage {
                Image(systemName: systemImage)
                    .font(theme.typography.title)
                    .foregroundStyle(theme.colors.textTertiary)
            }
            Text(title)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)
                .multilineTextAlignment(.center)
            if let message {
                Text(message)
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            action
                .padding(.top, theme.spacing.oneUnit)
        }
        .frame(maxWidth: .infinity)
        .padding(theme.spacing.threeUnits)
        .accessibilityElement(children: .combine)
    }
}

#Preview("Design Empty State") {
    DesignEmptyStateView(
        title: "No Components",
        message: "Create your first reusable component to get started.",
        systemImage: "shippingbox"
    ) {
        DesignButton("Create Component") {}
    }
    .padding()
}
