import DesignSystem
import SwiftUI

/// The embeddable body of ``SelectionListView`` — an inline searchable selection list
/// with two-level disclosure, without any surrounding `NavigationStack`, navigation
/// title, or dismiss control.
///
/// Use this directly when you want the selection list inside your own screen (for
/// example a full-screen onboarding step that already has its own header and primary
/// button). Use ``SelectionListView`` instead when presenting in a `.sheet`.
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
///     SelectionListContentView(
///         nodes: nodes,
///         selectedID: choice,
///         isSearchable: true,
///         onSelect: { choice = $0 }
///     )
///     continueButton
/// }
/// ```
public struct SelectionListContentView<ID: Hashable>: View {

    // MARK: - Configuration

    private let nodes: [SelectionNode<ID>]
    private let selectedIDs: Set<ID>
    private let isSearchable: Bool
    private let searchPlaceholder: String
    private let showsContainerBackground: Bool
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
    ///   - showsContainerBackground: When `false`, hides the grouped list background and uses a plain full-width style. Use this when embedding the list inside a screen that provides its own background (e.g. an onboarding step). Defaults to `true`.
    ///   - onSelect: Closure invoked with the chosen leaf or child identifier.
    public init(
        nodes: some RandomAccessCollection<SelectionNode<ID>>,
        selectedID: ID? = nil,
        isSearchable: Bool = false,
        searchPlaceholder: String = "Search",
        showsContainerBackground: Bool = true,
        onSelect: @escaping (ID) -> Void
    ) {
        self.nodes = Array(nodes)
        self.selectedIDs = selectedID.map { [$0] } ?? []
        self.isSearchable = isSearchable
        self.searchPlaceholder = searchPlaceholder
        self.showsContainerBackground = showsContainerBackground
        self.onSelect = onSelect
    }

    /// Creates a multiple-choice selection list.
    /// - Parameters:
    ///   - nodes: The root nodes to display. Leaves select directly; parents expand inline.
    ///   - selectedIDs: Identifiers of the currently selected leaves or children, each marked with a checkmark.
    ///   - isSearchable: When `true`, shows an inline search field that filters across both levels. Defaults to `false`.
    ///   - searchPlaceholder: Hint shown in the search field when it is empty. Defaults to `"Search"`.
    ///   - showsContainerBackground: When `false`, hides the grouped list background and uses a plain full-width style. Defaults to `true`.
    ///   - onToggle: Closure invoked with the tapped leaf or child identifier. Toggle its membership in your selection.
    public init(
        nodes: some RandomAccessCollection<SelectionNode<ID>>,
        selectedIDs: Set<ID>,
        isSearchable: Bool = false,
        searchPlaceholder: String = "Search",
        showsContainerBackground: Bool = true,
        onToggle: @escaping (ID) -> Void
    ) {
        self.nodes = Array(nodes)
        self.selectedIDs = selectedIDs
        self.isSearchable = isSearchable
        self.searchPlaceholder = searchPlaceholder
        self.showsContainerBackground = showsContainerBackground
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
        // Each expandable parent is a single `ExpandableNodeRow` cell that owns its
        // children and animates its own height from a 0…1 progress. Driving the cell
        // height through `Animatable` lets the `List` interpolate it every frame, so the
        // rows below slide up in lockstep with the children clipping and fading away —
        // unlike a `DisclosureGroup` (or flat rows removed by `List` diffing), which
        // drop the children instantly and then close the gap, reading as a jump.
        List {
            ForEach(visibleNodes) { node in
                if node.isLeaf {
                    SelectionRow(
                        title: node.title,
                        subtitle: node.subtitle,
                        leadingGlyph: node.leadingGlyph,
                        isSelected: selectedIDs.contains(node.id),
                        isIndented: false,
                        disclosure: nil,
                        action: { onSelect(node.id) }
                    )
                } else {
                    ExpandableNodeRow(progress: expansionProgress(for: node.id)) {
                        SelectionRow(
                            title: node.title,
                            subtitle: selectedChildrenSummary(in: node) ?? node.subtitle,
                            leadingGlyph: node.leadingGlyph,
                            isSelected: false,
                            isIndented: false,
                            disclosure: isExpanded(node.id),
                            action: { toggleExpansion(node.id) }
                        )
                    } children: {
                        childRows(for: node)
                    }
                }
            }
        }
        .selectionListStyle(grouped: showsContainerBackground)
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

    /// Whether `id`'s parent is currently disclosed — explicitly expanded, or force-expanded while searching.
    private func isExpanded(_ id: ID) -> Bool {
        isSearching || expandedIDs.contains(id)
    }

    /// The disclosure progress (`1` expanded, `0` collapsed) handed to ``ExpandableNodeRow`` for `id`'s parent.
    private func expansionProgress(for id: ID) -> CGFloat {
        isExpanded(id) ? 1 : 0
    }

    /// The indented child rows shown beneath an expanded parent, separated by hairline dividers.
    @ViewBuilder
    private func childRows(for node: SelectionNode<ID>) -> some View {
        VStack(spacing: 0) {
            ForEach(node.children) { child in
                Divider()
                    .padding(.leading, theme.spacing.twoUnits)
                SelectionRow(
                    title: child.title,
                    subtitle: child.subtitle,
                    leadingGlyph: child.leadingGlyph,
                    isSelected: selectedIDs.contains(child.id),
                    isIndented: true,
                    disclosure: nil,
                    action: { onSelect(child.id) }
                )
            }
        }
    }

    private func selectedChildrenSummary(in node: SelectionNode<ID>) -> String? {
        let titles = node.children
            .filter { selectedIDs.contains($0.id) }
            .map(\.title)
        return titles.isEmpty ? nil : titles.joined(separator: ", ")
    }

    /// Toggles a parent's expansion, animating its ``ExpandableNodeRow`` height so the
    /// children and the rows below them slide smoothly. Ignored while searching, where
    /// every parent is force-expanded.
    private func toggleExpansion(_ id: ID) {
        guard !isSearching else { return }
        withAnimation(theme.motion.standardAnimation) {
            if expandedIDs.contains(id) {
                expandedIDs.remove(id)
            } else {
                expandedIDs.insert(id)
            }
        }
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

private extension View {
    /// Applies the grouped or plain list style based on `grouped`.
    ///
    /// Split into a `@ViewBuilder` branch rather than a ternary because `.insetGrouped`
    /// and `.plain` are distinct `ListStyle` types — a `grouped ? .insetGrouped : .plain`
    /// expression fails to type-check. When grouped, the inset-grouped surface is kept;
    /// when not, the list goes plain with a hidden scroll background so it blends into a
    /// caller-provided background (e.g. an onboarding step).
    @ViewBuilder
    func selectionListStyle(grouped: Bool) -> some View {
        #if os(iOS) || targetEnvironment(macCatalyst)
            if grouped {
                listStyle(.insetGrouped)
                    .scrollContentBackground(.automatic)
            } else {
                listStyle(.plain)
                    .scrollContentBackground(.hidden)
            }
        #else
            listStyle(.plain)
        #endif
    }
}
