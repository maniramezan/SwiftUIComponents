import Components
import DesignSystem
import SwiftUI

struct BadgesDetailView: View {
    @State private var label = "Status"
    @State private var prominent = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                ShowcaseTextField("Label", text: $label)
                Toggle("Prominent", isOn: $prominent)
                Badge(label, isProminent: prominent)
            }

            ShowcaseSection("Standard") {
                HStack(spacing: theme.spacing.oneUnit) {
                    Badge("Beta")
                    Badge("v2.0")
                    Badge("Draft")
                }
            }

            ShowcaseSection("Prominent") {
                HStack(spacing: theme.spacing.oneUnit) {
                    Badge("New", isProminent: true)
                    Badge("Hot", isProminent: true)
                    Badge("Sale", isProminent: true)
                }
            }

            ShowcaseSection("Mixed") {
                HStack(spacing: theme.spacing.oneUnit) {
                    Badge("Stable")
                    Badge("New", isProminent: true)
                    Badge("Deprecated")
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        BadgesDetailView()
            .padding()
    }
}
