import Components
import DesignSystem
import SwiftUI

/// A showcase app that demonstrates all components from the design system.
@main
struct ComponentShowcaseApp: App {
    var body: some Scene {
        WindowGroup {
            ShowcaseView()
        }
    }
}

/// Root view containing all component showcases in a scrollable layout.
struct ShowcaseView: View {
    @State private var searchText = ""
    @State private var toggleValue = true
    @State private var selectedChip = "All"

    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVStack(alignment: .leading, spacing: 24) {
                    showcaseSection("Buttons") { ButtonShowcase() }
                    showcaseSection("Search Bar") { SearchBarShowcase(text: $searchText) }
                    showcaseSection("Toggle") { ToggleShowcase(isOn: $toggleValue) }
                    showcaseSection("Badges") { BadgeShowcase() }
                    showcaseSection("Pill Chips") { PillChipShowcase(selected: $selectedChip) }
                    showcaseSection("Text Styles") { TextStyleShowcase() }
                    showcaseSection("Surfaces") { SurfaceShowcase() }
                    showcaseSection("Containers") { ContainerShowcase() }
                    showcaseSection("Paged View") { PagedViewShowcase() }
                    showcaseSection("Empty State") { EmptyStateShowcase() }
                    showcaseSection("Loading") { LoadingShowcase() }
                }
                .padding()
            }
            .navigationTitle("Component Showcase")
        }
    }

    private func showcaseSection<Content: View>(
        _ title: String,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .designTextStyle(.headline)
            content()
        }
    }
}

// MARK: - Individual Showcases

private struct ButtonShowcase: View {
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 8) {
            DesignButton("Primary") { isLoading.toggle() }
            DesignButton("Secondary", role: .secondary) {}
            DesignButton("Tertiary", role: .tertiary) {}
            DesignButton("Destructive", role: .destructive) {}
            DesignButton("Loading", isLoading: isLoading) {}
        }
    }
}

private struct SearchBarShowcase: View {
    @Binding var text: String

    var body: some View {
        DesignSearchBar(text: $text, placeholder: "Search components…")
    }
}

private struct ToggleShowcase: View {
    @Binding var isOn: Bool

    var body: some View {
        Toggle("Enable notifications", isOn: $isOn)
            .toggleStyle(DesignToggleStyle())
    }
}

private struct BadgeShowcase: View {
    var body: some View {
        HStack(spacing: 8) {
            DesignBadge("Beta")
            DesignBadge("New", isProminent: true)
            DesignBadge("v2.0")
        }
    }
}

private struct PillChipShowcase: View {
    @Binding var selected: String
    private let options = ["All", "Recent", "Favorites", "Archived"]

    var body: some View {
        HStack(spacing: 8) {
            ForEach(options, id: \.self) { option in
                DesignPillChip(option, isSelected: selected == option) {
                    selected = option
                }
            }
        }
    }
}

private struct TextStyleShowcase: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Title text").designTextStyle(.title)
            Text("Headline text").designTextStyle(.headline)
            Text("Body text").designTextStyle(.body)
            Text("Secondary text").designTextStyle(.secondary)
            Text("Caption text").designTextStyle(.caption)
            Text("Error text").designTextStyle(.error)
        }
    }
}

private struct SurfaceShowcase: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Card Surface")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .designCardSurface()

            HStack(spacing: 12) {
                Text("Capsule")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .designCapsuleSurface()
                Text("Selected")
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .designCapsuleSurface(isSelected: true)
            }

            Text("Input Surface")
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                .designInputSurface()
        }
    }
}

private struct ContainerShowcase: View {
    var body: some View {
        VStack(spacing: 12) {
            DesignContainer(style: .card) { Text("Card container").frame(maxWidth: .infinity) }
            DesignContainer(style: .elevated) { Text("Elevated container").frame(maxWidth: .infinity) }
            DesignContainer(style: .outlined) { Text("Outlined container").frame(maxWidth: .infinity) }
        }
    }
}

private struct EmptyStateShowcase: View {
    var body: some View {
        DesignEmptyStateView(
            title: "No Results",
            message: "Try adjusting your search or filters.",
            systemImage: "magnifyingglass"
        ) {
            DesignButton("Reset Filters", role: .secondary) {}
        }
    }
}

private struct LoadingShowcase: View {
    var body: some View {
        DesignLoadingView("Loading components…")
    }
}

private struct PagedViewShowcase: View {
    private struct ShowcasePage: Identifiable, Hashable {
        let id: Int
        let title: String
        let summary: String
        let symbol: String
    }

    private static let allPages: [ShowcasePage] = [
        .init(id: 0, title: "Best of 2025", summary: "Editors' picks from across the year.", symbol: "sparkles"),
        .init(id: 1, title: "Spotlight: Health", summary: "Apps to help you move, eat, sleep, and breathe.", symbol: "heart.fill"),
        .init(id: 2, title: "Travel Companions", summary: "Plan, book, and remember every trip.", symbol: "airplane"),
        .init(id: 3, title: "Quiet Tools", summary: "Beautifully focused single-purpose apps.", symbol: "moon.stars.fill"),
    ]

    @State private var selection: Int = 0
    @State private var indicatorStyle: DesignPaginationIndicatorStyle = .dots
    @State private var peekDirection: DesignPaginationPeekDirection = .unidirectional
    @State private var isRTL: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            controlsRow

            DesignPagedView(
                Self.allPages,
                selection: $selection,
                title: \ShowcasePage.title,
                indicatorStyle: indicatorStyle
            ) { page in
                pageBody(page)
            }
            .designPaginationStyle(.init(peekDirection: peekDirection))
            .frame(height: 260)
            .environment(\.layoutDirection, isRTL ? .rightToLeft : .leftToRight)
        }
    }

    private var controlsRow: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                ForEach([DesignPaginationIndicatorStyle.dots, .bar, .hidden], id: \.self) { style in
                    DesignPillChip(label(for: style), isSelected: indicatorStyle == style) {
                        indicatorStyle = style
                    }
                }
            }
            HStack(spacing: 8) {
                ForEach(DesignPaginationPeekDirection.allCases, id: \.self) { direction in
                    DesignPillChip(label(for: direction), isSelected: peekDirection == direction) {
                        peekDirection = direction
                    }
                }
            }
            Toggle("Right-to-Left", isOn: $isRTL)
                .toggleStyle(DesignToggleStyle())
        }
    }

    @ViewBuilder
    private func pageBody(_ page: ShowcasePage) -> some View {
        VStack(spacing: 12) {
            Image(systemName: page.symbol)
                .font(.system(size: 56, weight: .semibold))
            Text(page.summary)
                .designTextStyle(.body)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
        .designCardSurface()
        .padding(.horizontal, 8)
    }

    private func label(for style: DesignPaginationIndicatorStyle) -> String {
        switch style {
        case .dots: return "Dots"
        case .bar: return "Bar"
        case .hidden: return "Hidden"
        }
    }

    private func label(for direction: DesignPaginationPeekDirection) -> String {
        switch direction {
        case .bidirectional: return "Both"
        case .unidirectional: return "Next only"
        case .none: return "No peek"
        }
    }
}
