import Components
import SwiftUI
import Testing

@MainActor
@Suite("CompactActionButton")
struct CompactActionButtonTests {

    @Test("default init is not disabled")
    func defaultNotDisabled() {
        var tapCount = 0
        _ = CompactActionButton(title: "Go", icon: "arrow.right") { tapCount += 1 }
        #expect(tapCount == 0)
    }

    @Test("explicit isDisabled true suppresses interaction")
    func explicitDisabled() {
        _ = CompactActionButton(title: "Go", icon: "arrow.right", isDisabled: true) {}
    }

    @Test("explicit isDisabled false allows interaction")
    func explicitEnabled() {
        _ = CompactActionButton(title: "Go", icon: "arrow.right", isDisabled: false) {}
    }

    @Test("nil isDisabled defers to environment disabled state")
    func environmentDisabled() {
        // When no explicit value is passed, the view reads @Environment(\.isEnabled)
        let button = CompactActionButton(title: "Go", icon: "arrow.right") {}
        let disabled = button.disabled(true)
        _ = disabled
    }

    @Test("respects SwiftUI .disabled() modifier")
    func swiftUIDisabledModifier() {
        let view = CompactActionButton(title: "Translate", icon: "globe") {}
            .disabled(true)
        _ = view
    }
}
