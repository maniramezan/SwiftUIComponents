import Components
import DesignSystem
import SwiftUI

struct ButtonsDetailView: View {
    @State private var isLoading = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Roles") {
                VStack(spacing: theme.spacing.oneUnit) {
                    ThemeButton("Primary") {}
                    ThemeButton("Secondary", role: .secondary) {}
                    ThemeButton("Tertiary", role: .tertiary) {}
                    ThemeButton("Destructive", role: .destructive) {}
                }
            }

            ShowcaseSection("Loading state") {
                VStack(spacing: theme.spacing.oneUnit) {
                    ThemeButton(isLoading ? "Loading…" : "Tap to load", isLoading: isLoading) {
                        isLoading.toggle()
                    }
                    if isLoading {
                        Button("Stop") { isLoading = false }
                            .buttonStyle(.plain)
                            .font(theme.typography.caption)
                    }
                }
            }

            ShowcaseSection("Disabled") {
                ThemeButton("Disabled") {}
                    .disabled(true)
            }
        }
    }
}

#Preview {
    ScrollView {
        ButtonsDetailView()
            .padding()
    }
}
