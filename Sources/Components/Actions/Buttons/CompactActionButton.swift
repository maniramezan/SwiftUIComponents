import DesignSystem
import SwiftUI

/// A compact pill-shaped action button — short label, leading SF Symbol,
/// prominent fill — sized for chip rows and contextual action strips.
///
/// Tuned for "quick action" affordances (Translate, Simplify, Explain, etc.)
/// that sit alongside content rather than standing alone as a primary CTA.
/// Uses the theme's prominent button styling tinted with
/// `theme.colors.primary` and `theme.colors.onPrimary` for the label.
///
/// ```swift
/// HStack {
///     CompactActionButton(title: "Grammar", icon: "book") { explainGrammar() }
///     CompactActionButton(title: "Translate", icon: "globe") { translate() }
/// }
/// ```
///
/// When `isDisabled` is `true`, the button stops responding to taps and
/// fades its label to `theme.motion.disabledOpacity`. The transition is
/// animated with `theme.motion.standardAnimation` so toggling disabled state
/// reads as a smooth state change rather than a pop.
public struct CompactActionButton: View {

    private let title: String
    private let icon: String
    private let explicitDisabled: Bool?
    private let action: () -> Void
    @Environment(\.designTheme) private var theme
    @Environment(\.isEnabled) private var isEnvironmentEnabled

    private var isEffectivelyDisabled: Bool {
        if let explicitDisabled { return explicitDisabled }
        return !isEnvironmentEnabled
    }

    /// Creates a compact action button.
    ///
    /// - Parameters:
    ///   - title: Button label text.
    ///   - icon: SF Symbol name shown leading the label.
    ///   - isDisabled: When `true`, suppresses hit-testing and dims the
    ///     label. When `nil` (the default), the button respects SwiftUI's
    ///     `.disabled()` environment modifier instead.
    ///   - action: Closure invoked on tap when not disabled.
    public init(
        title: String,
        icon: String,
        isDisabled: Bool? = nil,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.explicitDisabled = isDisabled
        self.action = action
    }

    public var body: some View {
        Button(action: action) {
            Label(title, systemImage: icon)
                .font(theme.typography.subheadline.weight(.medium))
                .foregroundStyle(
                    theme.colors.onPrimary.opacity(
                        isEffectivelyDisabled ? theme.motion.disabledOpacity : 1
                    )
                )
                .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                .padding(.vertical, theme.spacing.oneUnit)
        }
        .buttonStyle(.borderedProminent)
        .buttonBorderShape(.capsule)
        .tint(theme.colors.primary)
        .allowsHitTesting(!isEffectivelyDisabled)
        .animation(theme.motion.standardAnimation, value: isEffectivelyDisabled)
    }
}

#Preview("Compact action buttons") {
    PreviewContent { theme in
        HStack(spacing: theme.spacing.oneUnit) {
            CompactActionButton(title: "Grammar", icon: "book") {}
            CompactActionButton(title: "Simpler", icon: "lightbulb") {}
            CompactActionButton(title: "Translate", icon: "globe", isDisabled: true) {}
        }
        .padding(theme.spacing.twoUnits)
    }
}
