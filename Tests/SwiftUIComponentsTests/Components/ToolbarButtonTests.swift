import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("Toolbar buttons")
struct ToolbarButtonTests {

    @Test("renders dismiss and confirm buttons inside a navigation stack")
    func rendersDismissAndConfirm() {
        renderForCoverage(
            NavigationStack {
                Text("Content")
                    .toolbar {
                        DismissToolbarButton {}
                        ConfirmToolbarButton(accessibilityLabel: "Save") {}
                    }
            }
        )
    }

    @Test("renders a disabled confirm button")
    func rendersDisabledConfirm() {
        renderForCoverage(
            NavigationStack {
                Text("Content")
                    .toolbar {
                        ConfirmToolbarButton(accessibilityLabel: "Save", isDisabled: true) {}
                    }
            }
        )
    }

    @Test("renders a confirm button with a custom system image")
    func rendersCustomImage() {
        renderForCoverage(
            NavigationStack {
                Text("Content")
                    .toolbar {
                        ConfirmToolbarButton(systemImage: "plus", accessibilityLabel: "Add") {}
                    }
            }
        )
    }

    @Test("renders the confirmation content in enabled and disabled states")
    func rendersConfirmationContent() {
        renderForCoverage(
            ToolbarConfirmationContent(title: "Save", systemImage: "checkmark", isDisabled: false, action: {})
        )
        renderForCoverage(
            ToolbarConfirmationContent(title: "Save", systemImage: "checkmark", isDisabled: true, action: {})
        )
    }
}
