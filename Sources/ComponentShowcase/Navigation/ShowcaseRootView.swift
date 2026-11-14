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
    @State private var searchText = ""
    @Environment(\.designTheme) private var theme
    @ScaledMetric(relativeTo: .body) private var sidebarIdealWidth: CGFloat = 280

    /// Creates the showcase browser.
    public init() {}

    /// The sidebar of component groups and the selected component's detail page.
    public var body: some View {
        let groups = ShowcaseComponent.groups(matching: searchText)

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
            .searchable(text: $searchText)
            .overlay {
                if groups.isEmpty {
                    ContentUnavailableView.search(text: searchText)
                }
            }
            // Grows with Dynamic Type so labels wrap at word boundaries instead of
            // breaking mid-word in a fixed-width column at accessibility sizes.
            .navigationSplitViewColumnWidth(min: 280, ideal: sidebarIdealWidth, max: 560)
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
