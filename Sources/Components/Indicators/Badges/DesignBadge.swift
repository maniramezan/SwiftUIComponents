import DesignSystem
import SwiftUI

/// Compact text badge styled from the active design theme.
///
/// ![Standard and prominent badges](designBadges)
public struct DesignBadge: View {
    private let text: String
    private let isProminent: Bool
    @Environment(\.designTheme) private var theme

    /// Creates a themed badge.
    public init(_ text: String, isProminent: Bool = false) {
        self.text = text
        self.isProminent = isProminent
    }

    public var body: some View {
        Text(text)
            .font(theme.typography.badge)
            .foregroundStyle(isProminent ? theme.colors.onPrimary : theme.colors.textSecondary)
            .padding(.horizontal, theme.spacing.oneUnit)
            .padding(.vertical, theme.spacing.halfUnit)
            .background(
                isProminent ? theme.colors.primary : theme.colors.containerSecondary, in: Capsule(style: .continuous)
            )
            .accessibilityElement(children: .combine)
    }
}

#Preview("Design Badges") {
    HStack(spacing: 8) {
        DesignBadge("Beta")
        DesignBadge("New", isProminent: true)
    }
    .padding()
}
