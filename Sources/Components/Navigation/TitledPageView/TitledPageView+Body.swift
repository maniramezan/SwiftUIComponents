import DesignSystem
import SwiftUI

// MARK: - Body helpers

extension TitledPageView {

    /// The main paged layout: title header → scroll view → indicator/footer.
    ///
    /// Delegates to ``TitledPageViewPagedContent``, a dedicated `View` type
    /// (rather than an inline `@ViewBuilder` property), so SwiftUI can track
    /// and diff this subtree independently of the rest of `TitledPageView`.
    var pagedBody: some View {
        TitledPageViewPagedContent(
            pages: pages,
            idKeyPath: idKeyPath,
            titleKeyPath: titleKeyPath,
            titleAlignment: titleAlignment,
            indicatorStyle: indicatorStyle,
            customTitle: customTitle,
            customFooter: customFooter,
            content: content,
            selection: $selection,
            scrollOffsetX: $scrollOffsetX,
            viewportWidth: $viewportWidth,
            unidirectionalBaseIndex: $unidirectionalBaseIndex,
            swipeHintOffset: $swipeHintOffset,
            isSwipeHintPlaying: $isSwipeHintPlaying
        )
    }
}

// MARK: - Paged content

/// The main paged layout for a ``TitledPageView``: title header → scroll
/// view → indicator/footer, plus the swipe-hint animation.
///
/// Extracted as its own `View` (instead of a computed property on
/// `TitledPageView`) so SwiftUI can diff and update it independently — a
/// plain `@ViewBuilder` property or method is always re-evaluated as part of
/// its owning view's `body` and never gets its own identity in the render
/// tree.
struct TitledPageViewPagedContent<Element, ID: Hashable, PageContent: View>: View {

    let pages: [Element]
    let idKeyPath: KeyPath<Element, ID>
    let titleKeyPath: KeyPath<Element, String>
    let titleAlignment: TitledPageTitleAlignment
    let indicatorStyle: PaginationIndicatorStyle
    let customTitle: ((TitledPageViewContext<ID>) -> AnyView)?
    let customFooter: ((TitledPageViewContext<ID>) -> AnyView)?
    let content: (Element) -> PageContent

    @Binding var selection: ID
    @Binding var scrollOffsetX: CGFloat
    @Binding var viewportWidth: CGFloat
    @Binding var unidirectionalBaseIndex: Int
    @Binding var swipeHintOffset: CGFloat
    @Binding var isSwipeHintPlaying: Bool

