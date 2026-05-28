import DesignSystem
import SwiftUI

// MARK: - Previews

private struct TitledPageViewPreviewPage: Identifiable {
    let id: Int
    let title: String
    let symbol: String
}

private let titledPageViewPreviewPages: [TitledPageViewPreviewPage] = [
    .init(id: 0, title: "Best of 2025", symbol: "sparkles"),
    .init(id: 1, title: "Spotlight: Health", symbol: "heart.fill"),
    .init(id: 2, title: "Travel Companions", symbol: "airplane"),
    .init(id: 3, title: "Quiet Tools", symbol: "moon.stars.fill"),
]

#Preview("Dots indicator") {
    @Previewable @State var selection = 0
    PreviewContent { theme in
        TitledPageView(
            titledPageViewPreviewPages,
            selection: $selection,
            title: \TitledPageViewPreviewPage.title
        ) { page in
            VStack(spacing: theme.spacing.oneUnit) {
                Image(systemName: page.symbol)
                    .font(theme.typography.largeTitle)
                Text(page.title)
                    .designTextStyle(.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .designCardSurface()
            .padding(.horizontal, theme.spacing.oneUnit)
        }
        .frame(height: 240)
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Bar indicator") {
    @Previewable @State var selection = 0
    PreviewContent { theme in
        TitledPageView(
            titledPageViewPreviewPages,
            selection: $selection,
            title: \TitledPageViewPreviewPage.title,
            indicatorStyle: .bar
        ) { page in
            VStack(spacing: theme.spacing.oneUnit) {
                Image(systemName: page.symbol)
                    .font(theme.typography.largeTitle)
                Text(page.title)
                    .designTextStyle(.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .designCardSurface()
            .padding(.horizontal, theme.spacing.oneUnit)
        }
        .frame(height: 240)
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Next-only peek") {
    @Previewable @State var selection = 0
    PreviewContent { theme in
        TitledPageView(
            titledPageViewPreviewPages,
            selection: $selection,
            title: \TitledPageViewPreviewPage.title
        ) { page in
            VStack(spacing: theme.spacing.oneUnit) {
                Image(systemName: page.symbol)
                    .font(theme.typography.largeTitle)
                Text(page.title)
                    .designTextStyle(.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .designCardSurface()
            .padding(.horizontal, theme.spacing.oneUnit)
        }
        .designPaginationStyle(.init(peekDirection: .unidirectional))
        .frame(height: 240)
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Swipe hint (tap Replay to reset)") {
    @Previewable @State var selection = 0
    @Previewable @State var hintToken = UUID()
    PreviewContent { theme in
        VStack(spacing: theme.spacing.twoUnits) {
            TitledPageView(
                titledPageViewPreviewPages,
                selection: $selection,
                title: \TitledPageViewPreviewPage.title,
                indicatorStyle: .dots
            ) { page in
                VStack(spacing: theme.spacing.oneUnit) {
                    Image(systemName: page.symbol)
                        .font(theme.typography.largeTitle)
                    Text(page.title)
                        .designTextStyle(.body)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .designCardSurface()
                .padding(.horizontal, theme.spacing.oneUnit)
            }
            .id(hintToken)
            .frame(height: 240)
            // To replay the hint in previews, tap the button below — it re-creates the view
            // with a fresh identity, which restarts the hint task from the beginning.
            Button("Replay hint") {
                selection = 0
                hintToken = UUID()
            }
            .buttonStyle(ThemeButtonStyle(role: .secondary))
        }
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Swipe hint — custom config") {
    @Previewable @State var selection = 0
    @Previewable @State var hintToken = UUID()
    PreviewContent { theme in
        VStack(spacing: theme.spacing.twoUnits) {
            TitledPageView(
                titledPageViewPreviewPages,
                selection: $selection,
                title: \TitledPageViewPreviewPage.title
            ) { page in
                VStack(spacing: theme.spacing.oneUnit) {
                    Image(systemName: page.symbol)
                        .font(theme.typography.largeTitle)
                    Text(page.title)
                        .designTextStyle(.body)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .designCardSurface()
                .padding(.horizontal, theme.spacing.oneUnit)
            }
            .id(hintToken)
            .designSwipeHint(.init(delay: 0.3, distance: 72))
            .frame(height: 240)
            Button("Replay hint") {
                selection = 0
                hintToken = UUID()
            }
            .buttonStyle(ThemeButtonStyle(role: .secondary))
        }
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Pinned title leading padding") {
    @Previewable @State var selection = 0
    PreviewContent { theme in
        TitledPageView(
            titledPageViewPreviewPages,
            selection: $selection,
            title: \TitledPageViewPreviewPage.title
        ) { page in
            VStack(spacing: theme.spacing.oneUnit) {
                Image(systemName: page.symbol)
                    .font(theme.typography.largeTitle)
                Text(page.title)
                    .designTextStyle(.body)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .designCardSurface()
            .padding(.horizontal, theme.spacing.threeUnits)
        }
        // Pin the title strip's leading edge to match the page content inset
        // so the active title aligns with the card's text rather than
        // the peek+gap computed default.
        .designPaginationStyle(.init(titleLeadingPadding: theme.spacing.threeUnits))
        .frame(height: 240)
        .padding(theme.spacing.twoUnits)
    }
}
