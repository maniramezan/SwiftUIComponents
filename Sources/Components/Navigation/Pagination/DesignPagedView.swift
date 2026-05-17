import DesignSystem
import SwiftUI

/// A themed, horizontally paged view with a synchronized title header.
///
/// ![DesignPagedView showing three pages with dots indicator and bidirectional title peek](designPagedView)
///
/// `DesignPagedView` renders each element of a collection as a full-width page
/// inside a paging `ScrollView`. Above the pages, a title strip shows the
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
/// `DesignPagedView` uses `containerRelativeFrame(.horizontal)` internally,
/// so it must be placed inside a parent that proposes a finite horizontal
/// width (a root view, a `VStack`, a sized container). Embedding inside an
/// `HStack` with intrinsic-width siblings can collapse the page width to 0.
public struct DesignPagedView<Data, ID, PageContent>: View
where Data: RandomAccessCollection,
      ID: Hashable,
      PageContent: View {

    // MARK: - Stored properties

    private let pages: [Data.Element]
    private let idKeyPath: KeyPath<Data.Element, ID>
    private let titleKeyPath: KeyPath<Data.Element, String>
    private let indicatorStyle: DesignPaginationIndicatorStyle
    private let content: (Data.Element) -> PageContent

    @Binding private var selection: ID

    @State private var scrollOffsetX: CGFloat = 0
    @State private var viewportWidth: CGFloat = 0

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
        let progress = Self.progress(contentOffsetX: scrollOffsetX, viewportWidth: viewportWidth)

        VStack(spacing: resolved.headerSpacing) {
            if pages.count > 1 {
                DesignPaginationHeader(
                    resolved: resolved,
                    titles: titles,
                    progress: progress,
                    activeIndex: activeIdx,
                    viewportWidth: viewportWidth,
                    layoutSign: layoutDirection == .rightToLeft ? -1 : 1,
                    reduceMotion: reduceMotion
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
                DesignPaginationIndicator(
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
                    .preference(key: PaginationViewportWidthKey.self, value: proxy.size.width)
            }
        )
        .onPreferenceChange(PaginationViewportWidthKey.self) { width in
            viewportWidth = width
        }
        .accessibilityElement(children: .contain)
    }

    private var pagesScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(pages, id: idKeyPath) { page in
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
        .accessibilityScrollAction { edge in
            let delta: Int
            switch edge {
            case .leading, .top: delta = -1
            case .trailing, .bottom: delta = +1
            @unknown default: delta = +1
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
    /// non-optional `Binding<ID>` API.
    private var scrollPositionBinding: Binding<ID?> {
        Binding(
            get: { selection },
            set: { newValue in
                if let newValue { selection = newValue }
            }
        )
    }

    private func jump(to index: Int, reduceMotion: Bool) {
        guard pages.indices.contains(index) else { return }
        let newID = pages[index][keyPath: idKeyPath]
        let animation: Animation =
            reduceMotion ? .easeInOut(duration: 0.15) : theme.motion.standardAnimation
        withAnimation(animation) {
            selection = newID
        }
    }
}

// MARK: - Identifiable convenience

public extension DesignPagedView where Data.Element: Identifiable, ID == Data.Element.ID {

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

// MARK: - Pure helpers

extension DesignPagedView {

    /// Converts a raw horizontal scroll offset into a continuous page
    /// progress value (page 0 → 0, page 1 → 1, …). Guards against zero
    /// viewport widths.
    nonisolated static func progress(contentOffsetX: CGFloat, viewportWidth: CGFloat) -> CGFloat {
        guard viewportWidth > 0 else { return 0 }
        return contentOffsetX / viewportWidth
    }

    /// Returns the index `from + step` clamped to `0 ..< count`. Returns
    /// `from` unchanged when `count` is zero.
    nonisolated static func stepIndex(by step: Int, from: Int, count: Int) -> Int {
        guard count > 0 else { return from }
        let raw = from + step
        return max(0, min(count - 1, raw))
    }

    /// Whether the indicator subview should render at all. Hidden styles
    /// always return `false`; visible styles require more than one page.
    nonisolated static func shouldShowIndicator(
        count: Int,
        style: DesignPaginationIndicatorStyle
    ) -> Bool {
        switch style {
        case .hidden: return false
        case .dots, .bar: return count > 1
        }
    }

    /// Merges a ``DesignPaginationStyle`` override with the active theme to
    /// produce a fully-resolved style snapshot. Internal — used by the
    /// header and indicator subviews.
    @MainActor
    static func resolveStyle(
        override: DesignPaginationStyle,
        theme: any DesignTheme
    ) -> ResolvedPaginationStyle {
        ResolvedPaginationStyle(
            titleFont: override.titleFont ?? theme.typography.title,
            titleColor: override.titleColor ?? theme.colors.textPrimary,
            adjacentTitleColor: override.adjacentTitleColor ?? theme.colors.textTertiary,
            background: override.background,
            indicatorActiveColor: override.indicatorActiveColor ?? theme.colors.primary,
            indicatorInactiveColor: override.indicatorInactiveColor ?? theme.colors.containerSecondary,
            peekDirection: override.peekDirection,
            peekWidth: override.peekWidth ?? theme.spacing.fiveUnits,
            headerSpacing: override.headerSpacing ?? theme.spacing.twoUnits,
            titleGap: override.titleGap ?? theme.spacing.twoUnits,
            reduceMotionUsesCrossfade: override.reduceMotionUsesCrossfade
        )
    }
}

// MARK: - Preference keys

private struct PaginationViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Math

/// Pure, unit-tested geometry helpers shared by the header and metrics types.
enum DesignPaginationMath {

    /// Width of one title slot in the header HStack for the given peek mode.
    nonisolated static func slotWidth(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        direction: DesignPaginationPeekDirection
    ) -> CGFloat {
        switch direction {
        case .bidirectional:
            return max(0, viewportWidth - 2 * peek - 2 * gap)
        case .unidirectional:
            return max(0, viewportWidth - peek - gap)
        case .none:
            return max(0, viewportWidth)
        }
    }

    /// Distance between adjacent slot leading edges (`slotWidth + gap`).
    nonisolated static func slotStride(
        viewportWidth: CGFloat,
        peek: CGFloat,
        gap: CGFloat,
        direction: DesignPaginationPeekDirection
    ) -> CGFloat {
        let width = slotWidth(viewportWidth: viewportWidth, peek: peek, gap: gap, direction: direction)
        switch direction {
        case .bidirectional, .unidirectional:
            return width + gap
        case .none:
            return width
        }
    }

    /// Leading padding the header HStack should apply so that, at
    /// `progress == 0`, the first slot sits where it visually belongs for
    /// the selected peek direction.
    nonisolated static func headerLeadingPadding(
        peek: CGFloat,
        gap: CGFloat,
        direction: DesignPaginationPeekDirection
    ) -> CGFloat {
        switch direction {
        case .bidirectional: return peek + gap
        case .unidirectional, .none: return 0
        }
    }

    /// The horizontal offset to apply to the header HStack for a given
    /// progress value. `layoutSign` is `+1` for left-to-right layouts and
    /// `-1` for right-to-left.
    nonisolated static func headerOffset(
        progress: CGFloat,
        stride: CGFloat,
        layoutSign: CGFloat
    ) -> CGFloat {
        layoutSign * (-progress * stride)
    }

    /// Effective peek width after applying the Reduce Motion fallback.
    ///
    /// When Reduce Motion is on and the style opts into cross-fade behavior,
    /// peek collapses to zero so the strip cross-fades rather than slides
    /// fractional titles.
    nonisolated static func effectivePeek(
        configured: CGFloat,
        direction: DesignPaginationPeekDirection,
        reduceMotion: Bool,
        usesCrossfade: Bool
    ) -> CGFloat {
        if reduceMotion && usesCrossfade { return 0 }
        if direction == .none { return 0 }
        return max(0, configured)
    }
}

// MARK: - Previews

private struct PagedViewPreviewPage: Identifiable {
    let id: Int
    let title: String
    let symbol: String
}

private let pagedViewPreviewPages: [PagedViewPreviewPage] = [
    .init(id: 0, title: "Best of 2025", symbol: "sparkles"),
    .init(id: 1, title: "Spotlight: Health", symbol: "heart.fill"),
    .init(id: 2, title: "Travel Companions", symbol: "airplane"),
    .init(id: 3, title: "Quiet Tools", symbol: "moon.stars.fill"),
]

#Preview("Dots indicator") {
    @Previewable @State var selection = 0
    DesignPagedView(pagedViewPreviewPages, selection: $selection, title: \PagedViewPreviewPage.title) { page in
        VStack(spacing: 8) {
            Image(systemName: page.symbol)
                .font(.system(size: 48, weight: .semibold))
            Text(page.title)
                .designTextStyle(.body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .designCardSurface()
        .padding(.horizontal, 8)
    }
    .frame(height: 240)
    .padding()
}

#Preview("Bar indicator") {
    @Previewable @State var selection = 0
    DesignPagedView(
        pagedViewPreviewPages,
        selection: $selection,
        title: \PagedViewPreviewPage.title,
        indicatorStyle: .bar
    ) { page in
        VStack(spacing: 8) {
            Image(systemName: page.symbol)
                .font(.system(size: 48, weight: .semibold))
            Text(page.title)
                .designTextStyle(.body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .designCardSurface()
        .padding(.horizontal, 8)
    }
    .frame(height: 240)
    .padding()
}

#Preview("Next-only peek") {
    @Previewable @State var selection = 0
    DesignPagedView(pagedViewPreviewPages, selection: $selection, title: \PagedViewPreviewPage.title) { page in
        VStack(spacing: 8) {
            Image(systemName: page.symbol)
                .font(.system(size: 48, weight: .semibold))
            Text(page.title)
                .designTextStyle(.body)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .designCardSurface()
        .padding(.horizontal, 8)
    }
    .designPaginationStyle(.init(peekDirection: .unidirectional))
    .frame(height: 240)
    .padding()
}
