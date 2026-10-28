import DesignSystem
import SwiftUI
import Testing

@testable import Components

@MainActor
struct SphereViewTests {
    @Test(
        "Sphere sizing preserves explicit diameters and applies themed defaults for invalid input",
        arguments: [
            CGFloat?.none, .some(.nan), .some(-1), .some(0), .some(64),
        ])
    func sizing(diameter: CGFloat?) throws {
        var observedSize: CGSize?
        renderForCoverage(
            SphereView(diameter: diameter, tint: .purple) { Text("A") }
                .onGeometryChange(for: CGSize.self) {
                    $0.size
                } action: {
                    observedSize = $0
                }
        )
        let size = try #require(observedSize)
        let expected = diameter.flatMap { $0.isFinite && $0 > 0 ? $0 : nil } ?? DefaultTheme().spacing.sixUnits * 2
        #expect(size == CGSize(width: expected, height: expected))
    }
}
