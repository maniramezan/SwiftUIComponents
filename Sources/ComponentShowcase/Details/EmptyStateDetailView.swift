import Components
import DesignSystem
import SwiftUI

struct EmptyStateDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("With action button") {
                EmptyStateView(
                    title: "No Results",
                    message: "Try adjusting your search or filters.",
                    systemImage: "magnifyingglass"
                ) {
                    ThemeButton("Reset Filters", role: .secondary) {}
                }
            }

            ShowcaseSection("Without action") {
                EmptyStateView(
                    title: "All Caught Up",
                    message: "You have no new notifications.",
                    systemImage: "bell.slash"
                )
            }
        }
    }
}
