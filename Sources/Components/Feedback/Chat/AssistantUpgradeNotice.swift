import DesignSystem
import SwiftUI

/// A notice + call-to-action shown when an assistant feature is degraded or
/// limited under the current plan/tier and the caller wants to prompt an
/// upgrade — e.g. "the free tier can't respond in your language; upgrade for
/// full support."
///
/// The caller resolves its own localized copy; this component owns no copy
/// of its own.
///
/// ```swift
/// AssistantUpgradeNotice(
///     message: "Upgrade to Premium to get help in all languages.",
///     upgradeTitle: "Upgrade to Premium",
///     onUpgrade: { presentPaywall() }
/// )
/// ```
public struct AssistantUpgradeNotice: View {
    private let message: String
    private let upgradeTitle: String
    private let systemImage: String
    private let onUpgrade: () -> Void

    /// Creates an assistant upgrade notice.
    ///
    /// - Parameters:
    ///   - message: The localized explanation shown to the user.
    ///   - upgradeTitle: The upgrade button's title.
    ///   - systemImage: The leading SF Symbol shown next to `message`.
    ///     Defaults to `"sparkles"`.
    ///   - onUpgrade: Called when the user taps the upgrade button.
    public init(
        message: String,
        upgradeTitle: String,
        systemImage: String = "sparkles",
        onUpgrade: @escaping () -> Void
    ) {
        self.message = message
        self.upgradeTitle = upgradeTitle
        self.systemImage = systemImage
        self.onUpgrade = onUpgrade
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            HStack(spacing: theme.spacing.oneUnit) {
                Image(systemName: systemImage)
                    .foregroundStyle(theme.colors.primary)
                Text(message)
                    .font(theme.typography.subheadline.weight(.medium))
                    .foregroundStyle(theme.colors.textPrimary)
            }
            Button(upgradeTitle, action: onUpgrade)
                .font(theme.typography.subheadline.weight(.medium))
                .buttonStyle(.bordered)
                .controlSize(.small)
        }
        .designNoticeCard(background: theme.colors.containerSecondary)
    }
}

#Preview("Assistant upgrade notice") {
    PreviewContent { theme in
        AssistantUpgradeNotice(
            message: "Upgrade to Premium to get help in all languages.",
            upgradeTitle: "Upgrade to Premium",
            systemImage: "globe",
            onUpgrade: {}
        )
        .padding(theme.spacing.twoUnits)
    }
}
