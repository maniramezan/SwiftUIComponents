import DesignSystem
import SwiftUI

/// Applies a themed capsule surface.
public struct CapsuleSurface: ViewModifier {
    private let isSelected: Bool
    @Environment(\.designTheme) private var theme

    /// Creates a capsule surface modifier.
    public init(isSelected: Bool = false) {
        self.isSelected = isSelected
    }

    public func body(content: Content) -> some View {
        content
            .background(
                isSelected ? theme.colors.primary : theme.colors.containerSecondary, in: Capsule(style: .continuous)
            )
            .foregroundStyle(isSelected ? theme.colors.onPrimary : theme.colors.textPrimary)
    }
}

#Preview("Design Capsule Surface") {
    PreviewContent { theme in
        HStack(spacing: theme.spacing.oneUnit) {
            Text("Default")
                .padding(.horizontal, theme.spacing.twoUnits)
                .padding(.vertical, theme.spacing.oneUnit)
                .designCapsuleSurface()
            Text("Selected")
                .padding(.horizontal, theme.spacing.twoUnits)
                .padding(.vertical, theme.spacing.oneUnit)
                .designCapsuleSurface(isSelected: true)
        }
        .padding(theme.spacing.twoUnits)
    }
}
