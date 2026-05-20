import Components
import DesignSystem
import SwiftUI

struct PillChipsDetailView: View {
    private let options = ["All", "Recent", "Favorites", "Archived", "Shared"]
    @State private var selected = "All"
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
        }
    }
}
