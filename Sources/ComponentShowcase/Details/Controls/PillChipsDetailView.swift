import Components
import DesignSystem
import SwiftUI

struct PillChipsDetailView: View {
    private let options = ["All", "Recent", "Favorites", "Archived", "Shared"]
    @State private var selected = "All"
    @State private var showsActionValue = true
    @State private var emphasizesActionLabel = true
    @State private var actionTapCount = 0
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

            ShowcaseSection("Action Pill") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    ActionPill(action: { actionTapCount += 1 }) {
                        HStack(spacing: theme.spacing.halfUnit) {
                            Text("Status")
                                .fontWeight(emphasizesActionLabel ? .semibold : .regular)
                            if showsActionValue {
                                Text("Active")
                            }
                        }
                    }
                    Text("Tap count: \(actionTapCount)")
                        .font(theme.typography.caption)

                    Toggle("Show value", isOn: $showsActionValue)
                        .toggleStyle(ThemeToggleStyle())
                    Toggle("Emphasize label", isOn: $emphasizesActionLabel)
                        .toggleStyle(ThemeToggleStyle())
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
