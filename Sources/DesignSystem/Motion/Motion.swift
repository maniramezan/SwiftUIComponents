import SwiftUI

/// Motion and interaction tokens shared by components.
public protocol Motion: Sendable {
    /// Minimum tap/click target size recommended for controls.
    var minimumHitTarget: CGFloat { get }
    /// Opacity applied to disabled interactive elements.
    var disabledOpacity: Double { get }
    /// Opacity applied to a pressed (but still enabled) interactive element,
    /// e.g. while a button is held down.
    var pressedOpacity: Double { get }
    /// Standard animation used by simple state changes.
    @MainActor var standardAnimation: Animation { get }
    /// Shorter, simpler animation substituted for `standardAnimation` when the
    /// user has enabled the system **Reduce Motion** accessibility setting.
    @MainActor var reducedMotionAnimation: Animation { get }
    /// Spring used to commit a gesture-driven page transition (carousel, pager, segmented page).
    ///
    /// Defaults to ``MotionSpring/paging``. Components that page on a drag should resolve their
    /// transition from this rather than calling `Animation.interactiveSpring` with literal
    /// parameters, so every pager in an app settles with the same feel.
    var pagingSpring: MotionSpring { get }
    /// Spring used to return content to rest after a gesture ends without committing.
    ///
    /// Defaults to ``MotionSpring/snapBack``. Paired with ``pagingSpring``: the same gesture produces one
    /// of the two depending on whether it crossed the commit threshold.
    var snapBackSpring: MotionSpring { get }
}

public extension Motion {
    /// Opacity applied to a pressed (but still enabled) interactive element.
    /// Defaults to `0.82` when a theme does not override it.
    var pressedOpacity: Double { 0.82 }

    /// Shorter, simpler animation substituted for `standardAnimation` under
    /// Reduce Motion. Defaults to a quick 0.15 s ease when a theme does not
    /// override it.
    @MainActor var reducedMotionAnimation: Animation { .easeInOut(duration: 0.15) }

    /// Spring used to commit a gesture-driven page transition.
    /// Defaults to ``MotionSpring/paging`` when a theme does not override it.
    var pagingSpring: MotionSpring { .paging }

    /// Spring used to return content to rest after a gesture ends without committing.
    /// Defaults to ``MotionSpring/snapBack`` when a theme does not override it.
    var snapBackSpring: MotionSpring { .snapBack }

    /// The animation to use for simple state changes given the current Reduce
    /// Motion setting — `reducedMotionAnimation` when `reducingMotion` is
    /// `true`, otherwise `standardAnimation`.
    ///
    /// - Parameter reducingMotion: Whether the user has enabled **Reduce
    ///   Motion** (e.g. read from `@Environment(\.accessibilityReduceMotion)`).
    @MainActor func animation(reducingMotion: Bool) -> Animation {
        reducingMotion ? reducedMotionAnimation : standardAnimation
    }
}

/// Default motion and interaction tokens.
public struct DefaultMotion: Motion {
    /// Minimum tap/click target size recommended for controls.
    public let minimumHitTarget: CGFloat
    /// Opacity applied to disabled interactive elements.
    public let disabledOpacity: Double
    /// Opacity applied to a pressed (but still enabled) interactive element.
    public let pressedOpacity: Double
    private let standardDuration: TimeInterval
    private let reducedMotionDuration: TimeInterval
    /// Spring used to commit a gesture-driven page transition.
    public let pagingSpring: MotionSpring
    /// Spring used to return content to rest after a gesture ends without committing.
    public let snapBackSpring: MotionSpring

    /// Standard animation used by simple state changes.
    @MainActor public var standardAnimation: Animation {
        .easeInOut(duration: standardDuration)
    }

    /// Shorter, simpler animation substituted for `standardAnimation` under
    /// Reduce Motion.
    @MainActor public var reducedMotionAnimation: Animation {
        .easeInOut(duration: reducedMotionDuration)
    }

    /// Creates motion and interaction tokens.
    public init(
        minimumHitTarget: CGFloat = 44,
        disabledOpacity: Double = 0.45,
        pressedOpacity: Double = 0.82,
        standardDuration: TimeInterval = 0.2,
        reducedMotionDuration: TimeInterval = 0.15,
        pagingSpring: MotionSpring = .paging,
        snapBackSpring: MotionSpring = .snapBack
    ) {
        self.minimumHitTarget = minimumHitTarget
        self.disabledOpacity = disabledOpacity
        self.pressedOpacity = pressedOpacity
        self.standardDuration = standardDuration
        self.reducedMotionDuration = reducedMotionDuration
        self.pagingSpring = pagingSpring
        self.snapBackSpring = snapBackSpring
    }
}
