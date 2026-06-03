import DesignSystem
import SwiftUI

/// A themed selection list presented inside a sheet or drawer, with optional search
/// and inline two-level disclosure. Supports both single-choice and multiple-choice
/// selection.
///
/// Present it yourself with `.sheet` so you control detents, drag indicators, and
/// dismissal timing. Rows come from a ``SelectionNode`` tree: leaf nodes are
/// selectable, while parent nodes expand inline to reveal their children. The sheet
/// is **controlled** — it reflects the selection you pass in and reports taps through a
/// callback; it never mutates selection or dismisses itself. Selected rows show a
/// checkmark, and a collapsed parent lists its selected children as its subtitle.
///
/// Use ``init(title:nodes:selectedID:isSearchable:searchPlaceholder:onSelect:)`` for
/// single choice (typically replace the selection and dismiss in the callback), or
/// ``init(title:nodes:selectedIDs:isSearchable:searchPlaceholder:onToggle:)`` for
/// multiple choice (toggle membership and keep the sheet open).
///
/// When `isSearchable` is `true`, the search field filters leaves and children by
/// title and subtitle, keeps parents whose title matches (with all children) or that
/// contain a matching child (pruned to the matches), and force-expands parents while
/// searching.
///
/// ```swift
/// let nodes: [SelectionNode<String>] = [
///     .init(id: "water", title: "Water"),                  // leaf
///     .init(id: "fruit", title: "Fruit", children: [       // expands inline
///         .init(id: "apple", title: "Apple"),
///         .init(id: "banana", title: "Banana"),
///     ]),
/// ]
///
/// // Single choice
/// .sheet(isPresented: $isPresented) {
///     SelectionSheetView(title: "Category", nodes: nodes, selectedID: choice, isSearchable: true) { id in
///         choice = id
///         isPresented = false
///     }
/// }
///
/// // Multiple choice
/// .sheet(isPresented: $isPresented) {
///     SelectionSheetView(title: "Categories", nodes: nodes, selectedIDs: choices) { id in
///         choices.formSymmetricDifference([id])   // toggle; sheet stays open
///     }
/// }
/// ```
public struct SelectionSheetView<ID: Hashable>: View {

    // MARK: - Configuration

    private let title: String
    private let nodes: [SelectionNode<ID>]
    private let selectedIDs: Set<ID>
    private let isSearchable: Bool
    private let searchPlaceholder: String
    private let onSelect: (ID) -> Void

    // MARK: - State

    @State private var query: String = ""
    @State private var expandedIDs: Set<ID> = []
    @State private var didPrepareExpansion = false
    @Environment(\.designTheme) private var theme
    @Environment(\.dismiss) private var dismiss

    /// Creates a single-choice selection sheet.
    /// - Parameters:
    ///   - title: Navigation title shown at the top of the sheet.
    ///   - nodes: The root nodes to display. Leaves select directly; parents expand inline.
    ///   - selectedID: Identifier of the currently selected leaf or child, marked with a checkmark. Pass `nil` for no selection.
    ///   - isSearchable: When `true`, shows a search field that filters across both levels. Defaults to `false`.
    ///   - searchPlaceholder: Prompt shown in the search field when it is empty. Defaults to `"Search"`.
    ///   - onSelect: Closure invoked with the chosen leaf or child identifier. Replace the selection and perform your own dismissal here.
    public init(
        title: String,
        nodes: some RandomAccessCollection<SelectionNode<ID>>,
        selectedID: ID? = nil,
        isSearchable: Bool = false,
        searchPlaceholder: String = "Search",
        onSelect: @escaping (ID) -> Void
    ) {
        self.title = title
        self.nodes = Array(nodes)
        self.selectedIDs = selectedID.map { [$0] } ?? []
        self.isSearchable = isSearchable
        self.searchPlaceholder = searchPlaceholder
        self.onSelect = onSelect
    }

