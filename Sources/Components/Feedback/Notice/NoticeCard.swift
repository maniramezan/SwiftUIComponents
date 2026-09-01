import DesignSystem
import SwiftUI

/// Applies the full-width, padded, rounded container used by inline notice,
/// banner, and error cards.
///
/// ```swift
/// Text(message)
///     .designNoticeCard(background: theme.colors.error)
/// ```
///
/// Resolves spacing/radius from the active theme when the overrides are `nil`.
public struct NoticeCard: ViewModifier {
    private let background: Color
    private let cornerRadius: CGFloat?
    private let padding: CGFloat?
    @Environment(\.designTheme) private var theme

    /// Creates a notice-card modifier.
    /// - Parameters:
    ///   - background: The fill color of the card.
    ///   - cornerRadius: Corner radius override. Defaults to
    ///     `theme.radius.oneAndHalfUnits`.
    ///   - padding: Padding override. Defaults to `theme.spacing.twoUnits`.
    public init(
        background: Color,
        cornerRadius: CGFloat? = nil,
        padding: CGFloat? = nil
    ) {
        self.background = background
        self.cornerRadius = cornerRadius
        self.padding = padding
    }

    /// Applies the notice-card container to the wrapped content.
    public func body(content: Content) -> some View {
        let radius = cornerRadius ?? theme.radius.oneAndHalfUnits
        content
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(padding ?? theme.spacing.twoUnits)
            .background(background)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
    }
}

public extension View {
    /// Applies a full-width, padded, rounded notice-card container using the
    /// given fill color.
    ///
    /// - Parameters:
    ///   - background: The fill color of the card.
    ///   - cornerRadius: Corner radius override. Defaults to the theme's
    ///     `radius.oneAndHalfUnits`.
    ///   - padding: Padding override. Defaults to the theme's
    ///     `spacing.twoUnits`.
    func designNoticeCard(
        background: Color,
        cornerRadius: CGFloat? = nil,
        padding: CGFloat? = nil
    ) -> some View {
        modifier(NoticeCard(background: background, cornerRadius: cornerRadius, padding: padding))
    }
}
