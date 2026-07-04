import CoreGraphics

/// Describes how each item in a ``CarouselRow`` is sized along the horizontal
/// scroll axis.
///
/// Construct a value with one of the static factories:
///
/// ```swift
/// .peek(visibleCount: 1)        // one full item + a sliver of the next
/// .peek(visibleCount: 2, peek: 24)
/// .fixedWidth(120)              // every item exactly 120 pt wide
/// .fitContent                  // each item sizes to its own content
/// ```
public struct CarouselItemSizing: Equatable, Sendable {

    /// The underlying sizing strategy. Internal so the layout math and body can
    /// switch on it while the public surface stays factory-based.
    enum Kind: Equatable, Sendable {
        case peek(visibleCount: Int, peek: CGFloat)
        case fixedWidth(CGFloat)
        case fitContent
    }

    /// The resolved sizing strategy backing this value.
    let kind: Kind

    private init(kind: Kind) {
        self.kind = kind
    }

    /// Shows `visibleCount` items across the viewport while revealing a sliver
    /// of the next item so users can tell more content exists off-screen.
    ///
    /// - Parameters:
    ///   - visibleCount: The number of items fully visible at once. Values
    ///     below `1` are clamped to `1`. Defaults to `1`.
    ///   - peek: The width, in points, of the revealed sliver of the next
    ///     item. Defaults to `32`.
    /// - Returns: A peeking sizing value.
    public static func peek(visibleCount: Int = 1, peek: CGFloat = 32) -> CarouselItemSizing {
        CarouselItemSizing(kind: .peek(visibleCount: max(1, visibleCount), peek: max(0, peek)))
    }

    /// Sizes every item to an exact fixed width, regardless of the viewport.
    ///
    /// - Parameter width: The width, in points, applied to each item.
    /// - Returns: A fixed-width sizing value.
    public static func fixedWidth(_ width: CGFloat) -> CarouselItemSizing {
        CarouselItemSizing(kind: .fixedWidth(max(0, width)))
    }

    /// Lets each item size itself to its own intrinsic content width.
    public static let fitContent = CarouselItemSizing(kind: .fitContent)
}
