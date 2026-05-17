import DesignSystem
import SwiftUI

/// Per-call styling overrides for ``DesignTitledPageView``. Every optional
/// property falls back to the active `DesignTheme` token when `nil`, so
/// callers only need to override the values they actually want to customize.
public struct DesignPaginationStyle: Sendable {

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
    public var peekDirection: DesignPaginationPeekDirection

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
        peekDirection: DesignPaginationPeekDirection = .bidirectional,
        peekWidth: CGFloat? = nil,
        headerSpacing: CGFloat? = nil,
        titleGap: CGFloat? = nil,
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
        self.reduceMotionUsesCrossfade = reduceMotionUsesCrossfade
    }

    /// The default style — every override is `nil` and resolves from theme tokens.
    public static let `default` = DesignPaginationStyle()
}

// MARK: - Environment

private struct DesignPaginationStyleKey: EnvironmentKey {
    static let defaultValue: DesignPaginationStyle = .default
}

public extension EnvironmentValues {
    /// Active styling overrides for ``DesignTitledPageView`` instances in this subtree.
    var designPaginationStyle: DesignPaginationStyle {
        get { self[DesignPaginationStyleKey.self] }
        set { self[DesignPaginationStyleKey.self] = newValue }
    }
}

public extension View {
    /// Overrides the per-call styling for any ``DesignTitledPageView`` in this
    /// view hierarchy. Each non-`nil` property of `style` wins over the theme
    /// defaults; `nil` properties continue to resolve from the active
    /// `DesignTheme`.
    func designPaginationStyle(_ style: DesignPaginationStyle) -> some View {
        environment(\.designPaginationStyle, style)
    }
}
