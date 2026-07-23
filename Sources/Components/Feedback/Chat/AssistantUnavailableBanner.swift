import DesignSystem
import SwiftUI

/// A top banner shown when an assistant feature's underlying provider is
/// unavailable — e.g. an on-device model requires a system setting the user
/// hasn't enabled, or the feature is unsupported on this device/region.
///
/// Shows an optional settings action when the caller supplies one.
///
/// The caller resolves its own localized reason and button title; this
/// component owns no copy of its own.
///
/// ```swift
/// AssistantUnavailableBanner(
///     reason: "Turn on Apple Intelligence in Settings to use the assistant.",
///     settingsAction: .init(title: "Open Settings", action: { openSystemSettings() })
/// )
/// ```
public struct AssistantUnavailableBanner: View {
    private let reason: String
    private let settingsAction: SettingsAction?

    /// Creates an unavailable-provider banner.
    ///
    /// - Parameters:
    ///   - reason: The localized explanation shown to the user.
    ///   - settingsAction: An optional localized settings action. Supply this
    ///     only when the unavailable condition is actionable in Settings.
    public init(reason: String, settingsAction: SettingsAction? = nil) {
        self.reason = reason
        self.settingsAction = settingsAction
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: theme.spacing.oneUnit) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(theme.colors.warning)
                Text(reason)
                    .font(theme.typography.subheadline)
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                if let settingsAction {
                    Button(settingsAction.title, action: settingsAction.action)
                        .font(theme.typography.subheadline.weight(.medium))
                        .buttonStyle(.bordered)
                        .controlSize(.small)
                }
            }
            .frame(maxWidth: .infinity)
            .padding(theme.spacing.twoUnits)
            .background(theme.colors.containerSecondary)
            Divider()
        }
    }

    /// A localized action that opens the relevant settings screen.
    public struct SettingsAction {
        fileprivate let title: String
        fileprivate let action: () -> Void

        /// Creates a settings action.
        ///
        /// - Parameters:
        ///   - title: Localized button title.
        ///   - action: Called when the user taps the button.
        public init(title: String, action: @escaping () -> Void) {
            self.title = title
            self.action = action
        }
    }
}

#Preview("Assistant unavailable banner") {
    PreviewContent { _ in
        AssistantUnavailableBanner(
            reason: "Turn on Apple Intelligence in Settings to use the assistant.",
            settingsAction: .init(title: "Open Settings", action: {})
        )
    }
}

#Preview("Assistant unavailable banner — no settings CTA") {
    PreviewContent { _ in
        AssistantUnavailableBanner(
            reason: "This feature isn't supported on this device."
        )
    }
}
