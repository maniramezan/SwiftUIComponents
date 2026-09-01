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
/// Respects the `UIDesignRequiresCompatibility` Info.plist key — when set to `true`, the
/// material fallback is always used regardless of OS version.
public struct AdaptiveSurface: ViewModifier {
    private let tint: Color?
    private let interactive: Bool
    private let cornerRadius: CGFloat?
    @Environment(\.designTheme) private var theme

    /// Creates an adaptive surface modifier.
    /// - Parameters:
    ///   - tint: Optional tint color applied to the glass effect.
    ///   - interactive: When `true`, the glass responds to pointer hover and press events.
    ///   - cornerRadius: Corner radius override. Defaults to `theme.radius.oneAndHalfUnits`.
    public init(tint: Color? = nil, interactive: Bool = false, cornerRadius: CGFloat? = nil) {
        self.tint = tint
        self.interactive = interactive
        self.cornerRadius = cornerRadius
    }

    /// Applies the adaptive surface to the wrapped content — glass on iOS/macOS 26+,
    /// `ultraThinMaterial` on older systems.
    @ViewBuilder
    public func body(content: Content) -> some View {
        let radius = cornerRadius ?? theme.radius.oneAndHalfUnits
        let useCompatibility = Bundle.requiresDesignCompatibility
        if #available(iOS 26, macOS 26, *), !useCompatibility {
            content.glassEffect(buildGlass(), in: .rect(cornerRadius: radius))
        } else {
            content.background(
                .ultraThinMaterial,
                in: RoundedRectangle(cornerRadius: radius, style: .continuous)
            )
        }
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
    func designAdaptiveSurface(
        tint: Color? = nil,
        interactive: Bool = false,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        modifier(AdaptiveSurface(tint: tint, interactive: interactive, cornerRadius: cornerRadius))
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
            Text("Interactive")
                .padding(theme.spacing.twoUnits)
                .designAdaptiveSurface(interactive: true)
        }
        .padding(theme.spacing.twoUnits)
        .background(Color.teal.gradient)
    }
}
