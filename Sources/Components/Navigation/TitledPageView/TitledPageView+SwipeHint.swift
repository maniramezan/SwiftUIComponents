import SwiftUI

// MARK: - Configuration

/// Configuration for ``TitledPageView``'s swipe-hint animation.
///
/// Pass a value to the `designSwipeHint(_:)` view modifier to customise or disable
/// the automatic peek animation. Every property has a sensible default so
/// callers only need to override what they want to change:
///
/// ```swift
/// // Disable entirely
/// .designSwipeHint(.disabled)
///
/// // Fire later (e.g. after a welcome animation settles)
/// .designSwipeHint(.init(delay: 1.5))
///
/// // Peek further to reveal more of the next page
/// .designSwipeHint(.init(distance: 64))
/// ```
public struct TitledPageSwipeHintConfig: Sendable, Equatable {

    /// Whether the hint animation plays at all. Default: `true`.
    public var isEnabled: Bool

    /// Seconds to wait after first appearance before the animation begins.
    /// Default: `0.6`.
    public var delay: TimeInterval

    /// Points to shift the content during the peek. `nil` resolves to
    /// `theme.spacing.fiveUnits` (40 pt). Default: `nil`.
    public var distance: CGFloat?

    /// Creates a configuration with the given values. All parameters default
    /// to the recommended behavior.
    public init(
        isEnabled: Bool = true,
        delay: TimeInterval = 0.6,
        distance: CGFloat? = nil
    ) {
        self.isEnabled = isEnabled
        self.delay = delay
        self.distance = distance
    }

    /// The default configuration — enabled, 0.6 s delay, theme-derived distance.
    public static let `default` = TitledPageSwipeHintConfig()

    /// A configuration with the hint animation disabled.
    public static let disabled = TitledPageSwipeHintConfig(isEnabled: false)
}

// MARK: - Environment

private struct DesignSwipeHintConfigKey: EnvironmentKey {
    static let defaultValue = TitledPageSwipeHintConfig.default
}

extension EnvironmentValues {
    /// Active ``TitledPageSwipeHintConfig`` for ``TitledPageView`` instances in this subtree.
    var designSwipeHintConfig: TitledPageSwipeHintConfig {
        get { self[DesignSwipeHintConfigKey.self] }
        set { self[DesignSwipeHintConfigKey.self] = newValue }
    }
}

// MARK: - Modifier

public extension View {
    /// Configures the automatic swipe-hint animation on ``TitledPageView``.
    ///
    /// When enabled (the default), ``TitledPageView`` plays a brief peek animation
    /// shortly after first appearing to hint that the content is horizontally swipeable.
    /// The animation is automatically suppressed when the user enables **Reduce Motion**
    /// in Accessibility settings.
    ///
    /// ```swift
    /// TitledPageView(pages, selection: $selection, title: \.title) { page in
    ///     PageBody(page: page)
    /// }
    /// .designSwipeHint(.disabled)           // opt out entirely
    /// .designSwipeHint(.init(delay: 1.0))   // fire after 1 second instead of 0.6
    /// ```
    ///
    /// - Parameter config: The hint configuration to apply.
    func designSwipeHint(_ config: TitledPageSwipeHintConfig) -> some View {
        environment(\.designSwipeHintConfig, config)
    }

    /// Enables or disables the automatic swipe-hint animation on ``TitledPageView``.
    ///
    /// Convenience shorthand for `designSwipeHint(_:)` when you only
    /// need to toggle the hint on or off without customising timing or distance.
    ///
    /// - Parameter enabled: Pass `false` to suppress the hint animation.
    func designSwipeHint(enabled: Bool) -> some View {
        designSwipeHint(.init(isEnabled: enabled))
    }
}
