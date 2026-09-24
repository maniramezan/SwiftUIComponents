import SwiftUI

/// A horizontal layout that fills the proposed width by scaling every subview's
/// ideal width by the same factor, so wider content keeps proportionally more room.
///
/// Backs ``SegmentSizing/fillProportionally``. With an unspecified or unbounded
/// width proposal (for example inside a horizontal `ScrollView`, or while
/// `ViewThatFits` measures ideal sizes) it lays subviews out at their ideal
/// widths, exactly like an `HStack`.
struct ProportionalHStackLayout: Layout {

    /// Horizontal gap between adjacent subviews.
    var spacing: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache _: inout ()) -> CGSize {
        let widths = Self.widths(
            idealWidths: subviews.map { $0.sizeThatFits(.unspecified).width },
            availableWidth: proposal.width,
            spacing: spacing
        )
        let height =
            zip(subviews, widths)
            .map { subview, width in
                subview.sizeThatFits(ProposedViewSize(width: width, height: proposal.height)).height
            }
            .max() ?? 0
        return CGSize(width: Self.totalWidth(widths, spacing: spacing), height: height)
    }

    func placeSubviews(in bounds: CGRect, proposal _: ProposedViewSize, subviews: Subviews, cache _: inout ()) {
        let widths = Self.widths(
            idealWidths: subviews.map { $0.sizeThatFits(.unspecified).width },
            availableWidth: bounds.width,
            spacing: spacing
        )
        var x = bounds.minX
        for (subview, width) in zip(subviews, widths) {
            subview.place(
                at: CGPoint(x: x, y: bounds.midY),
                anchor: .leading,
                proposal: ProposedViewSize(width: width, height: bounds.height)
            )
            x += width + spacing
        }
    }
}

// MARK: - Pure math

extension ProportionalHStackLayout {

    /// Distributes `availableWidth` (minus the inter-item gaps) across items in
    /// proportion to their ideal widths.
    ///
    /// - Parameters:
    ///   - idealWidths: Each subview's ideal width, in order.
    ///   - availableWidth: The proposed width, or `nil`/non-finite for an unbounded proposal.
    ///   - spacing: The gap inserted between adjacent items.
    /// - Returns: One width per item. Ideal widths are returned unchanged when the
    ///   proposal is unbounded or every ideal width is zero.
    nonisolated static func widths(
        idealWidths: [CGFloat],
        availableWidth: CGFloat?,
        spacing: CGFloat
    ) -> [CGFloat] {
        let totalIdeal = idealWidths.reduce(0, +)
        guard let availableWidth, availableWidth.isFinite, totalIdeal > 0 else { return idealWidths }
        let gaps = spacing * CGFloat(max(0, idealWidths.count - 1))
        let scale = max(0, availableWidth - gaps) / totalIdeal
        return idealWidths.map { $0 * scale }
    }

    /// The width occupied by `widths` laid out with `spacing` between them.
    nonisolated static func totalWidth(_ widths: [CGFloat], spacing: CGFloat) -> CGFloat {
        widths.reduce(0, +) + spacing * CGFloat(max(0, widths.count - 1))
    }
}
