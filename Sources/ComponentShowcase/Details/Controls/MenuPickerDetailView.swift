import Components
import DesignSystem
import SwiftUI

private struct FruitItem: MenuPickerItem {
    let id: Int
    let title: String
}

struct MenuPickerDetailView: View {
    private static let fruits: [FruitItem] = [
        .init(id: 0, title: "Apple"),
        .init(id: 1, title: "Banana"),
        .init(id: 2, title: "Cherry"),
        .init(id: 3, title: "Mango"),
        .init(id: 4, title: "Pineapple"),
        .init(id: 5, title: "Strawberry"),
        .init(id: 6, title: "Watermelon"),
    ]
    private static let longFruits = (0...30).map { index in
        FruitItem(id: index, title: "Fruit \(index + 1)")
    }

    @State private var selected: FruitItem = Self.fruits[0]
    @State private var longSelected: FruitItem = Self.fruits[0]
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Default (inline menu)") {
                MenuPicker(items: Self.fruits, currentValue: $selected)
            }

            ShowcaseSection("Long list (wheel sheet on iOS)") {
                MenuPicker(
                    items: Self.longFruits,
                    currentValue: $longSelected
                )
            }

            ShowcaseSection("Forced menu") {
                MenuPicker(
                    items: Self.longFruits,
                    currentValue: $longSelected,
                    preferredStyle: .menu
                )
            }

            ShowcaseSection("Disabled") {
                MenuPicker(items: Self.fruits, currentValue: .constant(Self.fruits[0]))
                    .disabled(true)
            }
        }
    }
}

#Preview {
    ScrollView {
        MenuPickerDetailView()
            .padding()
    }
}
