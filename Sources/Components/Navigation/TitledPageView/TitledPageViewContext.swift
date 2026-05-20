import Foundation

/// Runtime state passed to custom ``TitledPageView`` title and footer builders.
public struct TitledPageViewContext<ID: Hashable> {

    /// The id currently bound to the paged view's selection.
    public let selection: ID

    /// The zero-based index of the page that is currently selected.
    public let activeIndex: Int

    /// Continuous page progress, where whole values represent snapped pages
    /// and fractional values represent in-flight drags.
    public let progress: Double

    /// Total number of pages represented by the paged view.
    public let pageCount: Int

    /// All page titles in display order.
    public let titles: [String]

    /// The active page title, or an empty string when no title is available.
    public let currentTitle: String

    /// The previous page title when one exists.
    public let previousTitle: String?

    /// The next page title when one exists.
    public let nextTitle: String?

    /// Selects the page at the supplied zero-based index.
    public let selectPage: (Int) -> Void

    /// Creates a page view context.
    ///
    /// - Parameters:
    ///   - selection: The id currently bound to the paged view's selection.
    ///   - activeIndex: The zero-based selected page index.
    ///   - progress: Continuous scroll progress through the pages.
    ///   - pageCount: Total number of pages.
    ///   - titles: Page titles in display order.
    ///   - currentTitle: The active page title.
    ///   - previousTitle: The previous page title, when available.
    ///   - nextTitle: The next page title, when available.
    ///   - selectPage: Action that selects a page by index.
    public init(
        selection: ID,
        activeIndex: Int,
        progress: Double,
        pageCount: Int,
        titles: [String],
        currentTitle: String,
        previousTitle: String?,
        nextTitle: String?,
        selectPage: @escaping (Int) -> Void
    ) {
        self.selection = selection
        self.activeIndex = activeIndex
        self.progress = progress
        self.pageCount = pageCount
        self.titles = titles
        self.currentTitle = currentTitle
        self.previousTitle = previousTitle
        self.nextTitle = nextTitle
        self.selectPage = selectPage
    }
}
