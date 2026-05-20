import Foundation

/// Runtime state passed to custom ``TitledPageView`` title and footer builders.
///
/// Every time the active page changes or the scroll position updates,
/// `TitledPageView` rebuilds any custom `titleContent` and `footerContent`
/// closures with a fresh `TitledPageViewContext`. Use the properties here to
/// drive your custom UI — for example, to display the current title, render a
/// custom progress bar, or enable a "next" button when ``nextTitle`` is
/// non-nil.
///
/// > Note: `TitledPageViewContext` is a value type (`struct`). Do not capture
/// > it beyond the lifetime of the builder closure; always read from the
/// > freshest value delivered by the parent view.
public struct TitledPageViewContext<ID: Hashable> {

    /// The id currently bound to the paged view's selection.
    ///
    /// Matches the value of the `selection` binding passed to ``TitledPageView``.
    /// Changes every time the active page changes.
    public let selection: ID

    /// The zero-based index of the page that is currently selected.
    public let activeIndex: Int

    /// Continuous scroll progress through the pages.
    ///
    /// Whole values (e.g. `1.0`) represent a fully snapped page. Fractional
    /// values (e.g. `1.4`) represent an in-flight drag between two pages. Use
    /// this to drive custom animations that track the user's finger, such as a
    /// scrubbing progress bar or a cross-fading title.
    public let progress: Double

    /// Total number of pages represented by the paged view.
    public let pageCount: Int

    /// All page titles in display order.
    public let titles: [String]

    /// The active page title, or an empty string when no title is available.
    public let currentTitle: String

    /// The title of the page immediately before the active page, or `nil` when
    /// the first page is active.
    public let previousTitle: String?

    /// The title of the page immediately after the active page, or `nil` when
    /// the last page is active.
    public let nextTitle: String?

    /// Navigates to the page at the given zero-based index.
    ///
    /// Calls to this closure are safe to make from a button action or gesture
    /// handler inside a builder. The navigation respects the component's
    /// current animation and unidirectional-mode constraints — forward-only
    /// navigation is enforced automatically when the peek direction is
    /// ``PaginationPeekDirection/unidirectional``.
    ///
    /// - Parameter index: The zero-based index of the destination page.
    ///   Out-of-range values are ignored.
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
