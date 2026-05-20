import Components
import DesignSystem
import SwiftUI

struct SelectableCardDetailView: View {
    @State private var selectedID: Int? = nil
    private let items = Array(1...4)
    @Environment(\.designTheme) private var theme

    var body: some View {
        ShowcaseSection("Tap a card to select it") {
            VStack(spacing: theme.spacing.oneAndHalfUnits) {
                ForEach(items, id: \.self) { id in
                    HStack {
                        Image(systemName: "star.fill")
                            .foregroundStyle(theme.colors.primary)
                        Text("Option \(id)")
                            .designTextStyle(.body)
                        Spacer()
                        if selectedID == id {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(theme.colors.primary)
                        }
                    }
                    .padding(theme.spacing.twoUnits)
                    .designSelectableCardSurface(isSelected: selectedID == id)
                    .onTapGesture { selectedID = id }
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        SelectableCardDetailView()
            .padding()
    }
}
