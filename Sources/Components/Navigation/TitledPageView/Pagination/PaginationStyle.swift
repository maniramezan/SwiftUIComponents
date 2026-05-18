import DesignSystem
import SwiftUI

/// Per-call styling overrides for ``TitledPageView``. Every optional
/// property falls back to the active `Theme` token when `nil`, so
/// callers only need to override the values they actually want to customize.
public struct PaginationStyle: Sendable {

    /// Font used for page titles in the header strip. `nil` → `theme.typography.title`.
    public var titleFont: Font?

    /// Foreground color for the active (current) page title. `nil` → `theme.colors.textPrimary`.
    public var titleColor: Color?

    /// Foreground color for the peeked previous/next page titles.
    /// `nil` → `theme.colors.textTertiary`.
    public var adjacentTitleColor: Color?

    /// Optional shape style painted behind the whole paged view. `nil` is transparent.
    public var background: AnyShapeStyle?

    /// Tint of the active dot or bar thumb. `nil` → `theme.colors.primary`.
    public var indicatorActiveColor: Color?

    /// Tint of inactive dots or the bar track. `nil` → `theme.colors.disabled`.
    public var indicatorInactiveColor: Color?

    /// How much of the adjacent pages' titles to reveal in the header strip.
    /// Defaults to `.bidirectional` (both previous and next page titles peek).
    public var peekDirection: PaginationPeekDirection

    /// Width (in points) of the visible peek on a single side.
    /// `nil` → `theme.spacing.fiveUnits` (40 pt by default).
    public var peekWidth: CGFloat?

    /// Vertical gap between the header strip and the page content.
    /// `nil` → `theme.spacing.twoUnits` (16 pt by default).
    public var headerSpacing: CGFloat?

    /// Horizontal gap between adjacent titles in the header strip.
    /// `nil` → `theme.spacing.twoUnits` (16 pt by default).
    public var titleGap: CGFloat?

    /// When `true` and the user has enabled Reduce Motion, page transitions
    /// cross-fade and the header peek collapses to zero to suppress parallax.
    public var reduceMotionUsesCrossfade: Bool

    /// Explicit leading inset for the title strip, in points. When set, this
    /// value is used as the header's leading padding instead of the value
    /// computed from `peekWidth` and `titleGap`. Use this to pin the active
    /// title to a specific x-position (e.g. to align it with page content that
    /// has its own horizontal padding) while keeping `peekWidth` free to
    /// control how much of the next page's title is revealed.
    ///
    /// `nil` (default) falls back to the standard `peek + gap` calculation.
    public var titleLeadingPadding: CGFloat?

    /// Creates a style with the given overrides. All parameters default to
    /// either `nil` (resolve from theme) or the design system's recommended
    /// behavior.
    public init(
        titleFont: Font? = nil,
        titleColor: Color? = nil,
        adjacentTitleColor: Color? = nil,
        background: AnyShapeStyle? = nil,
        indicatorActiveColor: Color? = nil,
        indicatorInactiveColor: Color? = nil,
        peekDirection: PaginationPeekDirection = .bidirectional,
        peekWidth: CGFloat? = nil,
        headerSpacing: CGFloat? = nil,
        titleGap: CGFloat? = nil,
        titleLeadingPadding: CGFloat? = nil,
        reduceMotionUsesCrossfade: Bool = true
    ) {
        self.titleFont = titleFont
        self.titleColor = titleColor
        self.adjacentTitleColor = adjacentTitleColor
        self.background = background
        self.indicatorActiveColor = indicatorActiveColor
        self.indicatorInactiveColor = indicatorInactiveColor
        self.peekDirection = peekDirection
        self.peekWidth = peekWidth
        self.headerSpacing = headerSpacing
        self.titleGap = titleGap
        self.titleLeadingPadding = titleLeadingPadding
        self.reduceMotionUsesCrossfade = reduceMotionUsesCrossfade
    }

    /// The default style — every override is `nil` and resolves from theme tokens.
    public static let `default` = PaginationStyle()
}

// MARK: - Environment

private struct PaginationStyleKey: EnvironmentKey {
    static let defaultValue: PaginationStyle = .default
}

public extension EnvironmentValues {
    /// Active styling overrides for ``TitledPageView`` instances in this subtree.
    var designPaginationStyle: PaginationStyle {
        get { self[PaginationStyleKey.self] }
        set { self[PaginationStyleKey.self] = newValue }
    }
}

public extension View {
    /// Overrides the per-call styling for any ``TitledPageView`` in this
    /// view hierarchy. Each non-`nil` property of `style` wins over the theme
    /// defaults; `nil` properties continue to resolve from the active
    /// `Theme`.
    func designPaginationStyle(_ style: PaginationStyle) -> some View {
        environment(\.designPaginationStyle, style)
    }
}
