import Components
import DesignSystem
import SwiftUI

/// Showcases ``CarouselRow`` across its sizing and snapping options.
struct CarouselRowDetailView: View {

    fileprivate struct Item: Identifiable {
        let id: Int
        let title: String
    }

    private let items: [Item] = (1...10).map { Item(id: $0, title: "Item \($0)") }
    private let tags: [Item] = [
        Item(id: 1, title: "Short"),
        Item(id: 2, title: "A longer tag"),
        Item(id: 3, title: "Mid"),
        Item(id: 4, title: "Another longer one"),
        Item(id: 5, title: "Tiny"),
        Item(id: 6, title: "Medium length"),
    ]

    @State private var sizing = 0
    @State private var count = 8
    @State private var visibleCount = 1
    @State private var peek = 32.0
    @State private var width = 120.0
    @State private var spacing = 16.0
    @State private var rows = 1
    @State private var rowHeight = 80.0
    @State private var snaps = true
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Playground") {
                CarouselRow(
                    Array(items.prefix(count)),
                    sizing: sizing == 0
                        ? .peek(visibleCount: visibleCount, peek: peek)
                        : sizing == 1 ? .fixedWidth(width) : .fitContent,
                    spacing: spacing, snapping: snaps ? .viewAligned : .free,
                    rows: rows, rowHeight: rowHeight
                ) { item in
                    Text(item.title).padding().frame(maxWidth: .infinity).frame(height: rowHeight).designCardSurface()
                }
                ShowcasePicker("Sizing", selection: $sizing) {
                    Text("Peek").tag(0)
                    Text("Fixed width").tag(1)
                    Text("Intrinsic").tag(2)
                }
                Stepper("Items: \(count)", value: $count, in: 0...10)
                Stepper("Visible columns: \(visibleCount)", value: $visibleCount, in: 1...4)
                Stepper("Rows: \(rows)", value: $rows, in: 1...4)
                LabeledContent("Peek") { Slider(value: $peek, in: 0...80) }
                LabeledContent("Item width") { Slider(value: $width, in: 44...240) }
                LabeledContent("Spacing") { Slider(value: $spacing, in: 0...40) }
                LabeledContent("Row height") { Slider(value: $rowHeight, in: 44...160) }
                Toggle("Snap to items", isOn: $snaps)
            }

            ShowcaseSection("Peek — one item, next sliver visible") {
                CarouselRow(items, sizing: .peek(visibleCount: 1)) { item in
                    CarouselRowDetailCard(item: item, height: 160)
                }
            }

            ShowcaseSection("Peek — two items visible") {
                CarouselRow(items, sizing: .peek(visibleCount: 2)) { item in
                    CarouselRowDetailCard(item: item, height: 120)
                }
            }

            ShowcaseSection("Fixed width — free scroll, edge fade") {
                CarouselRow(items, sizing: .fixedWidth(120), snapping: .free) { item in
                    CarouselRowDetailCard(item: item, height: 120)
                }
            }

            ShowcaseSection("Fit content — intrinsic widths") {
                CarouselRow(tags, sizing: .fitContent, snapping: .free) { tag in
                    Text(tag.title)
                        .designTextStyle(.body)
                        .padding(.horizontal, theme.spacing.twoUnits)
                        .padding(.vertical, theme.spacing.oneAndHalfUnits)
                        .designCapsuleSurface()
                }
            }
        }
    }
}

private struct CarouselRowDetailCard: View {
    let item: CarouselRowDetailView.Item
    let height: CGFloat

    @Environment(\.designTheme) private var theme

    var body: some View {
        RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
            .fill(theme.colors.containerSecondary)
            .frame(height: height)
            .overlay {
                Text(item.title)
                    .designTextStyle(.headline)
            }
            .overlay {
                RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                    .strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
            }
    }
}

#Preview {
    ScrollView {
        CarouselRowDetailView()
            .padding()
    }
}
