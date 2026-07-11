import Components
import DesignSystem
import SwiftUI

/// Showcases ``CarouselBoard`` — a two-directional layout of heterogeneous
/// shelves. The demo uses ``CarouselBoardContent`` because the surrounding
/// detail screen already provides a vertical `ScrollView`.
struct CarouselBoardDetailView: View {

    fileprivate struct App: Identifiable {
        let id: Int
        let name: String
    }

    fileprivate struct Story: Identifiable {
        let id: Int
        let headline: String
    }

    private let featured: [App] = (1...6).map { App(id: $0, name: "App \($0)") }
    private let topFree: [App] = (7...16).map { App(id: $0, name: "App \($0)") }
    private let stories: [Story] = (1...5).map { Story(id: $0, headline: "Story \($0)") }

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Shelves — heterogeneous, each scrolls horizontally") {
                CarouselBoardContent {
                    CarouselShelf("Featured", items: featured) { app in
                        CarouselBoardFeaturedCard(app: app)
                    }
                    CarouselShelf("Top Free", items: topFree, actionLabel: "See All", sizing: .fixedWidth(96)) { app in
                        CarouselBoardIconTile(app: app)
                    }
                    CarouselShelf("Stories", items: stories, sizing: .peek(visibleCount: 1, peek: 48)) { story in
                        CarouselBoardStoryBanner(story: story)
                    }
                    CarouselShelf("Editor's Pick") {
                        CarouselBoardEditorsBanner()
                    }
                }
            }
        }
    }
}

private struct CarouselBoardFeaturedCard: View {
    let app: CarouselBoardDetailView.App

    @Environment(\.designTheme) private var theme

    var body: some View {
        RoundedRectangle(cornerRadius: theme.radius.twoUnits, style: .continuous)
            .fill(theme.colors.containerSecondary)
            .frame(height: 180)
            .overlay(alignment: .bottomLeading) {
                Text(app.name)
                    .designTextStyle(.headline)
                    .padding(theme.spacing.twoUnits)
            }
    }
}

private struct CarouselBoardIconTile: View {
    let app: CarouselBoardDetailView.App

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.oneUnit) {
            RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                .fill(theme.colors.containerSecondary)
                .frame(width: 96, height: 96)
            Text(app.name)
                .designTextStyle(.caption)
                .lineLimit(1)
        }
    }
}

private struct CarouselBoardStoryBanner: View {
    let story: CarouselBoardDetailView.Story

    @Environment(\.designTheme) private var theme

    var body: some View {
        RoundedRectangle(cornerRadius: theme.radius.twoUnits, style: .continuous)
            .fill(theme.colors.containerSecondary)
            .frame(height: 120)
            .overlay {
                Text(story.headline)
                    .designTextStyle(.title)
            }
    }
}

private struct CarouselBoardEditorsBanner: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        RoundedRectangle(cornerRadius: theme.radius.twoUnits, style: .continuous)
            .fill(theme.colors.primary.opacity(0.15))
            .frame(height: 100)
            .overlay {
                Text("A fully custom shelf")
                    .designTextStyle(.headline)
            }
            .padding(.horizontal, theme.spacing.twoUnits)
    }
}

#Preview {
    ScrollView {
        CarouselBoardDetailView()
            .padding()
    }
}
