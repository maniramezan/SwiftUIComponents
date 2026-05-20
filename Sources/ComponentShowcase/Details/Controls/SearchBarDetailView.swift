import Components
import DesignSystem
import SwiftUI

struct SearchBarDetailView: View {
    @State private var text = ""
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Default") {
                SearchBar(text: $text, placeholder: "Search components…")
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
