import SwiftUI

nonisolated struct SphereOrbitPlacement: ViewModifier, Animatable {
    var position: Double
    let turns: Double
    let phase: Double
    let radius: CGFloat
    let style: SphereOrbitStyle
    let orientation: SphereOrbitGeometry.Orientation

    var animatableData: Double {
        get { position }
        set { position = newValue }
    }

    var placement: SphereOrbitGeometry.Placement {
        SphereOrbitGeometry.placement(
            angle: (turns + position) * 2 * .pi + phase,
            radius: radius, style: style, orientation: orientation
        )
    }

    func body(content: Content) -> some View {
        let placement = placement
        content
            .scaleEffect(placement.scale)
            .offset(x: placement.offset.x, y: placement.offset.y)
            .zIndex(style == .ring ? 1 : placement.depth)
    }
}
