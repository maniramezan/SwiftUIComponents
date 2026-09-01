import DesignSystem
import SwiftUI

/// A prompt card for assistant limits, quotas, upgrades, or other gated
/// actions with caller-controlled primary and secondary actions.
public struct AssistantLimitPromptCard: View {
    private let message: String
    private let supportingText: String
    private let primaryActionTitle: String
    private let secondaryActionTitle: String
    private let onPrimaryAction: () -> Void
    private let onSecondaryAction: () -> Void

    /// Creates a limit or upgrade prompt.
    ///
    /// - Parameters:
    ///   - message: Localized primary explanation.
    ///   - supportingText: Localized detail about the limit or upgrade.
    ///   - primaryActionTitle: Localized title for the prominent action.
    ///   - secondaryActionTitle: Localized title for the secondary action.
    ///   - onPrimaryAction: Called when the user taps the primary action.
    ///   - onSecondaryAction: Called when the user taps the secondary action.
    public init(
        message: String,
        supportingText: String,
        primaryActionTitle: String,
        secondaryActionTitle: String,
        onPrimaryAction: @escaping () -> Void,
        onSecondaryAction: @escaping () -> Void
    ) {
        self.message = message
        self.supportingText = supportingText
        self.primaryActionTitle = primaryActionTitle
        self.secondaryActionTitle = secondaryActionTitle
        self.onPrimaryAction = onPrimaryAction
        self.onSecondaryAction = onSecondaryAction
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            Text(message)
                .font(theme.typography.subheadline.weight(.medium))
                .foregroundStyle(theme.colors.textPrimary)
            Text(supportingText)
                .font(theme.typography.subheadline)
                .foregroundStyle(theme.colors.textSecondary)
            Button(primaryActionTitle, action: onPrimaryAction)
                .font(theme.typography.subheadline.weight(.medium))
                .buttonStyle(.borderedProminent)
                .tint(theme.colors.primary)
            Button(secondaryActionTitle, action: onSecondaryAction)
                .font(theme.typography.subheadline.weight(.medium))
                .buttonStyle(.bordered)
        }
        .designNoticeCard(background: theme.colors.containerSecondary)
    }
}

#Preview("Assistant limit prompt") {
    PreviewContent { theme in
        AssistantLimitPromptCard(
            message: "You've reached today's assistant limit.",
            supportingText: "Upgrade for unlimited help.",
            primaryActionTitle: "Upgrade",
            secondaryActionTitle: "Not now",
            onPrimaryAction: {},
            onSecondaryAction: {}
        )
        .padding(theme.spacing.twoUnits)
    }
}
