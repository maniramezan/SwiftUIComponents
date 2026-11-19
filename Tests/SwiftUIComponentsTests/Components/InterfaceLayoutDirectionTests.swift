import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("InterfaceLayoutDirection")
struct InterfaceLayoutDirectionTests {

    @Test(
        "renders a list under each interface direction",
        arguments: [LayoutDirection.leftToRight, .rightToLeft]
    )
    func rendersListForDirection(direction: LayoutDirection) {
        renderForCoverage(
            List(["First", "Second", "Third"], id: \.self) { title in
                Text(title)
            }
            .interfaceLayoutDirection(direction)
        )
    }

    @Test("renders a navigation stack after the interface direction flips")
    func rendersAfterDirectionFlip() {
        for direction in [LayoutDirection.rightToLeft, .leftToRight] {
            renderForCoverage(
                NavigationStack {
                    Form {
                        Text("Row")
                    }
                }
                .interfaceLayoutDirection(direction)
            )
        }
    }
}
