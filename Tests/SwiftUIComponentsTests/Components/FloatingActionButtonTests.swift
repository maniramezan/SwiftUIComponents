import DesignSystem
import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("Floating action button", .serialized)
struct FloatingActionButtonTests {
    @Test("circular and extended labels render in enabled and disabled states", arguments: [false, true])
    func rendersStyles(showsTitle: Bool) {
        renderForCoverage(
            HStack {
                FloatingActionButton(showsTitle: showsTitle, action: {}) {
                    Label("Add item", systemImage: "plus")
                }
                FloatingActionButton(showsTitle: showsTitle, action: {}) {
                    Label("Disabled action", systemImage: "plus")
                }
                .disabled(true)
            }
        )
    }

    @Test("large text and custom theme tokens render without a fixed default font")
    func rendersCustomTheme() {
        renderForCoverage(
            FloatingActionButton(showsTitle: true, action: {}) {
                Label("Add item", systemImage: "plus")
            }
            .designTheme(
                DefaultTheme(
                    spacing: DefaultSpacing(sixUnits: 64),
                    motion: DefaultMotion(minimumHitTarget: 60)
                )
            )
            .dynamicTypeSize(.accessibility3),
            size: CGSize(width: 600, height: 240)
        )
    }
}