    /// Creates a multiple-choice selection sheet.
    /// - Parameters:
    ///   - title: Navigation title shown at the top of the sheet.
    ///   - nodes: The root nodes to display. Leaves select directly; parents expand inline.
    ///   - selectedIDs: Identifiers of the currently selected leaves or children, each marked with a checkmark.
    ///   - isSearchable: When `true`, shows a search field that filters across both levels. Defaults to `false`.
    ///   - searchPlaceholder: Prompt shown in the search field when it is empty. Defaults to `"Search"`.
    ///   - onToggle: Closure invoked with the tapped leaf or child identifier. Toggle its membership in your selection; the sheet stays open.
    public init(
        title: String,
        nodes: some RandomAccessCollection<SelectionNode<ID>>,
        selectedIDs: Set<ID>,
        isSearchable: Bool = false,
        searchPlaceholder: String = "Search",
        onToggle: @escaping (ID) -> Void
    ) {
        self.title = title
        self.nodes = Array(nodes)
        self.selectedIDs = selectedIDs
        self.isSearchable = isSearchable
        self.searchPlaceholder = searchPlaceholder
        self.onSelect = onToggle
    }

    /// The SwiftUI body for the selection sheet.
    public var body: some View {
        NavigationStack {
            list
                .navigationTitle(title)
                #if os(iOS) || targetEnvironment(macCatalyst)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar { DismissToolbarButton { dismiss() } }
                .modifier(OptionalSearchable(isEnabled: isSearchable, text: $query, prompt: searchPlaceholder))
                .onAppear(perform: prepareExpansionIfNeeded)
        }
    }

    // MARK: - Subviews

    private var list: some View {
        List {
            ForEach(visibleNodes) { node in
                if node.isLeaf {
                    SelectionRow(
                        title: node.title,
                        subtitle: node.subtitle,
                        leadingGlyph: node.leadingGlyph,
                        isSelected: selectedIDs.contains(node.id),
                        isIndented: false,
                        action: { onSelect(node.id) }
                    )
                } else {
                    DisclosureGroup(isExpanded: expansionBinding(for: node.id)) {
                        ForEach(node.children) { child in
                            SelectionRow(
                                title: child.title,
                                subtitle: child.subtitle,
                                leadingGlyph: child.leadingGlyph,
                                isSelected: selectedIDs.contains(child.id),
                                isIndented: true,
                                action: { onSelect(child.id) }
                            )
                        }
                    } label: {
                        SelectionRow(
                            title: node.title,
                            subtitle: selectedChildrenSummary(in: node) ?? node.subtitle,
                            leadingGlyph: node.leadingGlyph,
                            isSelected: false,
                            isIndented: false,
                            action: nil
                        )
                    }
                }
            }
        }
        .listStyle(.plain)
        .overlay { emptyState }
    }

    @ViewBuilder
    private var emptyState: some View {
        if visibleNodes.isEmpty, isSearching {
            ContentUnavailableView.search(text: query)
        }
    }

    // MARK: - Derived state

    private var trimmedQuery: String {
        query.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private var isSearching: Bool {
        isSearchable && !trimmedQuery.isEmpty
    }

    private var visibleNodes: [SelectionNode<ID>] {
        Self.filtered(nodes, query: isSearchable ? query : "")
    }

    /// The comma-joined titles of `node`'s selected children, or `nil` when none are selected.
    private func selectedChildrenSummary(in node: SelectionNode<ID>) -> String? {
        let titles = node.children
            .filter { selectedIDs.contains($0.id) }
            .map(\.title)
        return titles.isEmpty ? nil : titles.joined(separator: ", ")
    }

    private func expansionBinding(for id: ID) -> Binding<Bool> {
        Binding(
            get: { isSearching || expandedIDs.contains(id) },
            set: { expanded in
                if expanded {
                    expandedIDs.insert(id)
                } else {
                    expandedIDs.remove(id)
                }
            }
        )
    }

    /// Expands every parent containing a selected child once, so selections are visible on first appearance.
    private func prepareExpansionIfNeeded() {
        guard !didPrepareExpansion else { return }
        didPrepareExpansion = true
        guard !selectedIDs.isEmpty else { return }
        for node in nodes where node.children.contains(where: { selectedIDs.contains($0.id) }) {
            expandedIDs.insert(node.id)
        }
    }
}
