import Components
import SwiftUI
import Testing

@Test("Themed components are constructible")
@MainActor
func themedComponentsAreConstructible() {
    _ = DesignButton("Continue") {}
    _ = Button("Continue") {}
        .buttonStyle(DesignButtonStyle(role: .secondary))
    _ = Toggle("Enabled", isOn: .constant(true))
        .toggleStyle(DesignToggleStyle())
    _ = DesignContainer {
        Text("Content")
    }
    _ = DesignBadge("Beta")
    _ = DesignPillChip("All", isSelected: true) {}
    _ = DesignSearchBar(text: .constant(""))
    _ = DesignLoadingView("Loading")
    _ = DesignEmptyStateView(title: "No Items", message: "Try again", systemImage: "tray")
    _ = Text("Error")
        .designTextStyle(.error)
        .designCardSurface()
}
