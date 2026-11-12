import Components
import DesignSystem
import SwiftUI

struct FloatingActionButtonDetailView: View {
    @State private var title = "Add item"
    @State private var icon = FloatingActionIcon.plus
    @State private var showsTitle = false
    @State private var disabled = false
    @State private var taps = 0
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                FloatingActionButton(showsTitle: showsTitle, action: { taps += 1 }) {
                    Label(title, systemImage: icon.rawValue)
                }
                .disabled(disabled)
                Text("Button taps: \(taps)")
                Text("Tap any demo button to increase the count.")
                    .foregroundStyle(.secondary)
            }

            ShowcaseSection("Preview settings") {
                LabeledContent("Button title") {
                    TextField("Button title", text: $title)
                        .labelsHidden()
                }
                FloatingActionIconPicker(title: "Button icon", selection: $icon)
                Toggle("Show title", isOn: $showsTitle).toggleStyle(ThemeToggleStyle())
                Toggle("Disabled", isOn: $disabled).toggleStyle(ThemeToggleStyle())
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
