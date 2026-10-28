import Components
import DesignSystem
import SwiftUI

struct CompactActionDetailView: View {
    @State private var title = "Action"
    @State private var icon = "star"
    @State private var disabled = false
    @State private var taps = 0
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                TextField("Title", text: $title)
                TextField("System image", text: $icon)
                Toggle("Disabled", isOn: $disabled)
                CompactActionButton(title: title, icon: icon, isDisabled: disabled) { taps += 1 }
                Text("Actions: \(taps)")
            }

            ShowcaseSection("Single action") {
                CompactActionButton(title: "Add to Favorites", icon: "heart") {}
            }

            ShowcaseSection("Action row") {
                HStack(spacing: theme.spacing.oneUnit) {
                    CompactActionButton(title: "Share", icon: "square.and.arrow.up") {}
                    CompactActionButton(title: "Simplify", icon: "wand.and.stars") {}
                    CompactActionButton(title: "Details", icon: "info.circle") {}
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
