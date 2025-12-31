import Testing
@testable import SwiftUIComponents

struct MenuPickerTestItem: MenuPickerItem {
    let id: Int
    let title: String
}

@Test("longestLabel returns the title with the most characters")
func longestLabelPicksWidestTitle() throws {
    let items = [
        MenuPickerTestItem(id: 1, title: "Short"),
        MenuPickerTestItem(id: 2, title: "Longest option here"),
        MenuPickerTestItem(id: 3, title: "Mid"),
    ]

    let label = MenuPicker<MenuPickerTestItem>.longestLabel(in: items)

    #expect(label == "Longest option here")
}

@Test("longestLabel matches the maximum title length")
func longestLabelMatchesMaxTitleLength() throws {
    let items = [
        MenuPickerTestItem(id: 1, title: "A"),
        MenuPickerTestItem(id: 2, title: "BBBB"),
        MenuPickerTestItem(id: 3, title: "CCC"),
    ]

    let label = MenuPicker<MenuPickerTestItem>.longestLabel(in: items)

    #expect(label.count == 4)
}

@Test("longestLabel returns empty string when no items exist")
func longestLabelHandlesEmptyItems() throws {
    let label = MenuPicker<MenuPickerTestItem>.longestLabel(in: [])

    #expect(label.isEmpty)
}
