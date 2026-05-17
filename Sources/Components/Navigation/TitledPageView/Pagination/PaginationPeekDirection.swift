import Foundation

/// Controls how much of the adjacent pages' titles is visible alongside the
/// current page's title in the header strip of ``TitledPageView``.
public enum PaginationPeekDirection: Sendable, Hashable, CaseIterable {

    /// Both the previous and next page titles peek into the header on the
    /// leading and trailing edges. This is the default and mimics
    /// horizontal carousel UIs that emphasize lateral continuity.
    case bidirectional

    /// Only the next page's title peeks on the trailing edge (leading edge
    /// in right-to-left layouts). Matches the App Store featured carousel.
    case unidirectional

    /// No peek — the current title fills the header strip.
    case none
}
