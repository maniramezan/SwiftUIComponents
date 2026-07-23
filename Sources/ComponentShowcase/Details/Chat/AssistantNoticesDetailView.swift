import Components
import DesignSystem
import SwiftUI

struct AssistantNoticesDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Unavailable banner — with settings CTA") {
                AssistantUnavailableBanner(
                    reason: "Turn on Apple Intelligence in Settings to use the assistant.",
                    settingsAction: .init(title: "Open Settings", action: {})
                )
            }

            ShowcaseSection("Unavailable banner — no settings CTA") {
                AssistantUnavailableBanner(
                    reason: "This feature isn't supported on this device."
                )
            }

            ShowcaseSection("Upgrade notice") {
                AssistantUpgradeNotice(
                    message: "Upgrade to Premium to get help in all languages.",
                    upgradeTitle: "Upgrade to Premium",
                    systemImage: "globe",
                    onUpgrade: {}
                )
            }

            ShowcaseSection("Disclaimer footer") {
                AssistantDisclaimerFooter(
                    text: "AI responses can be inaccurate. Always double-check important information."
                )
            }
        }
    }
}

#Preview {
    ScrollView {
        AssistantNoticesDetailView()
            .padding()
    }
}
