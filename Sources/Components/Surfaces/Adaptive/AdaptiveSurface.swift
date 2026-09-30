import DesignSystem
import SwiftUI

/// Applies a glass effect on iOS/macOS 26+ or an ultraThinMaterial fallback on older systems.
///
/// ```swift
/// Text("Floating panel")
///     .padding()
///     .designAdaptiveSurface(tint: .blue.opacity(0.2), interactive: true)
/// ```
///
/// Choose a shared outline for compact controls, with an optional border on material fallbacks:
///
/// ```swift
/// Image(systemName: "chevron.forward")
///     .padding()
///     .designAdaptiveSurface(shape: .circle, interactive: true)
/// Text("Option")
///     .padding()
///     .designAdaptiveSurface(shape: .capsule, fallbackBorderColor: .white)
/// ```
///
/// Reduce Transparency selects regular material and suppresses glass tint and interaction.
///
/// Respects the `UIDesignRequiresCompatibility` Info.plist key — when set to `true`, the
/// material fallback is always used regardless of OS version.
public struct AdaptiveSurface: ViewModifier {
    private let tint: Color?
    private let interactive: Bool
    private let cornerRadius: CGFloat?
    private let shape: AdaptiveSurfaceShape
    private let fallbackBorderColor: Color?
    private let fallbackBorderWidth: CGFloat?
    @Environment(\.accessibilityReduceTransparency) private var reduceTransparency
    @Environment(\.designTheme) private var theme

    /// Creates an adaptive surface modifier.
    /// - Parameters:
    ///   - tint: Optional tint color applied to the glass effect.
    ///   - interactive: When `true`, the glass responds to pointer hover and press events.
    ///   - cornerRadius: Corner radius override. Defaults to `theme.radius.oneAndHalfUnits`.
    ///   - shape: Surface outline. Defaults to a rounded rectangle.
    ///   - fallbackBorderColor: Optional outline drawn only over the material fallback.
    ///   - fallbackBorderWidth: Outline width; `nil` uses `theme.stroke.thin`.
    public init(
        tint: Color? = nil,
        interactive: Bool = false,
        cornerRadius: CGFloat? = nil,
        shape: AdaptiveSurfaceShape = .roundedRectangle,
        fallbackBorderColor: Color? = nil,
        fallbackBorderWidth: CGFloat? = nil
    ) {
        self.tint = tint
        self.interactive = interactive
        self.cornerRadius = cornerRadius
        self.shape = shape
        self.fallbackBorderColor = fallbackBorderColor
        self.fallbackBorderWidth = fallbackBorderWidth
    }

    /// Applies the adaptive surface to the wrapped content — glass on iOS/macOS 26+,
    /// `ultraThinMaterial` on older systems.
    @ViewBuilder
    public func body(content: Content) -> some View {
        let radius = cornerRadius ?? theme.radius.oneAndHalfUnits
        let outline = shape.resolved(cornerRadius: radius)
        if #available(iOS 26, macOS 26, *),
            Self.usesLiquidGlass(
                supportsLiquidGlass: true,
                requiresCompatibility: Bundle.requiresDesignCompatibility,
                reduceTransparency: reduceTransparency
            )
        {
            content.glassEffect(buildGlass(), in: outline)
        } else {
            content
                .background(Self.fallbackMaterialStyle(reduceTransparency: reduceTransparency).material, in: outline)
                .overlay {
                    if let fallbackBorderColor {
                        outline.stroke(fallbackBorderColor, lineWidth: fallbackBorderWidth ?? theme.stroke.thin)
                    }
                }
        }
    }

    nonisolated static func usesLiquidGlass(
        supportsLiquidGlass: Bool, requiresCompatibility: Bool, reduceTransparency: Bool
    ) -> Bool {
        supportsLiquidGlass && !requiresCompatibility && !reduceTransparency
    }

    enum FallbackMaterialStyle {
        case regular
        case ultraThin

        var material: Material {
            switch self {
            case .regular: .regular
            case .ultraThin: .ultraThin
            }
        }
    }

    nonisolated static func fallbackMaterialStyle(reduceTransparency: Bool) -> FallbackMaterialStyle {
        reduceTransparency ? .regular : .ultraThin
    }

    @available(iOS 26, macOS 26, *)
    private func buildGlass() -> Glass {
        var glass = Glass.regular
        if let tint {
            glass = glass.tint(tint)
        }
        if interactive {
            glass = glass.interactive()
        }
        return glass
    }
}

public extension View {
    /// Applies an adaptive surface — glass on iOS/macOS 26+, ultraThinMaterial below.
    /// - Parameters:
    ///   - tint: Optional tint color applied to the glass effect on supported systems.
    ///   - interactive: Whether supported glass surfaces respond to pointer and press interaction.
    ///   - cornerRadius: Optional corner radius override; defaults to the active theme radius.
    ///   - shape: Surface outline. `cornerRadius` applies only to rounded rectangles.
    ///   - fallbackBorderColor: Optional outline drawn only over the material fallback.
    ///   - fallbackBorderWidth: Outline width; `nil` uses `theme.stroke.thin`.
    func designAdaptiveSurface(
        tint: Color? = nil,
        interactive: Bool = false,
        cornerRadius: CGFloat? = nil,
        shape: AdaptiveSurfaceShape = .roundedRectangle,
        fallbackBorderColor: Color? = nil,
        fallbackBorderWidth: CGFloat? = nil
    ) -> some View {
        modifier(
            AdaptiveSurface(
                tint: tint, interactive: interactive, cornerRadius: cornerRadius, shape: shape,
                fallbackBorderColor: fallbackBorderColor, fallbackBorderWidth: fallbackBorderWidth
            )
        )
    }
}

#Preview("Adaptive Surface") {
    PreviewContent { theme in
        VStack(spacing: theme.spacing.twoUnits) {
            Text("Default")
                .padding(theme.spacing.twoUnits)
                .designAdaptiveSurface()
            Text("With Tint")
                .padding(theme.spacing.twoUnits)
                .designAdaptiveSurface(tint: .blue.opacity(0.2))
            Text("Capsule")
                .padding(theme.spacing.twoUnits)
                .designAdaptiveSurface(shape: .capsule, fallbackBorderColor: theme.colors.textPrimary)
            Image(systemName: "chevron.forward")
                .padding(theme.spacing.twoUnits)
                .designAdaptiveSurface(shape: .circle, interactive: true)
            Text("Interactive")
                .padding(theme.spacing.twoUnits)
                .designAdaptiveSurface(interactive: true)
        }
        .padding(theme.spacing.twoUnits)
        .background(Color.teal.gradient)
    }
}
