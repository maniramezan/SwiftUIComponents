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
    public func sizeThatFits(
        proposal: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) -> CGSize {
        // Use a large finite width when the proposal is unspecified or infinite
        // so the height isn't inflated into something unbounded.
        let effectiveWidth = proposal.width.flatMap { $0.isFinite ? $0 : nil } ?? 10_000
        return arrangeViews(maxWidth: effectiveWidth, subviews: subviews).size
    }

    /// Places subviews in wrapped rows inside the provided bounds.
    public func placeSubviews(
        in bounds: CGRect,
        proposal _: ProposedViewSize,
        subviews: Subviews,
        cache _: inout ()
    ) {
        // Use the actual allocated width so positions match the rendered width.
        let result = arrangeViews(maxWidth: bounds.width, subviews: subviews)

        for (index, subview) in subviews.enumerated() {
            let position = result.positions[index]
            subview.place(
                at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                proposal: .unspecified
            )
        }
    }
}

// MARK: - Layout math

extension FlowLayout {

    fileprivate func arrangeViews(maxWidth: CGFloat, subviews: Subviews) -> (
        size: CGSize, positions: [CGPoint]
    ) {
        var positions = [CGPoint]()
        var currentX: CGFloat = .zero
        var currentY: CGFloat = .zero
        var lineHeight: CGFloat = .zero
        var totalHeight: CGFloat = .zero

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)

            // Wrap to a new line when the next subview would overflow. The
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
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalHeight = max(totalHeight, currentY + lineHeight)
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
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
