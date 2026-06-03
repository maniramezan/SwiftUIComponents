import DesignSystem
import SwiftUI

/// A single themed row inside ``SelectionSheet``.
///
/// Renders an optional leading glyph, a title with optional subtitle, and a trailing
/// checkmark when selected. When `action` is `nil` the row is a static label (used as
/// an expandable parent's label, whose tap is handled by its `DisclosureGroup`);
/// otherwise it is a button that reports taps.
struct SelectionRow: View {
    let title: String
    let subtitle: String?
    let leadingGlyph: String?
    let isSelected: Bool
    let isIndented: Bool
    let action: (() -> Void)?
    @Environment(\.designTheme) private var theme

    var body: some View {
        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
        } else {
            content
        }
    }

    private var content: some View {
        HStack(spacing: theme.spacing.oneAndHalfUnits) {
            if let leadingGlyph {
                Text(leadingGlyph)
                    .font(theme.typography.title2)
                    .accessibilityHidden(true)
            }
            VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
                Text(title)
                    .font(theme.typography.body)
                    .fontWeight(isSelected ? .semibold : .regular)
                    .foregroundStyle(isSelected ? theme.colors.primary : theme.colors.textPrimary)
                if let subtitle {
                    Text(subtitle)
                        .font(theme.typography.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                }
            }
            Spacer(minLength: theme.spacing.oneUnit)
            if isSelected {
                Image(systemName: "checkmark")
                    .font(theme.typography.headline)
                    .foregroundStyle(theme.colors.primary)
                    .accessibilityHidden(true)
            }
        }
        .padding(.leading, isIndented ? theme.spacing.twoUnits : 0)
        .contentShape(Rectangle())
        .frame(minHeight: theme.motion.minimumHitTarget)
    }
}
