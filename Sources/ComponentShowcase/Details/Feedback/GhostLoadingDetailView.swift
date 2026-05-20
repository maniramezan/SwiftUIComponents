import Components
import DesignSystem
import SwiftUI

struct GhostLoadingDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Article card skeleton") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    GhostLoadingBlock(width: 120, height: 12)
                    GhostLoadingBlock(height: 20)
                    GhostLoadingBlock(height: 16)
                    GhostLoadingBlock(width: 200, height: 16)
                    GhostLoadingBlock(height: 100, cornerRadius: theme.radius.oneAndHalfUnits)
                }
                .accessibilityLabel("Loading")
            }

            ShowcaseSection("Profile row skeleton") {
                HStack(spacing: theme.spacing.oneAndHalfUnits) {
                    GhostLoadingBlock(width: 48, height: 48, cornerRadius: 24)
                    VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
                        GhostLoadingBlock(width: 140, height: 14)
                        GhostLoadingBlock(width: 90, height: 12)
                    }
                }
                .accessibilityLabel("Loading")
            }
        }
    }
}

#Preview {
    ScrollView {
        GhostLoadingDetailView()
            .padding()
    }
}
