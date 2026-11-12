import Components
import DesignSystem
import SwiftUI

struct ExpandableFloatingActionButtonDetailView: View {
    @State private var title = "Actions"
    @State private var collapsedSymbol = "plus"
    @State private var expandedSymbol = "xmark"
    @State private var direction = FloatingActionButtonDirection.up
    @State private var isExpanded = false
    @State private var showsTitle = false
    @State private var disabled = false
    @State private var disableFirstItem = false
    @State private var collapsesOnSelection = true
    @State private var itemCount = 3
    @State private var longLabels = false
    @State private var rightToLeft = false
    @State private var width: Double = 320
    @State private var height: Double = 280
    @State private var lastSelection = "None"
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                ExpandableFloatingActionButton(
                    items: Array(FloatingActionShowcaseItem.samples.prefix(itemCount)),
                    isExpanded: $isExpanded,
                    direction: direction,
                    showsTitle: showsTitle,
                    collapsesOnSelection: collapsesOnSelection,
                    isItemDisabled: { disableFirstItem && $0.id == 0 },
                    onSelect: { lastSelection = $0.title }
                ) { expanded in
                    Label(title, systemImage: expanded ? expandedSymbol : collapsedSymbol)
                } itemLabel: { item in
                    Label(
                        longLabels ? "\(item.title) with a longer descriptive label" : item.title,
                        systemImage: item.symbol
                    )
                }
                .frame(maxWidth: width)
                .frame(height: height)
                .environment(\.layoutDirection, rightToLeft ? .rightToLeft : .leftToRight)
                .disabled(disabled)
                Text("Last selection: \(lastSelection)")
            }

            ShowcaseSection("Controls") {
                TextField("Trigger title", text: $title)
                TextField("Collapsed system image", text: $collapsedSymbol)
                TextField("Expanded system image", text: $expandedSymbol)
                Picker("Direction", selection: $direction) {
                    Text("Up").tag(FloatingActionButtonDirection.up)
                    Text("Down").tag(FloatingActionButtonDirection.down)
                    Text("Leading").tag(FloatingActionButtonDirection.leading)
                    Text("Trailing").tag(FloatingActionButtonDirection.trailing)
                }
                Toggle("Expanded", isOn: $isExpanded).toggleStyle(ThemeToggleStyle())
                Toggle("Show trigger title", isOn: $showsTitle).toggleStyle(ThemeToggleStyle())
                Toggle("Collapse on selection", isOn: $collapsesOnSelection).toggleStyle(ThemeToggleStyle())
                Toggle("Disabled", isOn: $disabled).toggleStyle(ThemeToggleStyle())
                Toggle("Disable first action", isOn: $disableFirstItem).toggleStyle(ThemeToggleStyle())
                Toggle("Long action labels", isOn: $longLabels).toggleStyle(ThemeToggleStyle())
                Toggle("Right-to-left layout", isOn: $rightToLeft).toggleStyle(ThemeToggleStyle())
                Text("System Reduce Motion: \(reduceMotion ? "On" : "Off")")
                Text("Change Reduce Motion in system Accessibility settings to preview opacity-only transitions.")
                Stepper("Actions: \(itemCount)", value: $itemCount, in: 0...8)
                Text("Presentation width: \(Int(width))")
                Slider(value: $width, in: 180...600)
                Text("Presentation height: \(Int(height))")
                Slider(value: $height, in: 120...480)
            }
        }
    }
}

private struct FloatingActionShowcaseItem: Identifiable {
    let id: Int
    let title: String
    let symbol: String

    static let samples: [Self] = (0..<8).map {
        Self(id: $0, title: "Action \($0 + 1)", symbol: ["star", "square", "circle", "triangle"][$0 % 4])
    }
}

#Preview {
    ScrollView {
        ExpandableFloatingActionButtonDetailView()
    }
    .designTheme(DefaultTheme())
}
