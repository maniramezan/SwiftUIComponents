import SwiftUI

/// Stroke widths for borders, dividers, and emphasis outlines.
public protocol Stroke: Sendable {
    /// 0.5 pt hairline stroke.
    var hairline: CGFloat { get }
    /// 1 pt thin stroke.
    var thin: CGFloat { get }
    /// 2 pt regular stroke.
    var regular: CGFloat { get }
    /// 4 pt emphasis stroke.
    var thick: CGFloat { get }
}

/// Default stroke-width tokens for shared components.
public struct DefaultStroke: Stroke {
    public let hairline: CGFloat
    public let thin: CGFloat
    public let regular: CGFloat
    public let thick: CGFloat

    /// Creates stroke-width tokens.
    public init(
        hairline: CGFloat = 0.5,
        thin: CGFloat = 1,
        regular: CGFloat = 2,
        thick: CGFloat = 4
    ) {
        self.hairline = hairline
        self.thin = thin
        self.regular = regular
        self.thick = thick
    }
}
