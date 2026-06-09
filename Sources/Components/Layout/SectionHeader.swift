import DesignSystem
import SwiftUI

/// A section title with an optional trailing action button.
///
/// `SectionHeader` is a thin, theme-aware row designed to sit above grouped
/// content (lists, cards, grids) — typography and tint come from the current
/// design theme, with the title using `theme.typography.headline` and the
/// action label using `theme.typography.subheadline`.
///
/// ```swift
/// SectionHeader(title: "Vocabulary", actionLabel: "See All") {
///     openVocabularyList()
/// }
/// ```
///
/// When `actionLabel` is `nil` or `onAction` is `nil`, the trailing button is
/// omitted entirely; the title takes the full row width.
public struct SectionHeader: View {

    private let title: String
    private let actionLabel: String?
    private let onAction: (() -> Void)?
    @Environment(\.designTheme) private var theme

    /// Creates a section header.
    ///
    /// - Parameters:
    ///   - title: The section title rendered on the leading edge.
    ///   - actionLabel: Optional trailing button text. Required for the
    ///     action button to appear.
    ///   - onAction: Optional closure invoked when the trailing button is
    ///     tapped. Required for the action button to appear.
    public init(
        title: String,
        actionLabel: String? = nil,
        onAction: (() -> Void)? = nil
    ) {
        self.title = title
        self.actionLabel = actionLabel
        self.onAction = onAction
    }

    public var body: some View {
        HStack(spacing: theme.spacing.oneUnit) {
            Text(title)
                .font(theme.typography.headline)
                .foregroundStyle(theme.colors.textPrimary)
                .accessibilityAddTraits(.isHeader)
            Spacer(minLength: 0)
            if let actionLabel, let onAction {
                Button(actionLabel, action: onAction)
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.primary)
                    .frame(minHeight: theme.motion.minimumHitTarget)
            }
        }
        .padding(.horizontal, theme.spacing.twoUnits)
    }
}

#Preview("Section Header — with action") {
    PreviewContent { theme in
        SectionHeader(title: "Vocabulary", actionLabel: "See All") {}
            .padding(.vertical, theme.spacing.twoUnits)
    }
}

#Preview("Section Header — title only") {
    PreviewContent { theme in
        SectionHeader(title: "Recent Videos")
            .padding(.vertical, theme.spacing.twoUnits)
    }
}
