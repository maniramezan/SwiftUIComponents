import Components
import DesignSystem
import SwiftUI

struct SegmentedPickerDetailView: View {

    private enum Filter: String, CaseIterable, MenuPickerItem {
        case all, recent, favorites, archived
        var id: String { rawValue }
        var title: String { rawValue.capitalized }
    }

    private enum Genre: String, CaseIterable, MenuPickerItem {
        case all = "All"
        case action = "Action"
        case adventure = "Adventure"
        case comedy = "Comedy"
        case drama = "Drama"
        case horror = "Horror"
        case mystery = "Mystery"
        case romance = "Romance"
        case scifi = "Science Fiction"
        case thriller = "Thriller"
        case western = "Western"
        case documentary = "Documentary"
        var id: String { rawValue }
        var title: String { rawValue }
    }

    private struct Tab: MenuPickerItem {
        let id: String
        let title: String
        let systemImage: String
    }

    private let tabs: [Tab] = [
        Tab(id: "feed", title: "Feed", systemImage: "house"),
        Tab(id: "search", title: "Search", systemImage: "magnifyingglass"),
        Tab(id: "library", title: "Library", systemImage: "books.vertical"),
        Tab(id: "profile", title: "Profile", systemImage: "person.crop.circle"),
    ]

    @State private var sizing: SegmentSizing = .fit
    @State private var density: SegmentDensity = .regular
    @State private var showsBadges = false
    @State private var filter: Filter = .all
    @State private var genre: Genre = .all
    @State private var tab: Tab
    @State private var compact: Filter = .all

    @Environment(\.designTheme) private var theme

    init() {
        _tab = State(initialValue: Tab(id: "feed", title: "Feed", systemImage: "house"))
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Configuration") {
                Picker("Sizing", selection: $sizing) {
                    ForEach(SegmentSizing.allCases, id: \.self) { Text(String(describing: $0)).tag($0) }
                }
                Picker("Density", selection: $density) {
                    ForEach(SegmentDensity.allCases, id: \.self) { Text(String(describing: $0)).tag($0) }
                }
                Toggle("Badges", isOn: $showsBadges)
            }
            ShowcaseSection("Fits the row") {
                SegmentedPicker(
                    items: Filter.allCases, selection: $filter, sizing: sizing, density: density,
                    badge: { showsBadges ? ($0 == .all ? "3" : "") : nil })
                Text("Selected: \(filter.title)")
                    .designTextStyle(.caption)
            }

            ShowcaseSection("Overflows — fades on scrollable edges") {
                SegmentedPicker(items: Genre.allCases, selection: $genre)
                Text("Selected: \(genre.title)")
                    .designTextStyle(.caption)
            }

            ShowcaseSection("Custom label (icon + text)") {
                SegmentedPicker(items: tabs, selection: $tab) { tab, _ in
                    HStack(spacing: theme.spacing.halfUnit) {
                        Image(systemName: tab.systemImage)
                        Text(tab.title)
                    }
                }
                Text("Selected: \(tab.title)")
                    .designTextStyle(.caption)
            }

            ShowcaseSection("Compact density") {
                SegmentedPicker(items: Filter.allCases, selection: $compact, density: .compact)
                Text("Shorter control (~32pt) for tight headers; tap target shrinks with it.")
                    .designTextStyle(.caption)
            }
        }
    }
}

#Preview {
    ScrollView {
        SegmentedPickerDetailView()
            .padding()
    }
}
