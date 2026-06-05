import Foundation

/// A node in a one- or two-level ``SelectionListView`` hierarchy.
///
/// A node with no ``children`` is a **leaf** that selects directly when tapped.
/// A node with children is an **expandable parent**: tapping it reveals its
/// children inline, and selecting one returns that child's identifier. Build
/// a flat list of leaves for a single-level picker, or mix leaves and parents
/// for a two-level picker (for example, languages whose pluricentric entries
/// expand into regional variants).
public struct SelectionNode<ID: Hashable>: Identifiable {
    /// Stable identifier for the node. Leaf and child identifiers are the values reported by ``SelectionListView`` selection.
    public let id: ID
    /// Primary text shown for the row (e.g. an autonym such as "Español" or a region name such as "Mexico").
    public let title: String
    /// Optional secondary text shown beneath the title (e.g. a resulting locale tag). Defaults to `nil`.
    public let subtitle: String?
    /// Optional leading glyph rendered before the title, typically an emoji or flag. Defaults to `nil`.
    public let leadingGlyph: String?
    /// Child nodes revealed when an expandable parent is tapped. Empty for a leaf.
    public let children: [SelectionNode<ID>]

    /// Creates a selection node.
    /// - Parameters:
    ///   - id: Stable, unique identifier reported back through selection.
    ///   - title: Primary row text.
    ///   - subtitle: Optional secondary text. Defaults to `nil`.
    ///   - leadingGlyph: Optional leading emoji/flag glyph. Defaults to `nil`.
    ///   - children: Child nodes. Pass an empty array (the default) to make this a directly selectable leaf.
    public init(
        id: ID,
        title: String,
        subtitle: String? = nil,
        leadingGlyph: String? = nil,
        children: [SelectionNode<ID>] = []
    ) {
        self.id = id
        self.title = title
        self.subtitle = subtitle
        self.leadingGlyph = leadingGlyph
        self.children = children
    }

    /// Whether the node has no children and is therefore directly selectable.
    public var isLeaf: Bool { children.isEmpty }
}

extension SelectionNode: Sendable where ID: Sendable {}

extension SelectionNode {
    /// Whether the node's title or subtitle contains `query`, case-insensitively.
    func matches(_ query: String) -> Bool {
        title.localizedCaseInsensitiveContains(query)
            || (subtitle?.localizedCaseInsensitiveContains(query) ?? false)
    }

    /// Returns a copy of the node with its children replaced.
    func replacingChildren(_ newChildren: [SelectionNode<ID>]) -> SelectionNode<ID> {
        SelectionNode(id: id, title: title, subtitle: subtitle, leadingGlyph: leadingGlyph, children: newChildren)
    }
}
