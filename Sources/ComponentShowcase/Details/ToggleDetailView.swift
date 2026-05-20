import Components
import DesignSystem
import SwiftUI

struct ToggleDetailView: View {
    @State private var isOn = true
    @State private var isDisabled = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Interactive") {
                Toggle("Enable notifications", isOn: $isOn)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Show previews", isOn: .constant(false))
                    .toggleStyle(ThemeToggleStyle())
            }

            ShowcaseSection("Disabled") {
                Toggle("Locked setting", isOn: .constant(true))
                    .toggleStyle(ThemeToggleStyle())
                    .disabled(true)
            }
        }
    }
}
