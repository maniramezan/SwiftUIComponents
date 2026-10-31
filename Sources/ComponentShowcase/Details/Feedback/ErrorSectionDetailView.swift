import Components
import DesignSystem
import SwiftUI

struct ErrorSectionDetailView: View {
    @State private var title = "Error"
    @State private var message = "Unable to load items."
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                ShowcaseTextField("Title", text: $title)
                ShowcaseTextField("Message", text: $message)
                ErrorSection(title: title, message: message)
            }

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
