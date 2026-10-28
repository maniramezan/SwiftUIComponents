import SwiftUI

nonisolated struct SphereOrbitPlacement: ViewModifier, Animatable {
    var position: Double
    let geometry: SphereOrbitFrameGeometry
    let pose: SphereOrbitGeometry.Pose

    var animatableData: Double {
        get { position }
        set { position = newValue }
    }

    var placement: SphereOrbitGeometry.Placement {
        SphereOrbitGeometry.placement(
            angle: (pose.turns + position) * 2 * .pi + geometry.phase,
            radius: geometry.radius, style: geometry.style, orientation: pose.orientation
        )
    }

    func body(content: Content) -> some View {
        let placement = placement
        content
            .scaleEffect(placement.scale)
            .offset(x: placement.offset.x, y: placement.offset.y)
            .zIndex(geometry.style == .ring ? 1 : placement.depth)
    }
}
