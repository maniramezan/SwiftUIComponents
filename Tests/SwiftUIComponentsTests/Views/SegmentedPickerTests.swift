import SwiftUI
import Testing
@testable import Components

// Reuses the `MenuPickerTestItem` fixture defined in `MenuPickerTests.swift`,
// which is internal to the same test module.

// MARK: - edgeFade helper

@Test("edgeFade returns no fade when content fits the viewport")
func edgeFadeReturnsNoFadeWhenContentFits() {
    let edges = SegmentedPicker<MenuPickerTestItem, Text>.edgeFade(
        contentOffsetX: 0,
        contentWidth: 200,
        viewportWidth: 300
    )
    #expect(edges.leading == false)
    #expect(edges.trailing == false)
}

@Test("edgeFade fades only the trailing edge at the start of the scroll")
func edgeFadeReturnsTrailingOnlyAtLeftEdge() {
    let edges = SegmentedPicker<MenuPickerTestItem, Text>.edgeFade(
        contentOffsetX: 0,
        contentWidth: 600,
        viewportWidth: 300
    )
    #expect(edges.leading == false)
    #expect(edges.trailing == true)
}

@Test("edgeFade fades only the leading edge at the end of the scroll")
func edgeFadeReturnsLeadingOnlyAtRightEdge() {
    let edges = SegmentedPicker<MenuPickerTestItem, Text>.edgeFade(
        contentOffsetX: 300,
        contentWidth: 600,
        viewportWidth: 300
    )
    #expect(edges.leading == true)
    #expect(edges.trailing == false)
}

@Test("edgeFade fades both edges in the middle of the scroll")
func edgeFadeReturnsBothInTheMiddle() {
    let edges = SegmentedPicker<MenuPickerTestItem, Text>.edgeFade(
        contentOffsetX: 150,
        contentWidth: 600,
        viewportWidth: 300
    )
    #expect(edges.leading == true)
    #expect(edges.trailing == true)
}

@Test("edgeFade ignores sub-threshold offsets")
func edgeFadeHonorsThresholdSlop() {
    let edges = SegmentedPicker<MenuPickerTestItem, Text>.edgeFade(
        contentOffsetX: 0.5,
        contentWidth: 600,
        viewportWidth: 300,
        threshold: 1
    )
    #expect(edges.leading == false)
    #expect(edges.trailing == true)
}

// MARK: - accessibilityStep helper

@Test("accessibilityStep maps edges to selection deltas in LTR")
func accessibilityStepMapsEdgesInLTR() {
    typealias P = SegmentedPicker<MenuPickerTestItem, Text>
    #expect(P.accessibilityStep(for: .leading, layoutDirection: .leftToRight) == -1)
    #expect(P.accessibilityStep(for: .trailing, layoutDirection: .leftToRight) == +1)
}

@Test("accessibilityStep flips leading/trailing in RTL")
func accessibilityStepFlipsEdgesInRTL() {
    typealias P = SegmentedPicker<MenuPickerTestItem, Text>
    #expect(P.accessibilityStep(for: .leading, layoutDirection: .rightToLeft) == +1)
    #expect(P.accessibilityStep(for: .trailing, layoutDirection: .rightToLeft) == -1)
}

// MARK: - init smoke tests

@Test("init succeeds with a custom label builder")
@MainActor
func initSucceedsWithCustomLabel() {
    let items = (1...3).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
    var selected = items[1]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = SegmentedPicker(items: items, selection: binding) { item, isActive in
        Text(item.title)
            .fontWeight(isActive ? .bold : .regular)
    }
}

@Test("convenience text init succeeds")
@MainActor
func initSucceedsWithConvenienceTextInit() {
    let items = (1...3).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = SegmentedPicker(items: items, selection: binding)
}

@Test("selection binding round-trips when mutated externally")
@MainActor
func selectionBindingRoundTrips() {
    let items = (1...3).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = SegmentedPicker(items: items, selection: binding)

    binding.wrappedValue = items[2]
    #expect(selected.id == items[2].id)
}

// MARK: - Rendering (compact + scrolling layouts, badges)

@Test("Few items render the compact layout")
@MainActor
func compactLayoutRenders() {
    let items = (1...3).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
    let binding = Binding(get: { items[0] }, set: { _ in })
    renderForCoverage(SegmentedPicker(items: items, selection: binding))
}

@Test("Many items render the scrolling layout with edge indicators")
@MainActor
func scrollingLayoutRenders() {
    let items = (1...20).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
    let binding = Binding(get: { items[10] }, set: { _ in })
    renderForCoverage(SegmentedPicker(items: items, selection: binding), size: CGSize(width: 250, height: 80))
}

@Test("Badges render the dot, labeled, and empty branches")
@MainActor
func badgeVariantsRender() {
    let items = (1...3).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
    let binding = Binding(get: { items[0] }, set: { _ in })
    let badgeValues: [Int: String] = [1: "", 2: "9"]
    renderForCoverage(
        SegmentedPicker(items: items, selection: binding) { item in
            badgeValues[item.id]
        }
    )
}

@Test("step(by:) advances and clamps the selection")
@MainActor
func stepAdvancesSelection() {
    let items = (1...3).map { MenuPickerTestItem(id: $0, title: "Option \($0)") }
    var selected = items[0]
    let binding = Binding(get: { selected }, set: { selected = $0 })
    let row = SegmentedPickerScrollingRow(
        items: items,
        selection: binding,
        badge: nil,
        label: { item, _ in Text(item.title) },
        sizing: .fit,
        density: .regular
    )

    row.step(by: 1)
    #expect(selected.id == items[1].id)

    row.step(by: 10)
    #expect(selected.id == items[2].id)

    row.step(by: 0)
    #expect(selected.id == items[2].id)
}
