import SwiftUI

/// Semantic color tokens used by reusable components.
public protocol ColorTheme: Sendable {
    /// Primary screen background.
    @MainActor var background: Color { get }
    /// Secondary grouped background.
    @MainActor var backgroundSecondary: Color { get }
    /// Standard container/card fill.
    @MainActor var container: Color { get }
    /// Secondary container fill for nested surfaces.
    @MainActor var containerSecondary: Color { get }
    /// Unselected segmented-control trough fill, matching the platform native segmented control.
    @MainActor var segmentUnselectedBackground: Color { get }
    /// Primary brand/accent color for prominent actions.
    @MainActor var primary: Color { get }
    /// Foreground color placed on top of `primary`.
    @MainActor var onPrimary: Color { get }
    /// Primary readable text color.
    @MainActor var textPrimary: Color { get }
    /// Secondary readable text color.
    @MainActor var textSecondary: Color { get }
    /// Tertiary readable text color.
    @MainActor var textTertiary: Color { get }
    /// Standard border color.
    @MainActor var border: Color { get }
    /// Standard separator color.
    @MainActor var separator: Color { get }
    /// Destructive/error color.
    @MainActor var error: Color { get }
    /// Foreground color placed on top of `error`.
    @MainActor var onError: Color { get }
    /// Success color.
    @MainActor var success: Color { get }
    /// Warning color.
    @MainActor var warning: Color { get }
    /// Disabled fill or foreground color.
    @MainActor var disabled: Color { get }
    /// Tint used for drop shadows (typically combined with a low opacity at
    /// the call site, e.g. `theme.colors.shadow.opacity(0.15)`).
    @MainActor var shadow: Color { get }

    // MARK: Interactive tint

    /// Faint wash of `primary`, for a chip fill, a selected row, or any surface that
    /// should read as interactive without competing with a filled control.
    @MainActor var interactiveSubtle: Color { get }

    // MARK: Overlay scrims

    /// Lightest scrim, for a subtle button wash or a card shadow.
    @MainActor var overlaySubtle: Color { get }
    /// Mid scrim, for a control that sits directly on imagery, such as a play button.
    @MainActor var overlayMedium: Color { get }
    /// Heaviest scrim, for a modal backdrop or text laid over full-bleed media.
    @MainActor var overlayHeavy: Color { get }
    /// Fixed foreground for content placed on any scrim, independent of appearance.
    ///
    /// A scrim keeps the same tone in light and dark, so content on it must not follow the
    /// appearance the way `textPrimary` does — it would invert into the background.
    @MainActor var onOverlay: Color { get }
    /// Leading stop of a top-edge gradient scrim, where the fade is strongest.
    @MainActor var overlayShadowStart: Color { get }
    /// Trailing stop of an edge gradient scrim, where it fades out.
    @MainActor var overlayShadowEnd: Color { get }
    /// Tint for a bottom safe-area strip beneath scrollable content.
    @MainActor var overlayBottomTint: Color { get }

    // MARK: Skeletons

    /// Highlight band swept across skeleton placeholders to read as in-progress.
    @MainActor var shimmerHighlight: Color { get }
}

public extension ColorTheme {
    /// Unselected segmented-control trough fill used when a custom theme does not override it.
    @MainActor var segmentUnselectedBackground: Color { containerSecondary }

    /// Shadow tint used when a custom theme does not override it.
    @MainActor var shadow: Color { .black }

    /// Faint wash of `primary` used when a custom theme does not override it.
    @MainActor var interactiveSubtle: Color { primary.opacity(0.15) }

    /// Subtle scrim used when a custom theme does not override it.
    @MainActor var overlaySubtle: Color { shadow.opacity(0.10) }
    /// Mid scrim used when a custom theme does not override it.
    @MainActor var overlayMedium: Color { shadow.opacity(0.50) }
    /// Heavy scrim used when a custom theme does not override it.
    @MainActor var overlayHeavy: Color { shadow.opacity(0.75) }
    /// Fixed on-scrim foreground used when a custom theme does not override it.
    @MainActor var onOverlay: Color { .white }
    /// Top-edge gradient start used when a custom theme does not override it.
    @MainActor var overlayShadowStart: Color { shadow.opacity(0.14) }
    /// Edge gradient end used when a custom theme does not override it.
    @MainActor var overlayShadowEnd: Color { shadow.opacity(0.05) }
    /// Bottom safe-area tint used when a custom theme does not override it.
    @MainActor var overlayBottomTint: Color { shadow.opacity(0.22) }

    /// Skeleton highlight used when a custom theme does not override it.
    ///
    /// Derived from `shadow` so the sweep stays visible on a light surface; a theme whose
    /// skeletons sit on a dark surface should override this with a light tint.
    @MainActor var shimmerHighlight: Color { shadow.opacity(0.07) }
}
