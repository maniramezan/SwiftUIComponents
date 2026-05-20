import Components
import DesignSystem
import SwiftUI

struct TextStylesDetailView: View {
    @Environment(\.designTheme) private var theme

    private let styles: [(label: String, role: TextRole)] = [
        ("Title", .title),
        ("Headline", .headline),
        ("Body", .body),
        ("Secondary", .secondary),
        ("Caption", .caption),
        ("Error", .error),
    ]

    var body: some View {
        ShowcaseSection("All text roles") {
            VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                ForEach(styles, id: \.label) { item in
                    HStack(alignment: .firstTextBaseline) {
                        Text(item.label)
                            .designTextStyle(item.role)
                        Spacer()
                        Text(".\(item.label.lowercased().replacingOccurrences(of: " ", with: ""))")
                            .font(theme.typography.caption)
                            .foregroundStyle(theme.colors.textSecondary)
                    }
                    if item.label != styles.last?.label {
                        Divider()
                    }
                }
            }
        }
    }
}
