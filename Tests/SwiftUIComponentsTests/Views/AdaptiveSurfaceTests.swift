import SwiftUI
import Testing
@testable import Components

@Suite("Adaptive surface")
@MainActor
struct AdaptiveSurfaceTests {
    @Test(
        "Glass requires OS support and both compatibility and transparency permission",
        arguments: [false, true], [(false, false), (false, true), (true, false), (true, true)])
    func glassPolicy(supported: Bool, settings: (Bool, Bool)) {
        let (compatibility, reduced) = settings
        #expect(
            AdaptiveSurface.usesLiquidGlass(
                supportsLiquidGlass: supported, requiresCompatibility: compatibility, reduceTransparency: reduced
            ) == (supported && !compatibility && !reduced))
    }

    @Test("Reduce Transparency selects regular fallback material")
    func fallbackMaterial() {
        #expect(AdaptiveSurface.fallbackMaterialStyle(reduceTransparency: true) == .regular)
        #expect(AdaptiveSurface.fallbackMaterialStyle(reduceTransparency: false) == .ultraThin)
    }

    @Test("Outlines preserve their intended geometry")
    func outlineGeometry() {
        let bounds = CGRect(x: 0, y: 0, width: 100, height: 40)
        #expect(AdaptiveSurfaceShape.circle.resolved(cornerRadius: 8).path(in: bounds).boundingRect.width == 40)
        #expect(AdaptiveSurfaceShape.capsule.resolved(cornerRadius: 8).path(in: bounds).boundingRect == bounds)
        #expect(AdaptiveSurfaceShape.roundedRectangle.resolved(cornerRadius: 8).path(in: bounds).boundingRect == bounds)
    }

    @Test(
        "Every outline renders with configurable borders",
        arguments: AdaptiveSurfaceShape.allCases)
    func rendersFallback(shape: AdaptiveSurfaceShape) {
        renderForCoverage(
            Text("Sample").padding()
                .designAdaptiveSurface(
                    tint: .blue, interactive: true, cornerRadius: 8, shape: shape,
                    fallbackBorderColor: .white, fallbackBorderWidth: 1
                )
        )
    }
}
