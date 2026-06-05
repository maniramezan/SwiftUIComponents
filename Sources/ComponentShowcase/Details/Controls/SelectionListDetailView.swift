import Components
import DesignSystem
import SwiftUI

struct SelectionListDetailView: View {
    @State private var isSinglePresented = false
    @State private var isMultiPresented = false
    @State private var category = "banana"
    @State private var tags: Set<String> = ["wifi", "pool"]
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Single choice, two-level, searchable") {
                Button("Category: \(category)") { isSinglePresented = true }
            }

            ShowcaseSection("Multiple choice, no search") {
                Button("Tags: \(tags.count) selected") { isMultiPresented = true }
            }
        }
        .sheet(isPresented: $isSinglePresented) {
            SelectionListView(
                title: "Category",
                nodes: Self.categories,
                selectedID: category,
                isSearchable: true
            ) { id in
                category = id
                isSinglePresented = false
            }
        }
        .sheet(isPresented: $isMultiPresented) {
            // `isSearchable` defaults to false — short lists can omit the search field.
            SelectionListView(
                title: "Tags",
                nodes: Self.tags,
                selectedIDs: tags
            ) { id in
                tags.formSymmetricDifference([id])
            }
        }
    }

    /// Two-level data: expandable parents plus a directly selectable leaf.
    private static let categories: [SelectionNode<String>] = [
        .init(id: "fruit", title: "Fruit", leadingGlyph: "🍎", children: [
            .init(id: "apple", title: "Apple"),
            .init(id: "banana", title: "Banana"),
            .init(id: "mango", title: "Mango"),
        ]),
        .init(id: "vegetable", title: "Vegetable", leadingGlyph: "🥦", children: [
            .init(id: "carrot", title: "Carrot"),
            .init(id: "spinach", title: "Spinach"),
        ]),
        .init(id: "water", title: "Water", leadingGlyph: "💧"),
    ]

    /// Flat data used for multiple-choice selection.
    private static let tags: [SelectionNode<String>] = [
        .init(id: "wifi", title: "Wi-Fi", leadingGlyph: "📶"),
        .init(id: "parking", title: "Parking", leadingGlyph: "🅿️"),
        .init(id: "pool", title: "Pool", leadingGlyph: "🏊"),
        .init(id: "gym", title: "Gym", leadingGlyph: "🏋️"),
        .init(id: "breakfast", title: "Breakfast", leadingGlyph: "🍳"),
    ]
}

#Preview {
    ScrollView {
        SelectionListDetailView()
            .padding()
    }
}
