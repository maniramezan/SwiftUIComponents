import SwiftUI

/// Semantic color tokens used by reusable components.
public protocol DesignColorTheme: Sendable {
    /// Primary screen background.
    @MainActor var background: Color { get }
    /// Secondary grouped background.
    @MainActor var backgroundSecondary: Color { get }
    /// Standard container/card fill.
    @MainActor var container: Color { get }
    /// Secondary container fill for nested surfaces.
    @MainActor var containerSecondary: Color { get }
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
}
