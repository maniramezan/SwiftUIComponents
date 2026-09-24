import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("Container")
struct ContainerTests {

    @Test("renders every container style")
    func rendersEveryStyle() {
        renderForCoverage(
            VStack {
                Container(style: .plain) { Text("Plain") }
                Container(style: .card) { Text("Card") }
                Container(style: .elevated) { Text("Elevated") }
                Container(style: .outlined) { Text("Outlined") }
            },
            size: CGSize(width: 320, height: 400)
        )
    }
}