    @Environment(\.designTheme) private var theme
    @Environment(\.designPaginationStyle) private var styleOverride
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.designSwipeHintConfig) private var swipeHintConfig

    var body: some View {
        let resolved = TitledPageViewMath.resolveStyle(
            override: styleOverride,
            theme: theme,
            titleAlignment: titleAlignment
        )
        let showIndicator = TitledPageViewMath.shouldShowIndicator(
            count: pages.count,
            style: indicatorStyle
        )
        let titles = pages.map { $0[keyPath: titleKeyPath] }
        let activeIdx = activeIndex
        // SwiftUI reports `contentOffset.x` in logical coordinates, so page 0
        // is always 0 and progress increases toward the last page — in both
        // LTR and RTL. No layout-direction conversion is needed here; the
        // header and indicator mirror themselves automatically in RTL.
        let rawProgress = TitledPageViewMath.progress(
            contentOffsetX: scrollOffsetX,
            viewportWidth: viewportWidth
        )
        // Blend the hint offset so the header and indicator animate in sync with the content.
        let hintProgress: CGFloat = viewportWidth > 0 ? (-swipeHintOffset / viewportWidth) : 0
        let progress: CGFloat =
            if styleOverride.peekDirection == .unidirectional {
                rawProgress + CGFloat(unidirectionalBaseIndex) + hintProgress
            } else {
                rawProgress + hintProgress
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

            TitledPageViewPagesScrollView(
                pages: visiblePages,
                idKeyPath: idKeyPath,
                titleKeyPath: titleKeyPath,
                content: content,
                peekDirection: styleOverride.peekDirection,
                selection: selection,
                swipeHintOffset: swipeHintOffset,
                isSwipeHintPlaying: isSwipeHintPlaying,
                activeIndex: activeIdx,
                scrollOffsetX: $scrollOffsetX,
                unidirectionalBaseIndex: $unidirectionalBaseIndex,
                selectionBinding: $selection,
                layoutDirection: layoutDirection,
                onJump: { idx in jump(to: idx, reduceMotion: reduceMotion) }
            )

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
                        let newIdx = TitledPageViewMath.stepIndex(
                            by: step,
                            from: activeIdx,
                            count: pages.count
                        )
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
        .task {
            await playSwipeHintIfNeeded()
        }
    }

    // MARK: - Navigation state helpers

    /// The index in `pages` whose id currently matches `selection`. Falls
    /// back to the nearest integer of the scroll progress when the binding
    /// is mid-update, which keeps the indicator and header in sync during
    /// in-flight drags.
    private var activeIndex: Int {
        if let idx = pages.firstIndex(where: { $0[keyPath: idKeyPath] == selection }) {
            return idx
        }
        let progress = TitledPageViewMath.progress(
            contentOffsetX: scrollOffsetX,
            viewportWidth: viewportWidth
        )
        return TitledPageViewMath.stepIndex(
            by: 0,
            from: Int(progress.rounded()),
            count: pages.count
        )
    }

    /// The subset of pages visible in the scroll view. In unidirectional
    /// mode only the current page and those after it are rendered, preventing
    /// any backward swiping. Uses `unidirectionalBaseIndex` which updates
    /// after the scroll settles to avoid removing pages mid-animation.
    private var visiblePages: [Element] {
        if styleOverride.peekDirection == .unidirectional {
            let base = min(unidirectionalBaseIndex, pages.count - 1)
            return Array(pages[max(0, base)...])
        }
        return pages
    }

    /// Not `private` so tests can drive it directly rather than simulating a
    /// real tap on the header title, an indicator dot, or an accessibility
    /// adjustable action.
    func jump(to index: Int, reduceMotion: Bool) {
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

    /// Plays a brief peek animation that reveals the leading edge of the next page,
    /// then springs back. Fires once on first appearance when: hints are enabled,
    /// there are 2+ pages, the user is still on page 0, and Reduce Motion is off.
    private func playSwipeHintIfNeeded() async {
        guard swipeHintConfig.isEnabled, pages.count > 1, !reduceMotion else { return }
        let hintDistance = swipeHintConfig.distance ?? theme.spacing.fiveUnits
        do {
            try await Task.sleep(for: .seconds(swipeHintConfig.delay))
            guard activeIndex == 0 else { return }
            isSwipeHintPlaying = true
            // Shifting content left reveals the next page in both LTR (next is right)
            // and RTL (next is left in physical layout), and keeps hintProgress positive.
            withAnimation(.easeOut(duration: 0.3)) {
                swipeHintOffset = -hintDistance
            }
            try await Task.sleep(for: .seconds(0.38))
            withAnimation(.spring(response: 0.42, dampingFraction: 0.68)) {
                swipeHintOffset = 0
            }
            try await Task.sleep(for: .seconds(0.5))
        } catch {
            swipeHintOffset = 0
        }
        isSwipeHintPlaying = false
    }
}

// MARK: - Pages scroll view

/// The horizontally-paging `ScrollView` of page content.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the header and
/// indicator around it.
struct TitledPageViewPagesScrollView<Element, ID: Hashable, PageContent: View>: View {

    let pages: [Element]
    let idKeyPath: KeyPath<Element, ID>
    let titleKeyPath: KeyPath<Element, String>
    let content: (Element) -> PageContent
    let peekDirection: PaginationPeekDirection
    let selection: ID
    let swipeHintOffset: CGFloat
    let isSwipeHintPlaying: Bool
    let activeIndex: Int

    @Binding var scrollOffsetX: CGFloat
    @Binding var unidirectionalBaseIndex: Int
    @Binding var selectionBinding: ID

    let layoutDirection: LayoutDirection
    let onJump: (Int) -> Void

    /// Bridges the `ID?` shape required by `scrollPosition(id:)` to the
    /// non-optional `Binding<ID>` API. In unidirectional mode, backward
    /// scroll-position updates are rejected since previous pages have been
    /// removed from the scroll content.
    private var scrollPositionBinding: Binding<ID?> {
        Binding(
            get: { selectionBinding },
            set: { newValue in
                guard let newValue else { return }
                selectionBinding = newValue
            }
        )
    }

    var body: some View {
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
            .offset(x: swipeHintOffset)
            .scrollTargetLayout()
        }
        .scrollTargetBehavior(.paging)
        .scrollDisabled(isSwipeHintPlaying)
        .scrollPosition(id: scrollPositionBinding)
        .onScrollGeometryChange(for: CGFloat.self) { geometry in
            geometry.contentOffset.x
        } action: { _, newValue in
            scrollOffsetX = newValue
        }
        .onScrollPhaseChange { _, newPhase in
            if peekDirection == .unidirectional,
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
            stepScroll(edge: edge)
        }
    }

    /// Advances (or retreats) the active page in response to a VoiceOver
    /// scroll gesture.
    ///
    /// Not `private` so tests can drive it directly rather than simulating a
    /// real VoiceOver accessibility scroll gesture.
    func stepScroll(edge: Edge) {
        var delta = TitledPageViewMath.accessibilityStep(
            for: edge,
            layoutDirection: layoutDirection
        )
        if peekDirection == .unidirectional {
            delta = max(0, delta)
        }
        let newIdx = TitledPageViewMath.stepIndex(
            by: delta,
            from: activeIndex,
            count: pages.count
        )
        onJump(newIdx)
    }
}

// MARK: - Preference keys

struct TitledPageViewViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
