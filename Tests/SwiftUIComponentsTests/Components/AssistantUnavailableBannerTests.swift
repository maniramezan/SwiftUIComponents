import Components
import SwiftUI
import Testing

@MainActor
@Suite("AssistantUnavailableBanner")
struct AssistantUnavailableBannerTests {

    @Test("localized reason can explicitly include a settings action")
    func explicitSettingsAction() {
        _ = AssistantUnavailableBanner(
            reason: "Activez cette fonctionnalite dans Reglages.",
            settingsAction: .init(title: "Ouvrir Reglages", action: {})
        )
    }

    @Test("unavailable reason can omit a settings action")
    func noSettingsAction() {
        _ = AssistantUnavailableBanner(reason: "This feature isn't supported on this device.")
    }

    @Test("banner with explicit settings CTA renders")
    func settingsActionRenders() {
        renderForCoverage(
            AssistantUnavailableBanner(
                reason: "Activez cette fonctionnalite dans Reglages.",
                settingsAction: .init(title: "Ouvrir Reglages", action: {})
            )
        )
    }

    @Test("banner without settings CTA renders")
    func noSettingsActionRenders() {
        renderForCoverage(AssistantUnavailableBanner(reason: "This feature isn't supported on this device."))
    }
}
