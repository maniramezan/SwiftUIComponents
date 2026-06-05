import DesignSystem
import SwiftUI

private extension SelectionNode where ID == String {
    /// A two-level sample tree: a leaf, expandable parents with glyphs, and nested children.
    static var sampleCategories: [SelectionNode<String>] {
        [
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
    }
}

#Preview("Single choice, two-level") {
    @Previewable @State var selected = "banana"
    PreviewContent { _ in
        SelectionListView(
            title: "Category",
            nodes: SelectionNode<String>.sampleCategories,
            selectedID: selected,
            isSearchable: true
        ) { id in
            selected = id
        }
    }
}

#Preview("Multiple choice") {
    @Previewable @State var selected: Set<String> = ["apple", "spinach"]
    PreviewContent { _ in
        SelectionListView(
            title: "Categories",
            nodes: SelectionNode<String>.sampleCategories,
            selectedIDs: selected,
            isSearchable: true
        ) { id in
            selected.formSymmetricDifference([id])
        }
    }
}
