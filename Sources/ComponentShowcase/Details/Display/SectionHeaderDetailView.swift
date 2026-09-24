import Components
import DesignSystem
import SwiftUI

/// Showcases ``SectionHeader`` with live controls for its title, action, and font.
struct SectionHeaderDetailView: View {

    fileprivate enum TitleFontChoice: String, CaseIterable, Identifiable {
        case theme = "Theme (headline)"
        case title3 = "Title 3"
        case caption = "Caption"

        var id: String { rawValue }
    }

    @State private var title = "Recent Items"
    @State private var showsAction = true
    @State private var fontChoice: TitleFontChoice = .theme
    @State private var actionCount = 0
    @Environment(\.designTheme) private var theme

    private var titleFont: Font? {
        switch fontChoice {
        case .theme: nil
        case .title3: theme.typography.title3Semibold
        case .caption: theme.typography.captionSemibold
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Configurable header") {
                SectionHeader(
                    title: title,
                    // SectionHeader omits the button when either the label or the action is nil.
                    actionLabel: showsAction ? "See All" : nil,
                    onAction: { actionCount += 1 },
                    titleFont: titleFont
                )
                Text("Action taps: \(actionCount)")
                    .designTextStyle(.caption)
            }

            ShowcaseSection("Controls") {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                Toggle("Trailing action", isOn: $showsAction)
                    .toggleStyle(ThemeToggleStyle())
                Picker("Title font", selection: $fontChoice) {
                    ForEach(TitleFontChoice.allCases) { choice in
                        Text(choice.rawValue).tag(choice)
                    }
                }
            }

            ShowcaseSection("Flow layout below a header") {
                SectionHeader(title: "Tags")
                FlowLayout(spacing: theme.spacing.oneUnit, lineSpacing: theme.spacing.oneUnit) {
                    ForEach(["Alpha", "Beta", "Gamma", "Delta", "Epsilon", "Zeta"], id: \.self) { tag in
                        Badge(tag)
                    }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        SectionHeaderDetailView()
            .padding()
    }
}
