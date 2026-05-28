import DesignSystem
import SwiftUI

/// A themed, horizontally paged view with a synchronized title header.
///
///
/// `TitledPageView` renders each element of a collection as a full-width
/// page inside a paging `ScrollView`. Above the pages, a title strip shows the
/// current page's title and optionally peeks the adjacent pages' titles to
/// hint at lateral content. Swiping snaps to the nearest page; drag releases
/// below ~50 % of the page width snap back automatically. The component
/// supports right-to-left layouts, Dynamic Type, and VoiceOver
/// page-by-page navigation out of the box.
///
/// ## Swipe hint
///
/// On first appearance, `TitledPageView` plays a brief animation that peeks the
/// next page, signalling to users that the content is horizontally swipeable.
/// The hint fires automatically when there are two or more pages and the view
/// is on the first page. It is suppressed when Reduce Motion is enabled.
///
/// Configure or disable the hint with the `designSwipeHint(_:)` view modifier
/// and a ``TitledPageSwipeHintConfig`` value:
///
/// ```swift
/// TitledPageView(pages, selection: $selection, title: \.title) { page in
///     PageBody(page: page)
/// }
/// .designSwipeHint(.disabled)                  // opt out entirely
/// .designSwipeHint(.init(delay: 1.5))          // fire later
/// .designSwipeHint(.init(distance: 60))        // peek further
/// ```
///
/// ## Theming
///
/// All visual defaults — fonts, colors, spacing, motion — resolve from the
/// active `Theme` injected through the environment. Use
/// ``PaginationStyle`` together with the `designPaginationStyle(_:)`
/// view modifier to override individual properties without redefining the
/// theme.
///
/// ## Observing page changes
///
/// `TitledPageView` has no dedicated `onPageChange` callback. Instead, the
/// `selection` binding is updated every time the active page changes — whether
/// from a swipe, a header-title tap, or programmatic navigation. Observe it
/// with SwiftUI's standard `.onChange(of:)` modifier:
///
/// ```swift
/// @State private var selectedID = pages.first!.id
///
/// TitledPageView(pages, selection: $selectedID, title: \.title) { page in
///     PageBody(page: page)
/// }
/// .onChange(of: selectedID) { _, newID in
///     // React to the page change here.
///     print("Navigated to page", newID)
/// }
/// ```
///
/// For context beyond just the id — such as the new page's title, index, or
/// scroll progress — supply a custom `titleContent` or `footerContent` builder.
/// Those builders receive a ``TitledPageViewContext`` value on every render,
/// which carries ``TitledPageViewContext/currentTitle``,
/// ``TitledPageViewContext/activeIndex``, ``TitledPageViewContext/progress``,
/// and more.
///
/// ## Layout requirement
///
/// `TitledPageView` uses `containerRelativeFrame(.horizontal)` internally,
/// so it must be placed inside a parent that proposes a finite horizontal
/// width (a root view, a `VStack`, a sized container). Embedding inside an
/// `HStack` with intrinsic-width siblings can collapse the page width to 0.
public struct TitledPageView<Data, ID, PageContent>: View
where
    Data: RandomAccessCollection,
    ID: Hashable,
    PageContent: View
{

    // MARK: - Stored properties

    let pages: [Data.Element]
    let idKeyPath: KeyPath<Data.Element, ID>
    let titleKeyPath: KeyPath<Data.Element, String>
    let titleAlignment: TitledPageTitleAlignment
    let indicatorStyle: PaginationIndicatorStyle
    let customTitle: ((TitledPageViewContext<ID>) -> AnyView)?
    let customFooter: ((TitledPageViewContext<ID>) -> AnyView)?
    let content: (Data.Element) -> PageContent

    @Binding var selection: ID

    @State var scrollOffsetX: CGFloat = 0
    @State var viewportWidth: CGFloat = 0
    /// In unidirectional mode, tracks the lowest visible page index. Updated
    /// only after the scroll settles so that pages aren't removed mid-swipe.
    @State var unidirectionalBaseIndex: Int = 0
    /// Visual offset applied to the page content during the swipe-hint animation.
    /// Zero at all other times.
    @State var swipeHintOffset: CGFloat = 0
    @State var isSwipeHintPlaying: Bool = false

    @Environment(\.designTheme) var theme
    @Environment(\.designPaginationStyle) var styleOverride
    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    @Environment(\.designSwipeHintConfig) var swipeHintConfig

    // MARK: - Initializers

    /// Creates a paged view over a collection.
    ///
    /// - Parameters:
    ///   - pages: The page data. Must be non-empty for the view to render
    ///     content; an empty collection produces an `EmptyView`.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes — on swipe, header-title tap, or
    ///     programmatic navigation. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - id: KeyPath that yields a unique, stable id for each page.
    ///   - title: KeyPath that yields the display title for each page. The
    ///     title is shown in the header strip and used as the VoiceOver
    ///     label for each page.
    ///   - titleAlignment: How to position the default title strip. Defaults
    ///     to ``TitledPageTitleAlignment/automatic`` to preserve the style's
    ///     existing title peek behavior.
    ///   - indicatorStyle: How — or whether — to draw the page-position
    ///     indicator. Defaults to ``PaginationIndicatorStyle/dots``.
    ///   - content: A view builder that produces the body for each page.
    public init(
        _ pages: Data,
        selection: Binding<ID>,
        id: KeyPath<Data.Element, ID>,
        title: KeyPath<Data.Element, String>,
        titleAlignment: TitledPageTitleAlignment = .automatic,
        indicatorStyle: PaginationIndicatorStyle = .dots,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.pages = Array(pages)
        self._selection = selection
        self.idKeyPath = id
        self.titleKeyPath = title
        self.titleAlignment = titleAlignment
        self.indicatorStyle = indicatorStyle
        self.customTitle = nil
        self.customFooter = nil
        self.content = content
    }

    /// Creates a paged view with custom title and footer builders.
    ///
    /// - Parameters:
    ///   - pages: The page data. Must be non-empty for the view to render
    ///     content; an empty collection produces an `EmptyView`.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - id: KeyPath that yields a unique, stable id for each page.
    ///   - title: KeyPath that yields the display title for each page. The
    ///     title remains the VoiceOver label for each page.
    ///   - titleContent: A view builder that replaces the default title strip.
    ///   - footerContent: A view builder that replaces the default indicator.
    ///   - content: A view builder that produces the body for each page.
    public init<TitleContent: View, FooterContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        id: KeyPath<Data.Element, ID>,
        title: KeyPath<Data.Element, String>,
        @ViewBuilder titleContent: @escaping (TitledPageViewContext<ID>) -> TitleContent,
        @ViewBuilder footerContent: @escaping (TitledPageViewContext<ID>) -> FooterContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.pages = Array(pages)
        self._selection = selection
        self.idKeyPath = id
        self.titleKeyPath = title
        self.titleAlignment = .automatic
        self.indicatorStyle = .hidden
        self.customTitle = { AnyView(titleContent($0)) }
        self.customFooter = { AnyView(footerContent($0)) }
        self.content = content
    }

    /// Creates a paged view with a custom title builder and default footer.
    ///
    /// - Parameters:
    ///   - pages: The page data. Must be non-empty for the view to render
    ///     content; an empty collection produces an `EmptyView`.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - id: KeyPath that yields a unique, stable id for each page.
    ///   - title: KeyPath that yields the display title for each page. The
    ///     title remains the VoiceOver label for each page.
    ///   - indicatorStyle: How — or whether — to draw the page-position
    ///     indicator below the pages.
    ///   - titleContent: A view builder that replaces the default title strip.
    ///   - content: A view builder that produces the body for each page.
    public init<TitleContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        id: KeyPath<Data.Element, ID>,
        title: KeyPath<Data.Element, String>,
        indicatorStyle: PaginationIndicatorStyle = .dots,
        @ViewBuilder titleContent: @escaping (TitledPageViewContext<ID>) -> TitleContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.pages = Array(pages)
        self._selection = selection
        self.idKeyPath = id
        self.titleKeyPath = title
        self.titleAlignment = .automatic
        self.indicatorStyle = indicatorStyle
        self.customTitle = { AnyView(titleContent($0)) }
        self.customFooter = nil
        self.content = content
    }

    /// Creates a paged view with the default title strip and a custom footer.
    ///
    /// - Parameters:
    ///   - pages: The page data. Must be non-empty for the view to render
    ///     content; an empty collection produces an `EmptyView`.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - id: KeyPath that yields a unique, stable id for each page.
    ///   - title: KeyPath that yields the display title for each page. The
    ///     title is shown in the header strip and used as the VoiceOver label
    ///     for each page.
    ///   - titleAlignment: How to position the default title strip.
    ///   - footerContent: A view builder that replaces the default indicator.
    ///   - content: A view builder that produces the body for each page.
    public init<FooterContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        id: KeyPath<Data.Element, ID>,
        title: KeyPath<Data.Element, String>,
        titleAlignment: TitledPageTitleAlignment = .automatic,
        @ViewBuilder footerContent: @escaping (TitledPageViewContext<ID>) -> FooterContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.pages = Array(pages)
        self._selection = selection
        self.idKeyPath = id
        self.titleKeyPath = title
        self.titleAlignment = titleAlignment
        self.indicatorStyle = .hidden
        self.customTitle = nil
        self.customFooter = { AnyView(footerContent($0)) }
        self.content = content
    }

    // MARK: - Body

    /// The SwiftUI body for the paged view.
    public var body: some View {
        Group {
            if pages.isEmpty {
                EmptyView()
            } else {
                pagedBody
            }
        }
    }
}
