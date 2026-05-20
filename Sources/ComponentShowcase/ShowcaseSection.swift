import Components
import DesignSystem
import SwiftUI

/// A labelled card that wraps a showcase section's content.
///
/// Used consistently across all detail views to present a named group
/// of component variants with a headline and a card surface background.
struct ShowcaseSection<Content: View>: View {

    let title: String
    let content: Content
    @Environment(\.designTheme) private var theme

    init(_ title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneAndHalfUnits) {
            Text(title)
                .designTextStyle(.headline)
            content
        }
        .padding(theme.spacing.twoUnits)
        .frame(maxWidth: .infinity, alignment: .leading)
        .designCardSurface()
        .padding(.bottom, theme.spacing.twoUnits)
    }
}
