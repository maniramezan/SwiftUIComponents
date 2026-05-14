import DesignSystem
import SwiftUI

/// Selectable pill chip for filters and tag lists.
///
/// ![Pill chips with selected and unselected states](designPillChips)
public struct DesignPillChip: View {
    private let title: String
    private let isSelected: Bool
    private let action: () -> Void
    @Environment(\.designTheme) private var theme

    /// Creates a selectable pill chip.
    public init(_ title: String, isSelected: Bool, action: @escaping () -> Void) {
        self.title = title
        self.isSelected = isSelected
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Text(title)
                .font(theme.typography.subheadline.weight(isSelected ? .semibold : .regular))
                .padding(.horizontal, theme.spacing.twoUnits)
                .padding(.vertical, theme.spacing.oneUnit)
                .designCapsuleSurface(isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Design Pill Chips") {
    HStack(spacing: 8) {
        DesignPillChip("All", isSelected: true) {}
        DesignPillChip("Recent", isSelected: false) {}
        DesignPillChip("Favorites", isSelected: false) {}
    }
    .padding()
}
