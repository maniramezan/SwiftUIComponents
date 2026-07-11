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

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
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
