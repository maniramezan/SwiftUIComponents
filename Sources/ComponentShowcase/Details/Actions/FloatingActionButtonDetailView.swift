import Components
import DesignSystem
import SwiftUI

struct FloatingActionButtonDetailView: View {
    @State private var title = "Add item"
    @State private var symbol = "plus"
    @State private var showsTitle = false
    @State private var disabled = false
    @State private var taps = 0
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                TextField("Title", text: $title)
                TextField("System image", text: $symbol)
                Toggle("Show title", isOn: $showsTitle).toggleStyle(ThemeToggleStyle())
                Toggle("Disabled", isOn: $disabled).toggleStyle(ThemeToggleStyle())
                FloatingActionButton(showsTitle: showsTitle, action: { taps += 1 }) {
                    Label(title, systemImage: symbol)
                }
                .disabled(disabled)
                Text("Actions: \(taps)")
            }

            ShowcaseSection("Styles") {
                HStack(spacing: theme.spacing.twoUnits) {
                    FloatingActionButton(action: { taps += 1 }) {
                        Label("Add item", systemImage: "plus")
                    }
                    FloatingActionButton(showsTitle: true, action: { taps += 1 }) {
                        Label("Add item", systemImage: "plus")
                    }
                }
            }
        }
    }
}

#Preview {
    FloatingActionButtonDetailView()
        .designTheme(DefaultTheme())
}
