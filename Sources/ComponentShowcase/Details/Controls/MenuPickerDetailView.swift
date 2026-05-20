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

    @State private var selected: FruitItem = Self.fruits[0]
    @State private var longSelected: FruitItem = Self.fruits[0]
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Default (inline menu)") {
                MenuPicker(items: Self.fruits, currentValue: $selected)
            }

            ShowcaseSection("Long list (searchable sheet)") {
                MenuPicker(
                    items: Self.fruits + [
                        .init(id: 7, title: "Blueberry"),
                        .init(id: 8, title: "Kiwi"),
                        .init(id: 9, title: "Lemon"),
                        .init(id: 10, title: "Lime"),
                        .init(id: 11, title: "Orange"),
                        .init(id: 12, title: "Peach"),
                    ],
                    currentValue: $longSelected
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
