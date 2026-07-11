import DesignSystem
import SwiftUI

/// A single themed row inside ``SelectionListView``.
///
/// Renders an optional leading glyph, a title with optional subtitle, and a trailing
/// accessory. Selected rows show a checkmark; expandable parent rows show a chevron
/// that rotates to reflect ``disclosure``. The row is always a button that reports
/// taps through `action` — a leaf selects, a parent toggles its disclosure.
struct SelectionRow: View {
    let title: String
    let subtitle: String?
    let leadingGlyph: String?
    let isSelected: Bool
    let isIndented: Bool
    /// Disclosure state for an expandable parent row: `true` when expanded, `false`
    /// when collapsed, `nil` for leaf and child rows that show no chevron.
    let disclosure: Bool?
    let action: (() -> Void)?
    @Environment(\.designTheme) private var theme

    var body: some View {
        let content = SelectionRowContent(
            title: title,
            subtitle: subtitle,
            leadingGlyph: leadingGlyph,
            isSelected: isSelected,
            isIndented: isIndented,
            disclosure: disclosure
        )
        if let action {
            Button(action: action) { content }
                .buttonStyle(.plain)
                .accessibilityAddTraits(isSelected ? [.isButton, .isSelected] : .isButton)
                .accessibilityValue(disclosureAccessibilityValue)
        } else {
            content
        }
    }

    /// Announces the parent's disclosure state to VoiceOver; empty for leaf/child rows.
    private var disclosureAccessibilityValue: Text {
        switch disclosure {
        case true: Text("Expanded", bundle: .module)
        case false: Text("Collapsed", bundle: .module)
        case nil: Text(verbatim: "")
        }
    }
}

/// The leading glyph, title/subtitle, and trailing checkmark/chevron for a
/// ``SelectionRow``.
///
/// A dedicated `View` type — rather than an inline computed property — so
/// SwiftUI can diff and update it independently of the enclosing `Button`.
private struct SelectionRowContent: View {
    let title: String
    let subtitle: String?
    let leadingGlyph: String?
    let isSelected: Bool
    let isIndented: Bool
    let disclosure: Bool?

    @Environment(\.designTheme) private var theme

    var body: some View {
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
            } else if let disclosure {
                Image(systemName: "chevron.forward")
                    .font(theme.typography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(theme.colors.textSecondary)
                    .rotationEffect(.degrees(disclosure ? 90 : 0))
                    .accessibilityHidden(true)
            }
        }
        .padding(.leading, isIndented ? theme.spacing.twoUnits : 0)
        .contentShape(Rectangle())
        .frame(minHeight: theme.motion.minimumHitTarget)
    }
}
