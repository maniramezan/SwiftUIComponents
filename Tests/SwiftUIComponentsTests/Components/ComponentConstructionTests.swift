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
    _ = DesignErrorBanner("Something failed.")
    _ = DesignErrorSection(message: "Could not load.")
    _ = DesignErrorSection(title: "Network Error", message: "Offline.")
    _ = Text("Adaptive").designAdaptiveSurface()
    _ = Text("Adaptive Tinted").designAdaptiveSurface(tint: .blue.opacity(0.2))
    _ = Text("Selectable").designSelectableCardSurface(isSelected: false)
    _ = Text("Selectable On").designSelectableCardSurface(isSelected: true)
    _ = Button("Action") {}.designAdaptiveButtonStyle()
    _ = Button("Prominent") {}.designAdaptiveButtonStyle(prominent: true)
    _ = NavigationStack {
        Text("Content")
            .toolbar {
                DesignDismissToolbarButton {}
                DesignConfirmToolbarButton(accessibilityLabel: "Save") {}
            }
    }
}
