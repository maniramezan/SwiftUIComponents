import DesignSystem
import SwiftUI

/// A shaded sphere that keeps caller-supplied content upright and interactive.
///
/// Colors and the default diameter follow the active design theme. The sphere adds no accessibility
/// label of its own; supply accessible content or label the enclosing control.
///
/// ```swift
/// SphereView(tint: .blue) {
///     Image(systemName: "plus")
/// }
/// ```
public struct SphereView<Content: View>: View {
    private let diameter: CGFloat?
    private let tint: Color?
    private let content: Content
    @Environment(\.designTheme) private var theme

    /// Creates a sphere with optional sizing and color overrides.
    ///
    /// - Parameters:
    ///   - diameter: Diameter in points. `nil` uses `theme.spacing.sixUnits * 2`.
    ///     Nonfinite or nonpositive values log a fault and use the theme default.
    ///   - tint: Sphere color. `nil` uses `theme.colors.primary`.
    ///   - content: Foreground content. Text and accessibility labels remain caller-owned.
    public init(diameter: CGFloat? = nil, tint: Color? = nil, @ViewBuilder content: () -> Content) {
        self.diameter = diameter
        self.tint = tint
        self.content = content()
    }

    /// The circular surface, shading, and caller-supplied foreground.
    public var body: some View {
        let side = SphereOrbitGeometry.positive(diameter, fallback: theme.spacing.sixUnits * 2)
        let color = tint ?? theme.colors.primary
        content
            .frame(width: side, height: side)
            .background {
                Circle()
                    .fill(theme.colors.container)
                    .overlay { Circle().fill(color.gradient) }
                    .overlay {
                        Circle().fill(
                            RadialGradient(
                                colors: [
                                    theme.colors.onOverlay.opacity(SphereSurfaceMetrics.highlightOpacity), .clear,
                                ],
                                center: .topLeading,
                                startRadius: 0,
                                endRadius: side
                            )
                        )
                    }
                    .overlay {
                        Circle().fill(
                            RadialGradient(
                                colors: [.clear, theme.colors.shadow.opacity(SphereSurfaceMetrics.shadeOpacity)],
                                center: .topLeading,
                                startRadius: side * SphereSurfaceMetrics.shadeStartRatio,
                                endRadius: side
                            )
                        )
                    }
                    .overlay {
                        Circle().strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
                    }
            }
            .clipShape(Circle())
            .contentShape(Circle())
    }
}

private enum SphereSurfaceMetrics {
    static let highlightOpacity = 0.55
    static let shadeOpacity = 0.18
    static let shadeStartRatio = 0.35
}

#Preview("Sphere") {
    PreviewContent { theme in
        SphereView {
            Image(systemName: "plus")
                .font(theme.typography.title)
                .foregroundStyle(theme.colors.onPrimary)
        }
    }
}
