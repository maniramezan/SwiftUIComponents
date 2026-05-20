import Components
import DesignSystem
import SwiftUI

struct AdaptiveSurfaceDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Adaptive surface (auto-selects card or input based on context)") {
                VStack(spacing: theme.spacing.oneAndHalfUnits) {
                    Text("Variant A")
                        .padding(theme.spacing.twoUnits)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .designAdaptiveSurface()

                    Text("Variant B")
                        .padding(theme.spacing.twoUnits)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .designAdaptiveSurface()
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        AdaptiveSurfaceDetailView()
            .padding()
    }
}
