import Components
import SwiftUI
import Testing

@MainActor
@Suite("AssistantUpgradeNotice")
struct AssistantUpgradeNoticeTests {

    @Test("default systemImage constructs")
    func defaultIcon() {
        _ = AssistantUpgradeNotice(
            message: "Upgrade to Premium to get help in all languages.",
            upgradeTitle: "Upgrade to Premium",
            onUpgrade: {}
        )
    }

    @Test("custom systemImage constructs")
    func customIcon() {
        _ = AssistantUpgradeNotice(
            message: "Upgrade to Premium to get help in all languages.",
            upgradeTitle: "Upgrade to Premium",
            systemImage: "globe",
            onUpgrade: {}
        )
    }

    // MARK: - Rendering

    @Test("renders with default icon")
    func defaultIconRenders() {
        renderForCoverage(
            AssistantUpgradeNotice(
                message: "Upgrade to Premium to get help in all languages.",
                upgradeTitle: "Upgrade to Premium",
                onUpgrade: {}
            )
        )
    }

    @Test("renders with custom icon")
    func customIconRenders() {
        renderForCoverage(
            AssistantUpgradeNotice(
                message: "Upgrade to Premium to get help in all languages.",
                upgradeTitle: "Upgrade to Premium",
                systemImage: "globe",
                onUpgrade: {}
            )
        )
    }
}
