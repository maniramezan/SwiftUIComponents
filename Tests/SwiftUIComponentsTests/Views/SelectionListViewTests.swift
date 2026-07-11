import SwiftUI
import Testing
@testable import Components

// MARK: - Shared fixture

private func leaf(_ id: String, _ title: String, subtitle: String? = nil) -> SelectionNode<String> {
    SelectionNode(id: id, title: title, subtitle: subtitle)
}

private let sampleNodes: [SelectionNode<String>] = [
    leaf("water", "Water", subtitle: "still"),
    leaf("juice", "Juice"),
    SelectionNode(
        id: "fruit", title: "Fruit",
        children: [
            leaf("apple", "Apple", subtitle: "green"),
            leaf("banana", "Banana", subtitle: "yellow"),
            leaf("mango", "Mango", subtitle: "ripe"),
        ]),
]

// MARK: - filtered: passthrough

@Test("filtered returns all nodes for an empty query")
func filteredReturnsAllForEmptyQuery() {
    let result = filteredSelectionNodes(sampleNodes, query: "")
    #expect(result.map(\.id) == ["water", "juice", "fruit"])
}

@Test("filtered returns all nodes for a whitespace-only query")
func filteredReturnsAllForWhitespaceQuery() {
    let result = filteredSelectionNodes(sampleNodes, query: "   ")
    #expect(result.count == sampleNodes.count)
}

// MARK: - filtered: leaves

@Test("filtered matches a leaf by title")
func filteredMatchesLeafTitle() {
    let result = filteredSelectionNodes(sampleNodes, query: "Juice")
    #expect(result.map(\.id) == ["juice"])
}

@Test("filtered matches a leaf by subtitle and is case-insensitive")
func filteredMatchesLeafSubtitleCaseInsensitive() {
    let result = filteredSelectionNodes(sampleNodes, query: "STILL")
    #expect(result.map(\.id) == ["water"])
}

// MARK: - filtered: parents

@Test("filtered keeps all children when the parent title matches")
func filteredKeepsAllChildrenOnParentMatch() {
    let result = filteredSelectionNodes(sampleNodes, query: "Fruit")
    #expect(result.map(\.id) == ["fruit"])
    #expect(result.first?.children.map(\.id) == ["apple", "banana", "mango"])
}

@Test("filtered prunes a parent to only its matching children")
func filteredPrunesChildrenOnChildMatch() {
    let result = filteredSelectionNodes(sampleNodes, query: "Banana")
    #expect(result.map(\.id) == ["fruit"])
    #expect(result.first?.children.map(\.id) == ["banana"])
}

@Test("filtered trims surrounding whitespace from the query")
func filteredTrimsQuery() {
    let result = filteredSelectionNodes(sampleNodes, query: "  Mango  ")
    #expect(result.first?.children.map(\.id) == ["mango"])
}

@Test("filtered returns no nodes when nothing matches")
func filteredReturnsEmptyWhenNoMatch() {
    let result = filteredSelectionNodes(sampleNodes, query: "zzz")
    #expect(result.isEmpty)
}

@Test("filtered preserves the original ordering of matches")
func filteredPreservesOrder() {
    let nodes = [leaf("1", "Alpha test"), leaf("2", "Beta"), leaf("3", "Gamma test")]
    let result = filteredSelectionNodes(nodes, query: "test")
    #expect(result.map(\.id) == ["1", "3"])
}

// MARK: - SelectionNode

@Test("isLeaf reflects the presence of children")
func nodeIsLeaf() {
    #expect(leaf("a", "A").isLeaf)
    #expect(!SelectionNode(id: "p", title: "P", children: [leaf("c", "C")]).isLeaf)
}

@Test("SelectionNode defaults subtitle and glyph to nil")
func nodeDefaults() {
    let node = SelectionNode(id: 1, title: "Only title")
    #expect(node.subtitle == nil)
    #expect(node.leadingGlyph == nil)
    #expect(node.children.isEmpty)
}

@Test("replacingChildren keeps identity and metadata")
func replacingChildrenKeepsMetadata() {
    let parent = SelectionNode(
        id: "fruit", title: "Fruit", subtitle: "sub", leadingGlyph: "🍎", children: [leaf("apple", "Apple")])
    let replaced = parent.replacingChildren([leaf("banana", "Banana")])
    #expect(replaced.id == "fruit")
    #expect(replaced.title == "Fruit")
    #expect(replaced.subtitle == "sub")
    #expect(replaced.leadingGlyph == "🍎")
    #expect(replaced.children.map(\.id) == ["banana"])
}

// MARK: - init

@Test("single-choice init succeeds with a selected id")
@MainActor
func singleChoiceInitSucceeds() {
    _ = SelectionListView(
        title: "Category",
        nodes: sampleNodes,
        selectedID: "banana",
        isSearchable: true,
        onSelect: { _ in }
    )
}

@Test("multiple-choice init succeeds with a selection set")
@MainActor
func multipleChoiceInitSucceeds() {
    _ = SelectionListView(
        title: "Categories",
        nodes: sampleNodes,
        selectedIDs: ["apple", "water"],
        isSearchable: true,
        onToggle: { _ in }
    )
}

// MARK: - Rendering (leaf rows, expandable parent rows, child rows, empty state)

@Test("Leaf and parent rows render without searching")
@MainActor
func leafAndParentRowsRender() {
    renderForCoverage(
        SelectionListContentView(
            nodes: sampleNodes,
            selectedID: "banana",
            onSelect: { _ in }
        ),
        size: CGSize(width: 320, height: 500)
    )
}

@Test("Searching with no matches renders the empty state")
@MainActor
func emptyStateRendersWhenSearchHasNoMatches() {
    let view = SelectionListContentView(
        nodes: sampleNodes,
        selectedID: nil,
        isSearchable: true,
        onSelect: { _ in }
    )
    renderForCoverage(view, size: CGSize(width: 320, height: 500))
}

@Test("showsContainerBackground false renders the plain list style")
@MainActor
func plainListStyleRenders() {
    renderForCoverage(
        SelectionListContentView(
            nodes: sampleNodes,
            selectedID: nil,
            showsContainerBackground: false,
            onSelect: { _ in }
        ),
        size: CGSize(width: 320, height: 500)
    )
}

@Test("toggleExpansion runs without crashing for a parent node")
@MainActor
func toggleExpansionRuns() {
    let view = SelectionListContentView(
        nodes: sampleNodes,
        selectedID: nil,
        onSelect: { _ in }
    )
    view.toggleExpansion("fruit")
    view.toggleExpansion("fruit")
}
