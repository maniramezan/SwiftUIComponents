import DesignSystem
import SwiftUI

/// Toggle style that uses the active design theme for colors and sizing.
///
/// ![Toggle in on and off states](designToggle)
public struct DesignToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.designTheme) private var theme

    /// Creates a themed toggle style.
    public init() {}

    public func makeBody(configuration: Configuration) -> some View {
        Button {
            withAnimation(theme.motion.standardAnimation) {
                configuration.isOn.toggle()
            }
        } label: {
            HStack(spacing: theme.spacing.oneAndHalfUnits) {
                configuration.label
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textPrimary)
                Spacer(minLength: theme.spacing.oneUnit)
                capsule(isOn: configuration.isOn)
            }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : theme.motion.disabledOpacity)
        .accessibilityValue(configuration.isOn ? Text("On") : Text("Off"))
    }

    private func capsule(isOn: Bool) -> some View {
        RoundedRectangle(cornerRadius: theme.radius.pill, style: .continuous)
            .fill(isOn ? theme.colors.primary : theme.colors.containerSecondary)
            .frame(width: 52, height: 32)
            .overlay(alignment: isOn ? .trailing : .leading) {
                Circle()
                    .fill(Color.white)
                    .shadow(color: .black.opacity(0.18), radius: 1, y: 1)
                    .padding(theme.spacing.halfUnit)
            }
    }
}

#Preview("Design Toggle") {
    @Previewable @State var isEnabled = true

    Toggle("Enable notifications", isOn: $isEnabled)
        .toggleStyle(DesignToggleStyle())
        .padding()
}
