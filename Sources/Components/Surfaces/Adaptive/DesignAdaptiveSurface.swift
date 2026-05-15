import DesignSystem
import SwiftUI

/// Applies a glass effect on iOS/macOS 26+ or an ultraThinMaterial fallback on older systems.
///
/// Respects the `UIDesignRequiresCompatibility` Info.plist key — when set to `true`, the
/// material fallback is always used regardless of OS version.
public struct DesignAdaptiveSurface: ViewModifier {
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

    @ViewBuilder
    public func body(content: Content) -> some View {
        let radius = cornerRadius ?? theme.radius.oneAndHalfUnits
        let useCompatibility =
            Bundle.main.object(forInfoDictionaryKey: "UIDesignRequiresCompatibility") as? Bool ?? false
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
    func designAdaptiveSurface(
        tint: Color? = nil,
        interactive: Bool = false,
        cornerRadius: CGFloat? = nil
    ) -> some View {
        modifier(DesignAdaptiveSurface(tint: tint, interactive: interactive, cornerRadius: cornerRadius))
    }
}

#Preview("Adaptive Surface") {
    VStack(spacing: 16) {
        Text("Default")
            .padding()
            .designAdaptiveSurface()
        Text("With Tint")
            .padding()
            .designAdaptiveSurface(tint: .blue.opacity(0.2))
        Text("Interactive")
            .padding()
            .designAdaptiveSurface(interactive: true)
    }
    .padding()
    .background(Color.teal.gradient)
}
