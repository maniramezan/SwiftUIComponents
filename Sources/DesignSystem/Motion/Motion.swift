import SwiftUI

/// Motion and interaction tokens shared by components.
public protocol Motion: Sendable {
    /// Minimum tap/click target size recommended for controls.
    var minimumHitTarget: CGFloat { get }
    /// Opacity applied to disabled interactive elements.
    var disabledOpacity: Double { get }
    /// Standard animation used by simple state changes.
    @MainActor var standardAnimation: Animation { get }
}

/// Default motion and interaction tokens.
public struct DefaultMotion: Motion {
    public let minimumHitTarget: CGFloat
    public let disabledOpacity: Double
    private let standardDuration: TimeInterval

    /// Standard animation used by simple state changes.
    @MainActor public var standardAnimation: Animation {
        .easeInOut(duration: standardDuration)
    }

    /// Creates motion and interaction tokens.
    public init(
        minimumHitTarget: CGFloat = 44,
        disabledOpacity: Double = 0.45,
        standardDuration: TimeInterval = 0.2
    ) {
        self.minimumHitTarget = minimumHitTarget
        self.disabledOpacity = disabledOpacity
        self.standardDuration = standardDuration
    }
}
