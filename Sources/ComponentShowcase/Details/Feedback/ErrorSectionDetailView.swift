import Components
import DesignSystem
import SwiftUI

struct ErrorSectionDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Message only") {
                ErrorSection(message: "No results found for your search.")
            }

            ShowcaseSection("Title and message") {
                ErrorSection(
                    title: "Connection Failed",
                    message: "We couldn't reach the server. Please try again later."
                )
            }
        }
    }
}

#Preview {
    ScrollView {
        ErrorSectionDetailView()
            .padding()
    }
}
