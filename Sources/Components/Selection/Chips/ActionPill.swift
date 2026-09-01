import DesignSystem
import SwiftUI

/// A capsule-shaped action whose label can contain arbitrary SwiftUI content.
///
/// Unlike ``PillChip``, an action pill does not represent selection. Use it for
/// compact links, tags that open content, and other capsule-shaped commands.
public struct ActionPill<Label: View>: View {
    private let action: () -> Void
    private let label: Label
    @Environment(\.designTheme) private var theme

    /// Creates an action pill with a caller-provided label.
    ///
    /// - Parameters:
    ///   - action: The action performed when the pill is activated.
    ///   - label: Content displayed inside the capsule.
    public init(action: @escaping () -> Void, @ViewBuilder label: () -> Label) {
        self.action = action
        self.label = label()
    }

    /// The themed capsule button.
    public var body: some View {
        Button(action: action) {
            label
                .fixedSize(horizontal: true, vertical: false)
                .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                .padding(.vertical, theme.spacing.oneUnit)
                .frame(minHeight: theme.motion.minimumHitTarget)
                .designCapsuleSurface()
                .overlay {
                    Capsule(style: .continuous)
                        .strokeBorder(theme.colors.border, lineWidth: theme.stroke.thin)
                }
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
    }
}

#Preview("Action Pill") {
    PreviewContent { theme in
        ActionPill(action: {}) {
            HStack(spacing: theme.spacing.halfUnit) {
                Text("past")
                    .bold()
                Text("walked")
            }
            .font(theme.typography.caption)
        }
        .padding(theme.spacing.twoUnits)
    }
}
