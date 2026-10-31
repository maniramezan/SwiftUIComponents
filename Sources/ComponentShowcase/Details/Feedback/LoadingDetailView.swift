import Components
import DesignSystem
import SwiftUI

struct LoadingDetailView: View {
    @State private var message = "Loading items"
    @State private var showsMessage = true
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                ShowcaseTextField("Message", text: $message)
                Toggle("Message", isOn: $showsMessage)
                LoadingView(showsMessage ? message : nil)
            }

            ShowcaseSection("With message") {
                LoadingView("Fetching components…")
            }

            ShowcaseSection("Without message") {
                LoadingView()
            }
        }
    }
}

#Preview {
    ScrollView {
        LoadingDetailView()
            .padding()
    }
}
