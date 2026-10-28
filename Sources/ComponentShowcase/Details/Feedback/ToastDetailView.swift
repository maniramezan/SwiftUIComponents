import Components
import DesignSystem
import SwiftUI

struct ToastDetailView: View {
    @Environment(\.designTheme) private var theme

    @State private var message = "Message"
    @State private var role = 0
    @State private var top = false
    @State private var seconds = 3.0
    @State private var action = false
    @State private var customIcon = false
    @State private var playground = false
    @State private var showBottom = false
    @State private var showTop = false
    @State private var showPersistent = false
    @State private var undoCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                TextField("Message", text: $message)
                Picker("Role", selection: $role) {
                    Text("Information").tag(0)
                    Text("Success").tag(1)
                    Text("Warning").tag(2)
                    Text("Error").tag(3)
                }
                Toggle("Top edge", isOn: $top)
                Toggle("Action makes the toast persistent", isOn: $action)
                Toggle("Custom icon", isOn: $customIcon)
                LabeledContent("Duration") { Slider(value: $seconds, in: 1...10) }
                Button("Present") { playground = true }
            }

            ShowcaseSection("Roles") {
                VStack(spacing: theme.spacing.oneUnit) {
                    ToastView("New version available", role: .info)
                    ToastView("Saved to your library", role: .success)
                    ToastView("Battery is low", role: .warning)
                    ToastView("Upload failed", role: .error, systemImage: "wifi.slash")
                }
            }

            ShowcaseSection("With action") {
                ToastView("Item deleted", role: .info, action: .init("Undo") {})
            }

            ShowcaseSection("Presentation") {
                VStack(spacing: theme.spacing.oneUnit) {
                    ThemeButton("Show bottom toast (auto-dismiss)") { showBottom = true }
                    ThemeButton("Show top toast (auto-dismiss)", role: .secondary) { showTop = true }
                    ThemeButton("Show persistent toast with Undo", role: .secondary) { showPersistent = true }
                    Text("Undo tapped \(undoCount) time(s)")
                        .designTextStyle(.secondary)
                }
            }
        }
        // Anchors the toast overlays to the full detail area.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .toast(
            message, role: [ToastRole.info, .success, .warning, .error][role],
            systemImage: customIcon ? "star" : nil, isPresented: $playground,
            edge: top ? .top : .bottom, duration: .seconds(seconds),
            action: action ? ToastAction("Action", handler: { undoCount += 1 }) : nil
        )
        .toast("Saved to your library", role: .success, isPresented: $showBottom)
        .toast("New version available", role: .info, isPresented: $showTop, edge: .top)
        .toast(
            "Item deleted",
            role: .warning,
            isPresented: $showPersistent,
            duration: nil,
            action: .init("Undo") { undoCount += 1 }
        )
    }
}

#Preview {
    ScrollView {
        ToastDetailView()
            .padding()
    }
}
