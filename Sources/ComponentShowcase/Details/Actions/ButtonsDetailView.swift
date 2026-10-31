import Components
import DesignSystem
import SwiftUI

struct ButtonsDetailView: View {
    @State private var title = "Action"
    @State private var role = 0
    @State private var disabled = false
    @State private var prominent = false
    @State private var isLoading = false
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                ShowcaseTextField("Title", text: $title)
                ShowcasePicker("Role", selection: $role) {
                    Text("Primary").tag(0)
                    Text("Secondary").tag(1)
                    Text("Tertiary").tag(2)
                    Text("Destructive").tag(3)
                }
                Toggle("Disabled", isOn: $disabled)
                Toggle("Prominent native button", isOn: $prominent)
                ThemeButton(
                    title, role: [ThemeButtonRole.primary, .secondary, .tertiary, .destructive][role],
                    isLoading: isLoading
                ) {}
                .disabled(disabled)
                Button(title) {}.designAdaptiveButtonStyle(prominent: prominent).disabled(disabled)
            }

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
