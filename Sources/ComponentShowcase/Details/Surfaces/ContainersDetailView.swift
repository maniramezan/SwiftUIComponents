import Components
import DesignSystem
import SwiftUI

struct ContainersDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Card") {
                Container(style: .card) {
                    Text("Card container content").frame(maxWidth: .infinity)
                }
            }

            ShowcaseSection("Elevated") {
                Container(style: .elevated) {
                    Text("Elevated container content").frame(maxWidth: .infinity)
                }
            }

            ShowcaseSection("Outlined") {
                Container(style: .outlined) {
                    Text("Outlined container content").frame(maxWidth: .infinity)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ContainersDetailView()
            .padding()
    }
}
