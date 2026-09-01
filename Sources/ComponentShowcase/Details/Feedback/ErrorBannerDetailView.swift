import Components
import DesignSystem
import SwiftUI

struct ErrorBannerDetailView: View {
    @State private var noticeBackground = Color.blue.opacity(0.15)
    @State private var usesCustomCornerRadius = false
    @State private var cornerRadius = 12.0
    @State private var usesCustomPadding = false
    @State private var noticePadding = 16.0
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Short message") {
                ErrorBanner("Something went wrong.")
            }

            ShowcaseSection("Long message") {
                ErrorBanner("Unable to load your data. Please check your connection and try again.")
            }

            ShowcaseSection("Notice card modifier") {
                VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
                    Text("Configurable notice")
                        .designNoticeCard(
                            background: noticeBackground,
                            cornerRadius: usesCustomCornerRadius ? cornerRadius : nil,
                            padding: usesCustomPadding ? noticePadding : nil
                        )

                    ColorPicker("Background", selection: $noticeBackground)

                    Toggle("Override corner radius", isOn: $usesCustomCornerRadius)
                    LabeledContent("Corner radius") {
                        Slider(value: $cornerRadius, in: 0...32)
                    }
                    .disabled(!usesCustomCornerRadius)

                    Toggle("Override padding", isOn: $usesCustomPadding)
                    LabeledContent("Padding") {
                        Slider(value: $noticePadding, in: 0...32)
                    }
                    .disabled(!usesCustomPadding)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ErrorBannerDetailView()
            .padding()
    }
}
