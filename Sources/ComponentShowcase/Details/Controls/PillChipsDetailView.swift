import Components
import DesignSystem
import SwiftUI

struct PillChipsDetailView: View {
    private let options = ["All", "Recent", "Favorites", "Archived", "Shared"]
    @State private var selected = "All"
    @State private var horizontalPadding = 16.0
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Interactive filter chips") {
                FlowLayout(spacing: theme.spacing.oneUnit) {
                    ForEach(options, id: \.self) { option in
                        PillChip(option, isSelected: selected == option) {
                            selected = option
                        }
                    }
                }
            }

            ShowcaseSection("Static states") {
                HStack(spacing: theme.spacing.oneUnit) {
                    PillChip("Unselected", isSelected: false) {}
                    PillChip("Selected", isSelected: true) {}
                }
            }

            ShowcaseSection("Pill metrics modifier") {
                VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
                    Text("Custom pill metrics")
                        .designPillMetrics(horizontalPadding: horizontalPadding)
                        .designCapsuleSurface(isSelected: true)

                    LabeledContent("Horizontal padding") {
                        Slider(value: $horizontalPadding, in: 0...40)
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        PillChipsDetailView()
            .padding()
    }
}
