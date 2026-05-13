import DesignSystem
import SwiftUI

public extension View {
    /// Applies a themed card background.
    func designCardSurface(showStroke: Bool = true) -> some View {
        modifier(DesignCardSurface(showStroke: showStroke))
    }

    /// Applies a themed capsule background.
    func designCapsuleSurface(isSelected: Bool = false) -> some View {
        modifier(DesignCapsuleSurface(isSelected: isSelected))
    }

    /// Applies a themed input field background.
    func designInputSurface() -> some View {
        modifier(DesignInputSurface())
    }
}
