import Components
import DesignSystem
import SwiftUI

struct CompactActionDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Single action") {
                CompactActionButton(title: "Add to Favorites", icon: "heart") {}
            }

            ShowcaseSection("Action row") {
                HStack(spacing: theme.spacing.oneUnit) {
                    CompactActionButton(title: "Translate", icon: "globe") {}
                    CompactActionButton(title: "Simplify", icon: "wand.and.stars") {}
                    CompactActionButton(title: "Explain", icon: "lightbulb") {}
                }
            }

            ShowcaseSection("Disabled") {
                CompactActionButton(title: "Locked", icon: "lock", isDisabled: true) {}
            }
        }
    }
}

#Preview {
    ScrollView {
        CompactActionDetailView()
            .padding()
    }
}
