import SwiftUI
import Testing
@testable import SwiftUIComponents

// MARK: - Shared fixture

struct MenuPickerTestItem: MenuPickerItem {
    let id: Int
    let title: String
}

private func makeItems(_ count: Int, startingAt start: Int = 1) -> [MenuPickerTestItem] {
    (start ..< start + count).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
}

// MARK: - longestLabel

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

// MARK: - init — success paths

@Test("init succeeds when currentValue is present in items")
@MainActor
func initSucceedsWithValidCurrentValue() throws {
    let items = makeItems(5)
    var selected = items[2]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    #expect(throws: Never.self) {
        _ = try MenuPicker(items: items, currentValue: binding)
    }
}

// MARK: - init — error paths

@Test("init throws emptyItems when items collection is empty")
@MainActor
func initThrowsOnEmptyItems() throws {
    var selected = MenuPickerTestItem(id: 1, title: "Ghost")
    let binding = Binding(get: { selected }, set: { selected = $0 })
    #expect(throws: MenuPickerError.emptyItems) {
        _ = try MenuPicker(items: [] as [MenuPickerTestItem], currentValue: binding)
    }
}

@Test("init throws currentValueNotInItems when currentValue is absent from items")
@MainActor
func initThrowsWhenCurrentValueMissing() throws {
    let items = makeItems(3)
    var selected = MenuPickerTestItem(id: 999, title: "Not in list")
    let binding = Binding(get: { selected }, set: { selected = $0 })
    #expect(throws: MenuPickerError.currentValueNotInItems) {
        _ = try MenuPicker(items: items, currentValue: binding)
    }
}

// MARK: - Long-list threshold

@Test("init accepts exactly longListThreshold items")
@MainActor
func initAcceptsThresholdCountItems() throws {
    // The threshold is 30; a list of exactly 30 items should succeed.
    let items = makeItems(30)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    #expect(throws: Never.self) {
        _ = try MenuPicker(items: items, currentValue: binding)
    }
}

@Test("init accepts more than longListThreshold items")
@MainActor
func initAcceptsLongList() throws {
    let items = makeItems(31)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    #expect(throws: Never.self) {
        _ = try MenuPicker(items: items, currentValue: binding)
    }
}
