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
