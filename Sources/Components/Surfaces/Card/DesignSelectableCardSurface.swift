import DesignSystem
import SwiftUI

/// Applies an interactive adaptive surface with a selection-state tint.
///
/// Uses a glass effect on iOS/macOS 26+ with an accent tint when selected, or an
/// ultraThinMaterial with an accent overlay stroke on older systems.
public struct DesignSelectableCardSurface: ViewModifier {
    private let isSelected: Bool
    private let cornerRadius: CGFloat?
    @Environment(\.designTheme) private var theme

    /// Creates a selectable card surface modifier.
    /// - Parameters:
    ///   - isSelected: Whether this card is in the selected state.
    ///   - cornerRadius: Corner radius override. Defaults to `theme.radius.oneAndHalfUnits`.
    public init(isSelected: Bool, cornerRadius: CGFloat? = nil) {
        self.isSelected = isSelected
        self.cornerRadius = cornerRadius
    }

    @ViewBuilder
    public func body(content: Content) -> some View {
        let radius = cornerRadius ?? theme.radius.oneAndHalfUnits
        let useCompatibility =
            Bundle.main.object(forInfoDictionaryKey: "UIDesignRequiresCompatibility") as? Bool ?? false
        if #available(iOS 26, macOS 26, *), !useCompatibility {
            content.glassEffect(
                Glass.regular
                    .tint(isSelected ? theme.colors.primary.opacity(0.18) : Color.secondary.opacity(0.08))
                    .interactive(),
                in: .rect(cornerRadius: radius)
            )
        } else {
            content
                .background(
                    .ultraThinMaterial,
                    in: RoundedRectangle(cornerRadius: radius, style: .continuous)
                )
                .overlay {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(
                            isSelected ? theme.colors.primary.opacity(0.5) : Color.clear,
                            lineWidth: theme.stroke.regular
                        )
                }
        }
    }
}

public extension View {
    /// Applies an interactive adaptive card surface with selection state.
    func designSelectableCardSurface(isSelected: Bool, cornerRadius: CGFloat? = nil) -> some View {
        modifier(DesignSelectableCardSurface(isSelected: isSelected, cornerRadius: cornerRadius))
    }
}

#Preview("Selectable Card Surface") {
    HStack(spacing: 12) {
        Text("Unselected")
            .padding()
            .designSelectableCardSurface(isSelected: false)
        Text("Selected")
            .padding()
            .designSelectableCardSurface(isSelected: true)
    }
    .padding()
    .background(Color.teal.gradient)
}
