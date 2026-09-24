import SwiftUI

/// A SwiftUI `Layout` that arranges subviews in a row, wrapping onto a new
/// line whenever the next subview would overflow the available width.
///
/// Use `FlowLayout` for tag clouds, word-by-word renderers, pill/chip rows
/// that should reflow instead of horizontally scrolling, or any other UI
/// where a fixed grid would either crowd the leading edge or break visual
/// rhythm.
///
/// Items are placed left-to-right with `spacing` between adjacent items on a
/// line and `lineSpacing` between successive lines. Wrapping occurs as soon
/// as appending the next item would exceed the proposed width.
///
/// ```swift
/// FlowLayout(spacing: 8, lineSpacing: 8) {
///     ForEach(tags) { tag in
///         TagView(tag)
///     }
/// }
/// ```
///
/// The layout reports a size whose width matches its proposed (or actual)
/// width and whose height is the sum of all line heights plus interline
/// spacing — there is no clipping or vertical scrolling built in.
public struct FlowLayout: Layout {

    /// Horizontal spacing between adjacent items on the same line.
    public var spacing: CGFloat

    /// Vertical spacing inserted between successive lines after a wrap.
    public var lineSpacing: CGFloat

    /// Creates a flow layout with the given inter-item spacings.
    ///
    /// - Parameters:
    ///   - spacing: Horizontal spacing between adjacent items. Defaults to `0`.
    ///   - lineSpacing: Vertical spacing between successive lines. Defaults to `0`.
    public init(spacing: CGFloat = .zero, lineSpacing: CGFloat = .zero) {
        self.spacing = spacing
        self.lineSpacing = lineSpacing
    }

    /// Returns the size needed to place all subviews within the proposed width.
    ///
    /// A bounded width proposal is reported back unchanged. An unspecified or
    /// infinite proposal (inside a horizontal `ScrollView`, or under `.fixedSize()`)
    /// lays every item on one line and reports that line's width, instead of an
    /// arbitrary placeholder width.
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        let maxWidth = Self.boundedWidth(proposal.width)
        return Self.arrange(
            sizes: Self.measure(subviews, maxWidth: maxWidth),
            maxWidth: maxWidth,
            spacing: spacing,
            lineSpacing: lineSpacing
        ).size
    }

    /// Places subviews in wrapped rows inside the provided bounds.
    public func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        // Use the actual allocated width so positions match the rendered width.
        let sizes = Self.measure(subviews, maxWidth: bounds.width)
        let result = Self.arrange(sizes: sizes, maxWidth: bounds.width, spacing: spacing, lineSpacing: lineSpacing)

        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: ProposedViewSize(sizes[index])
            )
        }
    }
}

// MARK: - Layout math

extension FlowLayout {

    /// Treats a missing or infinite proposal as unbounded.
    nonisolated static func boundedWidth(_ proposed: CGFloat?) -> CGFloat {
        guard let proposed, proposed.isFinite else { return .infinity }
        return proposed
    }

    /// Measures each subview at its ideal size, re-measuring any item wider than
    /// `maxWidth` against that width so long content (e.g. a multi-word tag) wraps
    /// inside the line instead of overflowing it.
    static func measure(_ subviews: Subviews, maxWidth: CGFloat) -> [CGSize] {
        subviews.map { subview in
            let ideal = subview.sizeThatFits(.unspecified)
            guard maxWidth.isFinite, ideal.width > maxWidth else { return ideal }
            return subview.sizeThatFits(ProposedViewSize(width: maxWidth, height: nil))
        }
    }

    /// Positions items of the given sizes left-to-right, wrapping onto a new line
    /// whenever the next item would overflow `maxWidth`.
    ///
    /// - Parameters:
    ///   - sizes: The size of each item, in order.
    ///   - maxWidth: The line width, or `.infinity` for a single unbounded line.
    ///   - spacing: Horizontal gap between items on a line.
    ///   - lineSpacing: Vertical gap between lines.
    /// - Returns: The item origins, plus the overall size — `maxWidth` wide when it
    ///   is finite, otherwise the width of the widest line.
    nonisolated static func arrange(
        sizes: [CGSize],
        maxWidth: CGFloat,
        spacing: CGFloat,
        lineSpacing: CGFloat
    ) -> (size: CGSize, positions: [CGPoint]) {
        var positions = [CGPoint]()
        positions.reserveCapacity(sizes.count)
        var currentX: CGFloat = .zero
        var currentY: CGFloat = .zero
        var lineHeight: CGFloat = .zero
        var totalHeight: CGFloat = .zero
        var widestLine: CGFloat = .zero

        for size in sizes {
            // Wrap to a new line when the next item would overflow. The
            // `currentX > 0` guard prevents wrapping an item that is already at
            // the line start but still wider than the available width — in
            // that case we render it overflowing rather than emitting an empty
            // line followed by the same overflow.
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }

            positions.append(CGPoint(x: currentX, y: currentY))
            widestLine = max(widestLine, currentX + size.width)
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalHeight = max(totalHeight, currentY + lineHeight)
        }

        let width = maxWidth.isFinite ? maxWidth : widestLine
        return (CGSize(width: width, height: totalHeight), positions)
    }
}

#Preview("Flow Layout — short tags") {
    FlowLayout(spacing: 8, lineSpacing: 8) {
        ForEach(["SwiftUI", "Layout", "Flow", "Wrap", "Tag", "Chip", "Reusable"], id: \.self) {
            label in
            Text(label)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(.tint.opacity(0.2), in: Capsule())
        }
    }
    .padding()
    .frame(width: 220)
}
