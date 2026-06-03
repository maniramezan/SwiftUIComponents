import DesignSystem
import SwiftUI

/// A themed selection list presented inside a sheet or drawer, with optional inline
/// search and two-level disclosure. Supports both single-choice and multiple-choice
/// selection.
///
/// Present it yourself with `.sheet` so you control detents, drag indicators, and
/// dismissal timing. Rows come from a ``SelectionNode`` tree: leaf nodes are
/// selectable, while parent nodes expand inline to reveal their children. The sheet
/// is **controlled** — it reflects the selection you pass in and reports taps through a
/// callback; it never mutates selection or dismisses itself. Selected rows show a
/// checkmark, and a collapsed parent lists its selected children as its subtitle.
///
/// To embed the same list inside your own screen (without the surrounding navigation
/// chrome and dismiss button), use ``SelectionSheetContentView`` directly.
///
/// ```swift
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

    private let title: String
    private let content: SelectionSheetContentView<ID>
    @Environment(\.dismiss) private var dismiss

    /// Creates a single-choice selection sheet.
    /// - Parameters:
    ///   - title: Navigation title shown at the top of the sheet.
    ///   - nodes: The root nodes to display. Leaves select directly; parents expand inline.
    ///   - selectedID: Identifier of the currently selected leaf or child, marked with a checkmark. Pass `nil` for no selection.
    ///   - isSearchable: When `true`, shows an inline search field that filters across both levels. Defaults to `false`.
    ///   - searchPlaceholder: Hint shown in the search field when it is empty. Defaults to `"Search"`.
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
        self.content = SelectionSheetContentView(
            nodes: nodes,
            selectedID: selectedID,
            isSearchable: isSearchable,
            searchPlaceholder: searchPlaceholder,
            onSelect: onSelect
        )
    }

    /// Creates a multiple-choice selection sheet.
    /// - Parameters:
    ///   - title: Navigation title shown at the top of the sheet.
    ///   - nodes: The root nodes to display. Leaves select directly; parents expand inline.
    ///   - selectedIDs: Identifiers of the currently selected leaves or children, each marked with a checkmark.
    ///   - isSearchable: When `true`, shows an inline search field that filters across both levels. Defaults to `false`.
    ///   - searchPlaceholder: Hint shown in the search field when it is empty. Defaults to `"Search"`.
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
        self.content = SelectionSheetContentView(
            nodes: nodes,
            selectedIDs: selectedIDs,
            isSearchable: isSearchable,
            searchPlaceholder: searchPlaceholder,
            onToggle: onToggle
        )
    }

    /// The SwiftUI body for the selection sheet.
    public var body: some View {
        NavigationStack {
            content
                .navigationTitle(title)
                #if os(iOS) || targetEnvironment(macCatalyst)
                    .navigationBarTitleDisplayMode(.inline)
                #endif
                .toolbar { DismissToolbarButton { dismiss() } }
        }
    }
}
