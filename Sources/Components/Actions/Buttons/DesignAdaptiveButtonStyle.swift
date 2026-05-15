import SwiftUI

public extension View {
    /// Applies a glass button style on iOS/macOS 26+ or a bordered button style on older systems.
    ///
    /// Respects the `UIDesignRequiresCompatibility` Info.plist key — when set to `true`, the
    /// bordered fallback is always used regardless of OS version.
    ///
    /// - Parameter prominent: When `true`, uses the prominent glass/bordered variant.
    @ViewBuilder
    func designAdaptiveButtonStyle(prominent: Bool = false) -> some View {
        let useCompatibility =
            Bundle.main.object(forInfoDictionaryKey: "UIDesignRequiresCompatibility") as? Bool ?? false
        if #available(iOS 26, macOS 26, *), !useCompatibility {
            if prominent {
                self.buttonStyle(.glassProminent)
            } else {
                self.buttonStyle(.glass)
            }
        } else {
            if prominent {
                self.buttonStyle(.borderedProminent)
            } else {
                self.buttonStyle(.bordered)
            }
        }
    }
}

#Preview("Adaptive Button Style") {
    VStack(spacing: 12) {
        Button("Default") {}
            .designAdaptiveButtonStyle()
        Button("Prominent") {}
            .designAdaptiveButtonStyle(prominent: true)
    }
    .padding()
    .background(Color.teal.gradient)
}
