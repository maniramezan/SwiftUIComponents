import DesignSystem
import SwiftUI

/// Toggle style that uses the active design theme for colors and sizing.
///
/// ```swift
/// Toggle("Enable notifications", isOn: $isEnabled)
///     .toggleStyle(ThemeToggleStyle())
/// ```
///
public struct ThemeToggleStyle: ToggleStyle {
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.designTheme) private var theme

    /// Creates a themed toggle style.
    public init() {}

    /// Builds the toggle control from the given configuration.
    ///
    /// - Parameter configuration: The label and binding provided by the `Toggle`.
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
                ThemeToggleCapsule(isOn: configuration.isOn)
            }
        }
        .buttonStyle(.plain)
        .opacity(isEnabled ? 1 : theme.motion.disabledOpacity)
        .accessibilityRepresentation {
            Toggle(isOn: configuration.$isOn) {
                configuration.label
            }
        }
    }
}

/// The pill-shaped track and thumb for a ``ThemeToggleStyle`` toggle.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` method —
/// so SwiftUI can diff and update it independently of the surrounding label.
private struct ThemeToggleCapsule: View {
    let isOn: Bool

    @Environment(\.designTheme) private var theme

    var body: some View {
        // The track mimics the native platform toggle's ~51×31pt footprint.
        // Height matches `fourUnits` on the 4/8pt scale exactly; width has no
        // single matching token, so it's expressed as `sixUnits + halfUnit`
        // (48 + 4 = 52pt) to keep it theme-derived rather than a bare literal.
        RoundedRectangle(cornerRadius: theme.radius.pill, style: .continuous)
            .fill(isOn ? theme.colors.primary : theme.colors.containerSecondary)
            .frame(width: theme.spacing.sixUnits + theme.spacing.halfUnit, height: theme.spacing.fourUnits)
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

    PreviewContent { theme in
        Toggle("Enable notifications", isOn: $isEnabled)
            .toggleStyle(ThemeToggleStyle())
            .padding(theme.spacing.twoUnits)
    }
}
