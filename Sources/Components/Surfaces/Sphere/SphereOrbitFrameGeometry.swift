import SwiftUI

nonisolated struct SphereOrbitFrameGeometry {
    let side: CGFloat
    let radius: CGFloat
    let phase: Double

    init(size: CGSize, configuration: SphereOrbitConfiguration) {
        side = min(size.width, size.height)
        let radiusRatio =
            configuration.style == .ring
            ? SphereOrbitGeometry.ringRadiusRatio : SphereOrbitGeometry.spatialRadiusRatio
        radius = SphereOrbitGeometry.positive(configuration.radius, fallback: side * radiusRatio)
        phase = SphereOrbitGeometry.phase(configuration.phase.radians)
    }
}
