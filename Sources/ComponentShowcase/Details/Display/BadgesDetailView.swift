import Components
import DesignSystem
import SwiftUI

struct BadgesDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
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
