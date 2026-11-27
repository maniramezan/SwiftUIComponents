import Components
import DesignSystem
import SwiftUI

struct DividerDetailView: View {
    @State private var usesCustomWidth = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Divider") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    Text("First section")
                    ThemeDivider()
                        .designTheme(
                            DefaultTheme(
                                stroke: DefaultStroke(
                                    hairline: usesCustomWidth ? theme.stroke.regular : theme.stroke.hairline
                                ),
                                colors: theme.colors
                            )
                        )
                    Text("Second section")
                }
                .font(theme.typography.body)
                .foregroundStyle(theme.colors.textPrimary)
            }

            ShowcaseSection("Controls") {
                Toggle("Use a thicker divider", isOn: $usesCustomWidth)
                    .toggleStyle(ThemeToggleStyle())
            }
        }
    }
}
