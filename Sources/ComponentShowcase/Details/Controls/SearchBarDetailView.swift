import Components
import DesignSystem
import SwiftUI

struct SearchBarDetailView: View {
    @State private var placeholder = "Search items"
    @State private var focused = false
    @State private var submits = 0
    @State private var text = ""
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Controls") {
                ShowcaseTextField("Placeholder", text: $placeholder)
                Toggle("Focus search", isOn: $focused)
                Text("Submissions: \(submits)")
            }

            ShowcaseSection("Default") {
                SearchBar(text: $text, placeholder: placeholder, isFocused: $focused, onSubmit: { submits += 1 })
            }

            ShowcaseSection("With text") {
                SearchBar(text: .constant("SwiftUI"), placeholder: "Search…")
            }
        }
    }
}

#Preview {
    ScrollView {
        SearchBarDetailView()
            .padding()
    }
}
