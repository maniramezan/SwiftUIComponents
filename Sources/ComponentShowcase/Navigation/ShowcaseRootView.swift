import Components
import DesignSystem
import SwiftUI

/// The root navigation split view listing all showcase components in the sidebar.
///
/// The public entry point of the `ComponentShowcase` product. Host it from a scratch
/// app target (or a preview) to browse every component with live controls:
///
/// ```swift
/// import ComponentShowcase
///
/// @main
/// struct ShowcaseApp: App {
///     var body: some Scene {
///         WindowGroup { ShowcaseRootView() }
///     }
/// }
/// ```
public struct ShowcaseRootView: View {

    @State private var selection: ShowcaseComponent?
    @Environment(\.designTheme) private var theme

    /// Creates the showcase browser.
    public init() {}

    /// Components grouped for sidebar sections.
    private var groups: [(title: String, items: [ShowcaseComponent])] {
        let allGroups = Dictionary(grouping: ShowcaseComponent.allCases, by: \.group)
        let order = ["Actions", "Controls", "Display", "Surfaces", "Feedback", "Pagination", "Chat", "Collections"]
        return order.compactMap { key in
            guard let items = allGroups[key] else { return nil }
            return (title: key, items: items)
        }
    }

    /// The sidebar of component groups and the selected component's detail page.
    public var body: some View {
        NavigationSplitView {
            List(selection: $selection) {
                ForEach(groups, id: \.title) { group in
                    Section(group.title) {
                        ForEach(group.items) { component in
                            Label(component.rawValue, systemImage: component.systemImage)
                                .tag(component)
                        }
                    }
                }
            }
            .navigationTitle("Components")
        } detail: {
            if let selection {
                ShowcaseDetailView(component: selection)
                    .id(selection)
            } else {
                ContentUnavailableView(
                    "Select a Component",
                    systemImage: "sidebar.left",
                    description: Text("Choose a component from the list to preview it.")
                )
            }
        }
    }
}

#Preview {
    ShowcaseRootView()
}
