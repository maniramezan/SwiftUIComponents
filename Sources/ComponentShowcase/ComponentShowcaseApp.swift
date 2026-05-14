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
