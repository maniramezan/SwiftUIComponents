import Components
import DesignSystem
import SwiftUI

struct ErrorBannerDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Short message") {
                ErrorBanner("Something went wrong.")
            }

            ShowcaseSection("Long message") {
                ErrorBanner("Unable to load your data. Please check your connection and try again.")
            }
        }
    }
}
