import DesignSystem
import SwiftUI

/// A themed, horizontally paged view with a synchronized title header.
///
/// ![TitledPageView showing three pages with dots indicator and bidirectional title peek](designPagedView)
///
/// `TitledPageView` renders each element of a collection as a full-width
/// page inside a paging `ScrollView`. Above the pages, a title strip shows the
/// current page's title and optionally peeks the adjacent pages' titles to
/// hint at lateral content. Swiping snaps to the nearest page; drag releases
/// below ~50 % of the page width snap back automatically. The component
/// supports right-to-left layouts, Dynamic Type, and VoiceOver
/// page-by-page navigation out of the box.
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

    @State private var scrollOffsetX: CGFloat = 0
    @State private var viewportWidth: CGFloat = 0
    /// In unidirectional mode, tracks the lowest visible page index. Updated
    /// only after the scroll settles so that pages aren't removed mid-swipe.
    @State private var unidirectionalBaseIndex: Int = 0

    @Environment(\.designTheme) private var theme
    @Environment(\.designPaginationStyle) private var styleOverride
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

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

    @ViewBuilder
    private var pagedBody: some View {
        let resolved = Self.resolveStyle(
            override: styleOverride,
            theme: theme,
            titleAlignment: titleAlignment
        )
        let showIndicator = Self.shouldShowIndicator(count: pages.count, style: indicatorStyle)
        let titles = pages.map { $0[keyPath: titleKeyPath] }
        let activeIdx = activeIndex
        let rawProgress = Self.progress(contentOffsetX: scrollOffsetX, viewportWidth: viewportWidth)
        let progress: CGFloat =
            if styleOverride.peekDirection == .unidirectional {
                rawProgress + CGFloat(unidirectionalBaseIndex)
            } else {
                rawProgress
            }
        let context = pageContext(titles: titles, activeIndex: activeIdx, progress: progress)

        VStack(spacing: resolved.headerSpacing) {
            if let customTitle {
                customTitle(context)
            } else if resolved.titleAlignment != .hidden, pages.count > 1 {
                TitledPageViewHeader(
                    resolved: resolved,
                    titles: titles,
                    progress: progress,
                    activeIndex: activeIdx,
                    viewportWidth: viewportWidth,
                    layoutSign: layoutDirection == .rightToLeft ? -1 : 1,
                    reduceMotion: reduceMotion,
                    onJump: { idx in jump(to: idx, reduceMotion: reduceMotion) }
                )
            } else if resolved.titleAlignment != .hidden, let only = titles.first {
                Text(only)
                    .font(resolved.titleFont)
                    .foregroundStyle(resolved.titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: singleTitleAlignment(for: resolved.titleAlignment))
                    .accessibilityHidden(true)
            }

            pagesScrollView

            if let customFooter {
                customFooter(context)
            } else if showIndicator {
                TitledPageViewIndicator(
                    resolved: resolved,
                    style: indicatorStyle,
                    count: pages.count,
                    activeIndex: activeIdx,
                    progress: progress,
                    currentTitle: titles.indices.contains(activeIdx) ? titles[activeIdx] : "",
                    onJump: { idx in jump(to: idx, reduceMotion: reduceMotion) },
                    onAdjustableStep: { step in
                        let newIdx = Self.stepIndex(by: step, from: activeIdx, count: pages.count)
                        jump(to: newIdx, reduceMotion: reduceMotion)
                    },
                    minimumHitTarget: theme.motion.minimumHitTarget
                )
            }
        }
        .background {
            if let background = resolved.background {
                Rectangle().fill(background)
            }
        }
        .background(
            GeometryReader { proxy in
                Color.clear
                    .preference(key: TitledPageViewViewportWidthKey.self, value: proxy.size.width)
            }
        )
        .onPreferenceChange(TitledPageViewViewportWidthKey.self) { width in
            viewportWidth = width
        }
        .accessibilityElement(children: .contain)
    }

    private func pageContext(
        titles: [String],
        activeIndex: Int,
        progress: CGFloat
    ) -> TitledPageViewContext<ID> {
        TitledPageViewContext(
            selection: selection,
            activeIndex: activeIndex,
            progress: Double(progress),
            pageCount: pages.count,
            titles: titles,
            currentTitle: titles.indices.contains(activeIndex) ? titles[activeIndex] : "",
            previousTitle: titles.indices.contains(activeIndex - 1) ? titles[activeIndex - 1] : nil,
            nextTitle: titles.indices.contains(activeIndex + 1) ? titles[activeIndex + 1] : nil,
            selectPage: { idx in jump(to: idx, reduceMotion: reduceMotion) }
        )
    }

    private func singleTitleAlignment(for titleAlignment: TitledPageTitleAlignment) -> Alignment {
        switch titleAlignment {
        case .automatic, .leading:
            return .leading
        case .trailing:
            return .trailing
        case .center:
            return .center
        case .hidden:
            return .leading
        }
    }

    /// The subset of pages visible in the scroll view. In unidirectional
    /// mode only the current page and those after it are rendered, preventing
    /// any backward swiping. Uses `unidirectionalBaseIndex` which updates
    /// after the scroll settles to avoid removing pages mid-animation.
    private var visiblePages: [Data.Element] {
        if styleOverride.peekDirection == .unidirectional {
            let base = min(unidirectionalBaseIndex, pages.count - 1)
            return Array(pages[max(0, base)...])
        }
        return pages
    }

    private var pagesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(visiblePages, id: idKeyPath) { page in
                    content(page)
                        .containerRelativeFrame(.horizontal)
                        .id(page[keyPath: idKeyPath])
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(Text(page[keyPath: titleKeyPath]))
                }
            }
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollPosition(id: scrollPositionBinding)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.x
        } action: { _, newValue in
            scrollOffsetX = newValue
        }
        .onScrollPhaseChange { _, newPhase in
            if styleOverride.peekDirection == .unidirectional,
                newPhase == .idle,
                let idx = pages.firstIndex(where: { $0[keyPath: idKeyPath] == selection }),
                idx > unidirectionalBaseIndex
            {
                unidirectionalBaseIndex = idx
                // Reset offset since the content shifted.
                scrollOffsetX = 0
            }
        }
        .accessibilityScrollAction { edge in
            var delta = Self.accessibilityStep(for: edge, layoutDirection: layoutDirection)
            if styleOverride.peekDirection == .unidirectional {
                delta = max(0, delta)
            }
            let newIdx = Self.stepIndex(by: delta, from: activeIndex, count: pages.count)
            jump(to: newIdx, reduceMotion: reduceMotion)
        }
    }

    // MARK: - State helpers

    /// The index in `pages` whose id currently matches `selection`. Falls
    /// back to the nearest integer of the scroll progress when the binding
    /// is mid-update, which keeps the indicator and header in sync during
    /// in-flight drags.
    private var activeIndex: Int {
        if let idx = pages.firstIndex(where: { $0[keyPath: idKeyPath] == selection }) {
            return idx
        }
        let progress = Self.progress(contentOffsetX: scrollOffsetX, viewportWidth: viewportWidth)
        return Self.stepIndex(by: 0, from: Int(progress.rounded()), count: pages.count)
    }

    /// Bridges the `ID?` shape required by `scrollPosition(id:)` to the
    /// non-optional `Binding<ID>` API. In unidirectional mode, backward
    /// scroll-position updates are rejected since previous pages have been
    /// removed from the scroll content.
    private var scrollPositionBinding: Binding<ID?> {
        Binding(
            get: { selection },
            set: { newValue in
                guard let newValue else { return }
                selection = newValue
            }
        )
    }

    private func jump(to index: Int, reduceMotion: Bool) {
        guard pages.indices.contains(index) else { return }
        if styleOverride.peekDirection == .unidirectional {
            guard index >= activeIndex else { return }
        }
        let newID = pages[index][keyPath: idKeyPath]
        let animation: Animation =
            reduceMotion ? .easeInOut(duration: 0.15) : theme.motion.standardAnimation
        withAnimation(animation) {
            selection = newID
        }
    }
}

