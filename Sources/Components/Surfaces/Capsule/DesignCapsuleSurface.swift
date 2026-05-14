import DesignSystem
import SwiftUI

/// Applies a themed capsule surface.
public struct DesignCapsuleSurface: ViewModifier {
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
    HStack(spacing: 8) {
        Text("Default")
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .designCapsuleSurface()
        Text("Selected")
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .designCapsuleSurface(isSelected: true)
    }
    .padding()
}
