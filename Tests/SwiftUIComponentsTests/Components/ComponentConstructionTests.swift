import Components
import SwiftUI
import Testing

@Test("Themed components are constructible")
@MainActor
func themedComponentsAreConstructible() {
    _ = ThemeButton("Continue") {}
    _ = Button("Continue") {}
        .buttonStyle(ThemeButtonStyle(role: .secondary))
    _ = Toggle("Enabled", isOn: .constant(true))
        .toggleStyle(ThemeToggleStyle())
    _ = Container {
        Text("Content")
    }
    _ = Badge("Beta")
    _ = PillChip("All", isSelected: true) {}
    _ = SearchBar(text: .constant(""))
    _ = LoadingView("Loading")
    _ = EmptyStateView(title: "No Items", message: "Try again", systemImage: "tray")
    _ = Text("Error")
        .designTextStyle(.error)
        .designCardSurface()
    _ = ErrorBanner("Something failed.")
    _ = ErrorSection(message: "Could not load.")
    _ = ErrorSection(title: "Network Error", message: "Offline.")
    _ = Text("Adaptive").designAdaptiveSurface()
    _ = Text("Adaptive Tinted").designAdaptiveSurface(tint: .blue.opacity(0.2))
    _ = Text("Selectable").designSelectableCardSurface(isSelected: false)
    _ = Text("Selectable On").designSelectableCardSurface(isSelected: true)
    _ = Button("Action") {}.designAdaptiveButtonStyle()
    _ = Button("Prominent") {}.designAdaptiveButtonStyle(prominent: true)
    _ = NavigationStack {
        Text("Content")
            .toolbar {
                DismissToolbarButton {}
                ConfirmToolbarButton(accessibilityLabel: "Save") {}
            }
    }

    let pages: [ConstructionPage] = [
        ConstructionPage(id: 0, title: "First"),
        ConstructionPage(id: 1, title: "Second"),
    ]
    let pageSelection: Binding<Int> = .constant(0)
    _ = TitledPageView(pages, selection: pageSelection, title: \ConstructionPage.title) { page in
        Text(page.title)
    }
}

private struct ConstructionPage: Identifiable {
    let id: Int
    let title: String
}
