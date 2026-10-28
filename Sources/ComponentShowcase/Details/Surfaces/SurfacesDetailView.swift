import Components
import DesignSystem
import SwiftUI

struct SurfacesDetailView: View {
    @State private var text = "Sample surface"
    @State private var stroke = true
    @State private var selected = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                TextField("Content", text: $text)
                Toggle("Card border", isOn: $stroke)
                Toggle("Selected capsule", isOn: $selected)
                Text(text).padding().designCardSurface(showStroke: stroke)
                Text(text).designPillMetrics().designCapsuleSurface(isSelected: selected)
            }

            ShowcaseSection("Card surface") {
                Text("Content inside a card surface")
                    .padding(theme.spacing.twoUnits)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .designCardSurface()
            }

            ShowcaseSection("Capsule surface") {
                HStack(spacing: theme.spacing.oneUnit) {
                    Text("Default")
                        .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                        .padding(.vertical, theme.spacing.oneUnit)
                        .designCapsuleSurface()
                    Text("Selected")
                        .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                        .padding(.vertical, theme.spacing.oneUnit)
                        .designCapsuleSurface(isSelected: true)
                }
            }

            ShowcaseSection("Input surface") {
                Text("Type something here…")
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(theme.spacing.twoUnits)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .designInputSurface()
            }
        }
    }
}

#Preview {
    ScrollView {
        SurfacesDetailView()
            .padding()
    }
}
