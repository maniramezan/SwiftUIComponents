import Foundation

/// Filters `nodes` against `query`, case-insensitively, preserving order.
///
/// Leaves are kept when their title or subtitle matches. A parent is kept whole when
/// its own title/subtitle matches; otherwise it is kept only if some child matches,
/// pruned to those children. An empty or whitespace-only query returns every node
/// unchanged.
/// - Parameters:
///   - nodes: The root nodes to filter.
///   - query: The search text entered by the user.
/// - Returns: The matching nodes, with non-matching children removed where applicable.
nonisolated func filteredSelectionNodes<ID: Hashable>(
    _ nodes: [SelectionNode<ID>],
    query: String
) -> [SelectionNode<ID>] {
    let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
    guard !trimmed.isEmpty else { return nodes }
    return nodes.compactMap { node in
        if node.isLeaf {
            return node.matches(trimmed) ? node : nil
        }
        if node.matches(trimmed) {
            return node
        }
        let matchingChildren = node.children.filter { $0.matches(trimmed) }
        return matchingChildren.isEmpty ? nil : node.replacingChildren(matchingChildren)
    }
}
