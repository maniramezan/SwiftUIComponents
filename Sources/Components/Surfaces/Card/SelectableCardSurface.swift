import DesignSystem
import SwiftUI

/// Applies an interactive adaptive surface with a selection-state tint.
///
/// ```swift
/// Text("Option A")
///     .padding()
///     .designSelectableCardSurface(isSelected: selectedOption == .a)
/// ```
///
/// Uses a glass effect on iOS/macOS 26+ with an accent tint when selected, or an
/// ultraThinMaterial with an accent overlay stroke on older systems.
public struct SelectableCardSurface: ViewModifier {
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

    /// Applies the selectable card surface to the wrapped content — glass with accent tint on
    /// iOS/macOS 26+, `ultraThinMaterial` with an accent stroke on older systems.
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
        modifier(SelectableCardSurface(isSelected: isSelected, cornerRadius: cornerRadius))
    }
}

#Preview("Selectable Card Surface") {
    PreviewContent { theme in
        HStack(spacing: theme.spacing.oneAndHalfUnits) {
            Text("Unselected")
                .padding(theme.spacing.twoUnits)
                .designSelectableCardSurface(isSelected: false)
            Text("Selected")
                .padding(theme.spacing.twoUnits)
                .designSelectableCardSurface(isSelected: true)
        }
        .padding(theme.spacing.twoUnits)
        .background(Color.teal.gradient)
    }
}
