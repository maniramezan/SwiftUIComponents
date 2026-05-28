import Components
import DesignSystem
import SwiftUI

/// The root navigation split view listing all showcase components in the sidebar.
struct ShowcaseRootView: View {

    @State private var selection: ShowcaseComponent?
    @Environment(\.designTheme) private var theme

    /// Components grouped for sidebar sections.
    private var groups: [(title: String, items: [ShowcaseComponent])] {
        let allGroups = Dictionary(grouping: ShowcaseComponent.allCases, by: \.group)
        let order = ["Actions", "Controls", "Display", "Surfaces", "Feedback", "Pagination", "Chat"]
        return order.compactMap { key in
            guard let items = allGroups[key] else { return nil }
            return (title: key, items: items)
        }
    }

    var body: some View {
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
