import SwiftUI

struct SphereOrbitCanvasLayout: Layout {
    let idealSide: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        SphereOrbitGeometry.canvasSize(width: proposal.width, height: proposal.height, idealSide: idealSide)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for subview in subviews {
            subview.place(at: bounds.origin, proposal: ProposedViewSize(bounds.size))
        }
    }
}
