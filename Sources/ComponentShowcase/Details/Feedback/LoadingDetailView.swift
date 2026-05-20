import Components
import DesignSystem
import SwiftUI

struct LoadingDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("With message") {
                LoadingView("Fetching components…")
            }

            ShowcaseSection("Without message") {
                LoadingView()
            }
        }
    }
}

#Preview {
    ScrollView {
        LoadingDetailView()
            .padding()
    }
}
