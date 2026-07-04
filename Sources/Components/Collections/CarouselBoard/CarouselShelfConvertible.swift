import SwiftUI

/// A section that a ``CarouselBoard`` can render as one horizontal shelf.
///
/// ``CarouselShelf`` is the built-in conformer; conform your own type to supply
/// a fully bespoke shelf. A board erases every shelf to `AnyView`, which is what
/// lets shelves carry heterogeneous item types within a single board.
public protocol CarouselShelfConvertible {
    /// A stable identifier used to distinguish shelves within a board.
    var shelfID: AnyHashable { get }
    /// Builds the shelf's view — typically a header above a ``CarouselRow``.
    @MainActor func makeShelf() -> AnyView
}
