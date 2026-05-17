import Foundation

/// Visual treatment for the page-position indicator drawn by ``DesignTitledPageView``.
public enum DesignPaginationIndicatorStyle: Sendable, Hashable, CaseIterable {

    /// A row of small filled circles — the active page is drawn with the
    /// active tint and the others with the inactive tint. Tapping a dot
    /// animates the paged view to that page.
    case dots

    /// A thin horizontal track with a thumb that scrubs continuously as the
    /// user swipes between pages.
    case bar

    /// No indicator is drawn. Useful when a parent view manages page
    /// position chrome or when a single page is shown.
    case hidden
}
