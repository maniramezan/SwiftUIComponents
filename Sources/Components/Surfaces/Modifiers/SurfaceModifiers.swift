import DesignSystem
import SwiftUI

public extension View {
    /// Applies a themed card background.
    func designCardSurface(showStroke: Bool = true) -> some View {
        modifier(CardSurface(showStroke: showStroke))
    }

    /// Applies a themed capsule background.
    func designCapsuleSurface(isSelected: Bool = false) -> some View {
        modifier(CapsuleSurface(isSelected: isSelected))
    }

    /// Applies a themed input field background.
    func designInputSurface() -> some View {
        modifier(InputSurface())
    }
}

#Preview("Design Surface Modifiers") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.oneAndHalfUnits) {
            Text("Card")
                .padding(theme.spacing.twoUnits)
                .designCardSurface()
            Text("Capsule")
                .padding(.horizontal, theme.spacing.twoUnits)
                .padding(.vertical, theme.spacing.oneUnit)
                .designCapsuleSurface()
            Text("Input")
                .padding(theme.spacing.twoUnits)
                .designInputSurface()
        }
        .padding(theme.spacing.twoUnits)
    }
}
