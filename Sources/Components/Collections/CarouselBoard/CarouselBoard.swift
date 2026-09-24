import DesignSystem
import SwiftUI

/// A two-directional, App-Store-style layout: a vertically scrolling column of
/// shelves, each of which scrolls horizontally.
///
/// Declare shelves with ``CarouselShelf`` inside the builder closure. Because
/// each shelf erases its content, shelves may carry completely different item
/// types and item views within one board.
///
/// ```swift
/// CarouselBoard {
///     CarouselShelf("Featured", items: apps) { app in FeaturedCard(app) }
///     CarouselShelf("Top Stories", items: articles) { story in ArticleCard(story) }
///     CarouselShelf("Editor's Pick") { EditorsBanner() }
/// }
/// ```
///
/// `CarouselBoard` owns its own vertical `ScrollView`. To embed shelves inside a
/// scroll you already manage (for example beneath a hero header), use
/// ``CarouselBoardContent`` instead.
public struct CarouselBoard: View {

    private let shelves: [any CarouselShelfConvertible]

    @Environment(\.designTheme) private var theme

    /// Creates a board from a builder of shelves.
    ///
    /// - Parameter shelves: A ``CarouselShelfBuilder`` closure declaring the
    ///   board's shelves top to bottom.
    public init(@CarouselShelfBuilder _ shelves: () -> [any CarouselShelfConvertible]) {
        self.shelves = shelves()
    }

    /// The SwiftUI body for the board.
    public var body: some View {
        ScrollView(.vertical) {
            CarouselBoardContent(shelves: shelves)
                .padding(.vertical, theme.spacing.twoUnits)
        }
    }
}

/// The vertical stack of shelves without an enclosing `ScrollView`, for
/// embedding inside a scroll you already manage.
///
/// ```swift
/// ScrollView {
///     HeroHeader()
///     CarouselBoardContent {
///         CarouselShelf("Featured", items: apps) { app in FeaturedCard(app) }
///     }
/// }
/// ```
public struct CarouselBoardContent: View {

    private let shelves: [any CarouselShelfConvertible]

    @Environment(\.designTheme) private var theme

    /// Creates the shelf stack from a builder of shelves.
    ///
    /// - Parameter shelves: A ``CarouselShelfBuilder`` closure declaring the
    ///   shelves top to bottom.
    public init(@CarouselShelfBuilder _ shelves: () -> [any CarouselShelfConvertible]) {
        self.shelves = shelves()
    }

    /// Creates the shelf stack from an already-collected array. Used internally
    /// by ``CarouselBoard``.
    init(shelves: [any CarouselShelfConvertible]) {
        self.shelves = shelves
    }

    /// The SwiftUI body for the embeddable shelf stack.
    public var body: some View {
        LazyVStack(alignment: .leading, spacing: theme.spacing.threeUnits) {
            // Keyed by `shelfID` rather than position, so a shelf inserted or removed
            // conditionally doesn't shift every shelf below it onto a new identity (and
            // reset their horizontal scroll positions).
            ForEach(IdentifiedCarouselShelf.identify(shelves)) { entry in
                entry.shelf.makeShelf()
            }
        }
    }
}

/// A shelf paired with a stable identity for `ForEach`.
struct IdentifiedCarouselShelf: Identifiable {

    /// The shelf's own ``CarouselShelfConvertible/shelfID`` plus how many earlier
    /// shelves share it, so two shelves with the same title still get distinct
    /// identities.
    struct ID: Hashable {
        let shelfID: AnyHashable
        let occurrence: Int
    }

    let id: ID
    let shelf: any CarouselShelfConvertible

    /// Pairs each shelf with its identity, in order.
    static func identify(_ shelves: [any CarouselShelfConvertible]) -> [IdentifiedCarouselShelf] {
        var occurrences: [AnyHashable: Int] = [:]
        return shelves.map { shelf in
            let occurrence = occurrences[shelf.shelfID, default: 0]
            occurrences[shelf.shelfID] = occurrence + 1
            return IdentifiedCarouselShelf(id: ID(shelfID: shelf.shelfID, occurrence: occurrence), shelf: shelf)
        }
    }
}
