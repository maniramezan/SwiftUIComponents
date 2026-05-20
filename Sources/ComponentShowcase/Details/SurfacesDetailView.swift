import Components
import DesignSystem
import SwiftUI

struct SurfacesDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Card surface") {
                Text("Content inside a card surface")
                    .padding(theme.spacing.twoUnits)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .designCardSurface()
            }

            ShowcaseSection("Capsule surface") {
                HStack(spacing: theme.spacing.oneUnit) {
                    Text("Default")
                        .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                        .padding(.vertical, theme.spacing.oneUnit)
                        .designCapsuleSurface()
                    Text("Selected")
                        .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                        .padding(.vertical, theme.spacing.oneUnit)
                        .designCapsuleSurface(isSelected: true)
                }
            }

            ShowcaseSection("Input surface") {
                Text("Type something here…")
                    .foregroundStyle(theme.colors.textSecondary)
                    .padding(theme.spacing.twoUnits)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .designInputSurface()
            }
        }
    }
}
