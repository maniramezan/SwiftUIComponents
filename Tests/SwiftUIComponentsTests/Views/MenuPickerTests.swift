import SwiftUI
import Testing
@testable import Components

// MARK: - Shared fixture

struct MenuPickerTestItem: MenuPickerItem {
    let id: Int
    let title: String
}

private func makeItems(_ count: Int, startingAt start: Int = 1) -> [MenuPickerTestItem] {
    (start..<start + count).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
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
    _ = MenuPicker(items: items, currentValue: binding)
}

// MARK: - Long-list threshold

@Test("init accepts exactly longListThreshold items")
@MainActor
func initAcceptsThresholdCountItems() throws {
    // The threshold is 30; a list of exactly 30 items should succeed.
    let items = makeItems(30)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = MenuPicker(items: items, currentValue: binding)
}

@Test("init accepts more than longListThreshold items")
@MainActor
func initAcceptsLongList() throws {
    let items = makeItems(31)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = MenuPicker(items: items, currentValue: binding)
}

// MARK: - preferredStyle

@Test("automatic style uses a menu at the long-list threshold")
func automaticStyleUsesMenuAtThreshold() {
    #expect(
        MenuPicker<MenuPickerTestItem>.usesWheelSheet(for: .automatic, itemCount: 30) == false
    )
}

@Test("automatic style uses a wheel sheet above the long-list threshold")
func automaticStyleUsesWheelAboveThreshold() {
    #expect(
        MenuPicker<MenuPickerTestItem>.usesWheelSheet(for: .automatic, itemCount: 31)
    )
}

@Test("menu style remains a menu above the long-list threshold")
func menuStyleRemainsMenuAboveThreshold() {
    #expect(
        MenuPicker<MenuPickerTestItem>.usesWheelSheet(for: .menu, itemCount: 200) == false
    )
}

@Test("init defaults preferredStyle to automatic")
@MainActor
func initDefaultsToAutomaticStyle() throws {
    let items = makeItems(5)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = MenuPicker(items: items, currentValue: binding)
}

@Test("init accepts an explicit .menu preferredStyle for a short list")
@MainActor
func initAcceptsMenuStyleForShortList() throws {
    let items = makeItems(5)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = MenuPicker(items: items, currentValue: binding, preferredStyle: .menu)
}

@Test("init accepts an explicit .menu preferredStyle for a list past longListThreshold")
@MainActor
func initAcceptsMenuStyleForLongList() throws {
    // Regression test: `.menu` must force the native dropdown presentation even when the item
    // count would otherwise fall back to the wheel-sheet under `.automatic` — e.g. a year picker
    // with 100+ items that must stay visually consistent with a sibling month picker.
    let items = makeItems(200)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = MenuPicker(items: items, currentValue: binding, preferredStyle: .menu)
}

@Test("init accepts an explicit .automatic preferredStyle")
@MainActor
func initAcceptsExplicitAutomaticStyle() throws {
    let items = makeItems(40)
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = MenuPicker(items: items, currentValue: binding, preferredStyle: .automatic)
}

@Test("Int conforms to MenuPickerItem for convenient picker usage")
func intConformsToMenuPickerItem() {
    let value = 9
    #expect(value.id == 9)
    #expect(value.title == "AAAA 9")
}

// MARK: - AppKit trigger width

@Test("appKitTriggerWidth sums text, padding, edge inset, and pop-up chrome")
func appKitTriggerWidthSumsComponents() {
    let width = MenuPicker<MenuPickerTestItem>.appKitTriggerWidth(
        textWidth: 28,
        horizontalPadding: 12,
        edgeInset: 4,
        popUpChrome: 24
    )
    // 28 + (12 * 2) + 4 + 24
    #expect(width == 80)
}

@Test("appKitTriggerWidth reserves the disclosure-arrow chrome so short labels are not clipped")
func appKitTriggerWidthReservesChrome() {
    // A short label (e.g. a 4-digit year) must still leave room for the pop-up arrows.
    let chrome: CGFloat = 24
    let withChrome = MenuPicker<MenuPickerTestItem>.appKitTriggerWidth(
        textWidth: 28, horizontalPadding: 12, edgeInset: 4, popUpChrome: chrome
    )
    let withoutChrome = MenuPicker<MenuPickerTestItem>.appKitTriggerWidth(
        textWidth: 28, horizontalPadding: 12, edgeInset: 4, popUpChrome: 0
    )
    #expect(withChrome - withoutChrome == chrome)
}