// MARK: - Identifiable convenience

public extension TitledPageView where Data.Element: Identifiable, ID == Data.Element.ID {

    /// Creates a paged view over a collection whose elements are
    /// `Identifiable`. The id is derived automatically.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - titleAlignment: How to position the default title strip.
    ///   - indicatorStyle: Indicator visual treatment. Defaults to `.dots`.
    ///   - content: A view builder that produces the body for each page.
    init(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        titleAlignment: TitledPageTitleAlignment = .automatic,
        indicatorStyle: PaginationIndicatorStyle = .dots,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            titleAlignment: titleAlignment,
            indicatorStyle: indicatorStyle,
            content: content
        )
    }

    /// Creates an identifiable paged view with custom title and footer builders.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - titleContent: A view builder that replaces the default title strip.
    ///   - footerContent: A view builder that replaces the default indicator.
    ///   - content: A view builder that produces the body for each page.
    init<TitleContent: View, FooterContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        @ViewBuilder titleContent: @escaping (TitledPageViewContext<ID>) -> TitleContent,
        @ViewBuilder footerContent: @escaping (TitledPageViewContext<ID>) -> FooterContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            titleContent: titleContent,
            footerContent: footerContent,
            content: content
        )
    }

    /// Creates an identifiable paged view with a custom title builder.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - indicatorStyle: Indicator visual treatment. Defaults to `.dots`.
    ///   - titleContent: A view builder that replaces the default title strip.
    ///   - content: A view builder that produces the body for each page.
    init<TitleContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        indicatorStyle: PaginationIndicatorStyle = .dots,
        @ViewBuilder titleContent: @escaping (TitledPageViewContext<ID>) -> TitleContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            indicatorStyle: indicatorStyle,
            titleContent: titleContent,
            content: content
        )
    }

    /// Creates an identifiable paged view with a custom footer builder.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///     `TitledPageView` writes a new value through this binding whenever
    ///     the active page changes. Observe page changes with
    ///     `.onChange(of: selection)`.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - titleAlignment: How to position the default title strip.
    ///   - footerContent: A view builder that replaces the default indicator.
    ///   - content: A view builder that produces the body for each page.
    init<FooterContent: View>(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        titleAlignment: TitledPageTitleAlignment = .automatic,
        @ViewBuilder footerContent: @escaping (TitledPageViewContext<ID>) -> FooterContent,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            titleAlignment: titleAlignment,
            footerContent: footerContent,
            content: content
        )
    }
}

// MARK: - Preference keys

struct TitledPageViewViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Backward compatibility
