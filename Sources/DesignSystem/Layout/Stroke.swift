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
    /// 0.5 pt stroke for hairline separators on high-density displays.
    public let hairline: CGFloat
    /// 1 pt stroke for standard outlines and dividers.
    public let thin: CGFloat
    /// 2 pt stroke for selected states or emphasized outlines.
    public let regular: CGFloat
    /// 4 pt stroke for strong focus or progress indicators.
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
