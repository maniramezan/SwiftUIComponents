import DesignSystem
import SwiftUI

/// The embeddable body of ``SelectionSheetView`` — an inline searchable selection list
/// with two-level disclosure, without any surrounding `NavigationStack`, navigation
/// title, or dismiss control.
///
/// Use this directly when you want the selection list inside your own screen (for
/// example a full-screen onboarding step that already has its own header and primary
/// button). Use ``SelectionSheetView`` instead when presenting in a `.sheet`.
///
/// Rows come from a ``SelectionNode`` tree: leaf nodes are selectable, while parent
/// nodes expand inline to reveal their children. The view is **controlled** — it reflects
/// the selection you pass in and reports taps through a callback; it never mutates the
/// selection. Selected rows show a checkmark, and a collapsed parent lists its selected
/// children as its subtitle.
///
/// ```swift
/// VStack {
///     header
///     SelectionSheetContentView(
///         nodes: nodes,
///         selectedID: choice,
///         isSearchable: true,
///         onSelect: { choice = $0 }
///     )
///     continueButton
/// }
/// ```
public struct SelectionSheetContentView<ID: Hashable>: View {

    // MARK: - Configuration

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

    /// Creates a single-choice selection list.
    /// - Parameters:
    ///   - nodes: The root nodes to display. Leaves select directly; parents expand inline.
    ///   - selectedID: Identifier of the currently selected leaf or child, marked with a checkmark. Pass `nil` for no selection.
    ///   - isSearchable: When `true`, shows an inline search field that filters across both levels. Defaults to `false`.
    ///   - searchPlaceholder: Hint shown in the search field when it is empty. Defaults to `"Search"`.
    ///   - onSelect: Closure invoked with the chosen leaf or child identifier.
    public init(
        nodes: some RandomAccessCollection<SelectionNode<ID>>,
        selectedID: ID? = nil,
        isSearchable: Bool = false,
        searchPlaceholder: String = "Search",
        onSelect: @escaping (ID) -> Void
    ) {
        self.nodes = Array(nodes)
        self.selectedIDs = selectedID.map { [$0] } ?? []
        self.isSearchable = isSearchable
        self.searchPlaceholder = searchPlaceholder
        self.onSelect = onSelect
    }

    /// Creates a multiple-choice selection list.
    /// - Parameters:
    ///   - nodes: The root nodes to display. Leaves select directly; parents expand inline.
    ///   - selectedIDs: Identifiers of the currently selected leaves or children, each marked with a checkmark.
    ///   - isSearchable: When `true`, shows an inline search field that filters across both levels. Defaults to `false`.
    ///   - searchPlaceholder: Hint shown in the search field when it is empty. Defaults to `"Search"`.
    ///   - onToggle: Closure invoked with the tapped leaf or child identifier. Toggle its membership in your selection.
    public init(
        nodes: some RandomAccessCollection<SelectionNode<ID>>,
        selectedIDs: Set<ID>,
        isSearchable: Bool = false,
        searchPlaceholder: String = "Search",
        onToggle: @escaping (ID) -> Void
    ) {
        self.nodes = Array(nodes)
        self.selectedIDs = selectedIDs
        self.isSearchable = isSearchable
        self.searchPlaceholder = searchPlaceholder
        self.onSelect = onToggle
    }

    /// The SwiftUI body for the inline selection list.
    public var body: some View {
        VStack(spacing: theme.spacing.oneUnit) {
            if isSearchable {
                SearchBar(text: $query, placeholder: searchPlaceholder)
                    .padding(.horizontal, theme.spacing.twoUnits)
            }
            list
        }
        .onAppear(perform: prepareExpansionIfNeeded)
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
        filteredSelectionNodes(nodes, query: isSearchable ? query : "")
    }

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
