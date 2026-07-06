import Components
import SwiftUI
import Testing

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

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

    @Test("convenience toast modifier treats action toasts as persistent")
    func toastModifierActionIgnoresDuration() {
        _ = Text("Host").toast(
            "Item deleted",
            role: .info,
            isPresented: .constant(true),
            duration: .seconds(3),
            action: .init("Undo") {}
        )
    }

    @Test("ViewBuilder toast modifier constructs with custom content")
    func toastModifierCustomContent() {
        _ = Text("Host").toast(isPresented: .constant(true), edge: .bottom, duration: .seconds(5)) {
            ToastView("Custom", role: .warning)
        }
    }

    @Test("toast modifier constructs on a full-bleed host")
    func toastModifierFullBleedHost() {
        render(
            Color.clear
                .ignoresSafeArea()
                .toast("Saved", role: .success, isPresented: .constant(true), edge: .bottom)
        )
    }
}

// MARK: - Helpers

extension ToastTests {

    @MainActor
    private func render<V: View>(_ view: V) {
        #if canImport(UIKit)
            let hostingController = UIHostingController(rootView: view)
            hostingController.view.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 200))
            hostingController.view.setNeedsLayout()
            hostingController.view.layoutIfNeeded()
        #elseif canImport(AppKit)
            let hostingController = NSHostingController(rootView: view)
            hostingController.view.frame = CGRect(origin: .zero, size: CGSize(width: 320, height: 200))
            hostingController.view.needsLayout = true
            hostingController.view.layoutSubtreeIfNeeded()
        #else
            _ = view
        #endif
    }
}
