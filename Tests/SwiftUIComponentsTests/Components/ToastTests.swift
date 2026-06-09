import Components
import SwiftUI
import Testing

@MainActor
@Suite("Toast")
struct ToastTests {

    @Test("ToastView constructs for every role", arguments: [ToastRole.info, .success, .warning, .error])
    func toastViewRoles(role: ToastRole) {
        _ = ToastView("Message", role: role)
    }

    @Test("ToastView accepts a custom system image")
    func toastViewSystemImage() {
        _ = ToastView("Offline", role: .error, systemImage: "wifi.slash")
    }

    @Test("ToastAction handler is wired and runs on invocation")
    func toastActionHandlerRuns() {
        var didRun = false
        let action = ToastAction("Undo") { didRun = true }
        #expect(action.title == "Undo")
        action.handler()
        #expect(didRun)
    }

    @Test("ToastView constructs with a trailing action")
    func toastViewWithAction() {
        _ = ToastView("Item deleted", role: .info, action: .init("Undo") {})
    }

    @Test("convenience toast modifier constructs with defaults")
    func toastModifierDefaults() {
        _ = Text("Host").toast("Saved", role: .success, isPresented: .constant(true))
    }

    @Test("convenience toast modifier supports a persistent (nil) duration with action")
    func toastModifierPersistentWithAction() {
        _ = Text("Host").toast(
            "Item deleted",
            role: .info,
            isPresented: .constant(true),
            edge: .top,
            duration: nil,
            action: .init("Undo") {}
        )
    }

    @Test("ViewBuilder toast modifier constructs with custom content")
    func toastModifierCustomContent() {
        _ = Text("Host").toast(isPresented: .constant(true), edge: .bottom, duration: .seconds(5)) {
            ToastView("Custom", role: .warning)
        }
    }
}
