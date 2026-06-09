import Components
import DesignSystem
import SwiftUI

struct ToastDetailView: View {
    @Environment(\.designTheme) private var theme

    @State private var showBottom = false
    @State private var showTop = false
    @State private var showPersistent = false
    @State private var undoCount = 0

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
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
