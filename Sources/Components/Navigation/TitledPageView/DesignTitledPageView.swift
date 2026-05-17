import DesignSystem
import SwiftUI

/// A themed, horizontally paged view with a synchronized title header.
///
/// ![DesignTitledPageView showing three pages with dots indicator and bidirectional title peek](designPagedView)
///
/// `DesignTitledPageView` renders each element of a collection as a full-width
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
/// active `DesignTheme` injected through the environment. Use
/// ``DesignPaginationStyle`` together with the `designPaginationStyle(_:)`
/// view modifier to override individual properties without redefining the
/// theme.
///
/// ## Layout requirement
///
/// `DesignTitledPageView` uses `containerRelativeFrame(.horizontal)` internally,
/// so it must be placed inside a parent that proposes a finite horizontal
/// width (a root view, a `VStack`, a sized container). Embedding inside an
/// `HStack` with intrinsic-width siblings can collapse the page width to 0.
public struct DesignTitledPageView<Data, ID, PageContent>: View
where
    Data: RandomAccessCollection,
    ID: Hashable,
    PageContent: View
{

    // MARK: - Stored properties

    let pages: [Data.Element]
    let idKeyPath: KeyPath<Data.Element, ID>
    let titleKeyPath: KeyPath<Data.Element, String>
    let indicatorStyle: DesignPaginationIndicatorStyle
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
    ///   - id: KeyPath that yields a unique, stable id for each page.
    ///   - title: KeyPath that yields the display title for each page. The
    ///     title is shown in the header strip and used as the VoiceOver
    ///     label for each page.
    ///   - indicatorStyle: How — or whether — to draw the page-position
    ///     indicator. Defaults to ``DesignPaginationIndicatorStyle/dots``.
    ///   - content: A view builder that produces the body for each page.
    public init(
        _ pages: Data,
        selection: Binding<ID>,
        id: KeyPath<Data.Element, ID>,
        title: KeyPath<Data.Element, String>,
        indicatorStyle: DesignPaginationIndicatorStyle = .dots,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.pages = Array(pages)
        self._selection = selection
        self.idKeyPath = id
        self.titleKeyPath = title
        self.indicatorStyle = indicatorStyle
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
        let resolved = Self.resolveStyle(override: styleOverride, theme: theme)
        let showIndicator = Self.shouldShowIndicator(count: pages.count, style: indicatorStyle)
        let titles = pages.map { $0[keyPath: titleKeyPath] }
        let activeIdx = activeIndex
        let rawProgress = Self.progress(contentOffsetX: scrollOffsetX, viewportWidth: viewportWidth)
        let progress: CGFloat = if styleOverride.peekDirection == .unidirectional {
            rawProgress + CGFloat(unidirectionalBaseIndex)
        } else {
            rawProgress
        }

        VStack(spacing: resolved.headerSpacing) {
            if pages.count > 1 {
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
            } else if let only = titles.first {
                Text(only)
                    .font(resolved.titleFont)
                    .foregroundStyle(resolved.titleColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.85)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .accessibilityHidden(true)
            }

            pagesScrollView

            if showIndicator {
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

public extension DesignTitledPageView where Data.Element: Identifiable, ID == Data.Element.ID {

    /// Creates a paged view over a collection whose elements are
    /// `Identifiable`. The id is derived automatically.
    ///
    /// - Parameters:
    ///   - pages: The page data.
    ///   - selection: Two-way binding to the id of the currently visible page.
    ///   - title: KeyPath that yields the display title for each page.
    ///   - indicatorStyle: Indicator visual treatment. Defaults to `.dots`.
    ///   - content: A view builder that produces the body for each page.
    init(
        _ pages: Data,
        selection: Binding<ID>,
        title: KeyPath<Data.Element, String>,
        indicatorStyle: DesignPaginationIndicatorStyle = .dots,
        @ViewBuilder content: @escaping (Data.Element) -> PageContent
    ) {
        self.init(
            pages,
            selection: selection,
            id: \Data.Element.id,
            title: title,
            indicatorStyle: indicatorStyle,
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

/// A themed, horizontally paged view with a synchronized title header.
///
/// - Note: `DesignPagedView` is a deprecated name. Use ``DesignTitledPageView`` instead.
@available(*, deprecated, renamed: "DesignTitledPageView")
public typealias DesignPagedView = DesignTitledPageView
