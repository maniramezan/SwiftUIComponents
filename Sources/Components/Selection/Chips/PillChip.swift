import DesignSystem
import SwiftUI

/// Selectable pill chip for filters and tag lists.
///
/// ```swift
/// HStack {
///     PillChip("All", isSelected: filter == .all) { filter = .all }
///     PillChip("Recent", isSelected: filter == .recent) { filter = .recent }
/// }
/// ```
///
public struct PillChip: View {
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
                .designPillMetrics()
                .designCapsuleSurface(isSelected: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

#Preview("Design Pill Chips") {
    PreviewContent { theme in
        HStack(spacing: theme.spacing.oneUnit) {
            PillChip("All", isSelected: true) {}
            PillChip("Recent", isSelected: false) {}
            PillChip("Favorites", isSelected: false) {}
        }
        .padding(theme.spacing.twoUnits)
    }
}
