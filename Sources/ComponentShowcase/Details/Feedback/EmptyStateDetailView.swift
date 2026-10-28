import Components
import DesignSystem
import SwiftUI

struct EmptyStateDetailView: View {
    @State private var title = "No items"
    @State private var message = "Try another selection."
    @State private var symbol = "tray"
    @State private var showsMessage = true
    @State private var showsSymbol = true
    @State private var showsAction = true
    @State private var taps = 0
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                TextField("Title", text: $title)
                TextField("Message", text: $message)
                TextField("Symbol", text: $symbol)
                Toggle("Message", isOn: $showsMessage)
                Toggle("Symbol", isOn: $showsSymbol)
                Toggle("Action", isOn: $showsAction)
                EmptyStateView(
                    title: title, message: showsMessage ? message : nil,
                    systemImage: showsSymbol ? symbol : nil
                ) {
                    if showsAction { Button("Action") { taps += 1 } }
                }
                Text("Actions: \(taps)")
            }

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

#Preview {
    ScrollView {
        EmptyStateDetailView()
            .padding()
    }
}
