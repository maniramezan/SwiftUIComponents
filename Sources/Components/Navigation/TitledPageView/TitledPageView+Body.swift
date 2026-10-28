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
            collection: collection,
            titleAlignment: titleAlignment,
            indicatorStyle: indicatorStyle,
            customTitle: customTitle,
            customFooter: customFooter,
            content: content,
            selection: $selection,
            scrollOffsetX: $scrollOffsetX,
            viewportWidth: $viewportWidth,
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

    let collection: TitledPageCollection<Element, ID>
    let titleAlignment: TitledPageTitleAlignment
    let indicatorStyle: PaginationIndicatorStyle
    let customTitle: ((TitledPageViewContext<ID>) -> AnyView)?
    let customFooter: ((TitledPageViewContext<ID>) -> AnyView)?
    let content: (Element) -> PageContent

    @Binding var selection: ID
    @Binding var scrollOffsetX: CGFloat
    @Binding var viewportWidth: CGFloat
    @Binding var swipeHintOffset: CGFloat
    @Binding var isSwipeHintPlaying: Bool

    @Environment(\.designTheme) private var theme
    @Environment(\.designPaginationStyle) private var styleOverride
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.designSwipeHintConfig) private var swipeHintConfig
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        let resolved = TitledPageViewMath.resolveStyle(
            override: styleOverride,
            theme: theme,
            titleAlignment: titleAlignment
        )
        let showIndicator = TitledPageViewMath.shouldShowIndicator(
            count: collection.entries.count,
            style: indicatorStyle
        )
        let titles = collection.titles
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
        let crossfades = reduceMotion && resolved.reduceMotionUsesCrossfade
        let progress = crossfades ? CGFloat(activeIdx) : rawProgress + hintProgress
        let context = pageContext(titles: titles, activeIndex: activeIdx, progress: progress)

        VStack(spacing: resolved.headerSpacing) {
            if let customTitle {
                customTitle(context)
            } else if resolved.titleAlignment != .hidden, collection.entries.count > 1 {
                TitledPageViewHeader(
                    resolved: resolved,
                    entries: collection.header,
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

            if crossfades, collection.entries.indices.contains(activeIdx) {
                TitledPageCrossfadeContent(
                    entry: collection.entries[activeIdx], content: content,
                    onStep: step
                )
            } else {
                TitledPageViewPagesScrollView(
                    collection: collection,
                    content: content,
                    swipeHintOffset: swipeHintOffset,
                    isSwipeHintPlaying: isSwipeHintPlaying,
                    activeIndex: activeIdx,
                    scrollOffsetX: $scrollOffsetX,
                    selectionBinding: $selection,
                    layoutDirection: layoutDirection,
                    onJump: { jump(to: $0, reduceMotion: reduceMotion) }
                )
            }

            if let customFooter {
                customFooter(context)
            } else if showIndicator {
                TitledPageViewIndicator(
                    resolved: resolved,
                    style: indicatorStyle,
                    count: collection.entries.count,
                    activeIndex: activeIdx,
                    progress: progress,
                    currentTitle: titles.indices.contains(activeIdx) ? titles[activeIdx] : "",
                    onJump: { idx in jump(to: idx, reduceMotion: reduceMotion) },
                    onAdjustableStep: { step in
                        let newIdx = TitledPageViewMath.stepIndex(
                            by: step,
                            from: activeIdx,
                            count: collection.entries.count
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
        .task(
            id: SwipeHintTaskID(
                configuration: swipeHintConfig, reduceMotion: reduceMotion,
                sceneActive: scenePhase == .active, pageCount: collection.entries.count
            )
        ) {
            guard scenePhase == .active else { return }
            await playSwipeHintIfNeeded(reduceMotion: reduceMotion)
        }
    }

    // MARK: - Navigation state helpers

    /// The index in `pages` whose id currently matches `selection`. Falls
    /// back to the nearest integer of the scroll progress when the binding
    /// is mid-update, which keeps the indicator and header in sync during
    /// in-flight drags.
    private var activeIndex: Int {
        if let idx = collection.indices[selection] {
            return idx
        }
        let progress = TitledPageViewMath.progress(
            contentOffsetX: scrollOffsetX,
            viewportWidth: viewportWidth
        )
        return TitledPageViewMath.stepIndex(
            by: 0,
            from: Int(progress.rounded()),
            count: collection.entries.count
        )
    }

    /// Not `private` so tests can drive it directly rather than simulating a
    /// real tap on the header title, an indicator dot, or an accessibility
    /// adjustable action.
    func jump(to index: Int, reduceMotion: Bool) {
        guard collection.entries.indices.contains(index) else { return }
        let newID = collection.entries[index].id
        let animation: Animation = theme.motion.animation(reducingMotion: reduceMotion)
        withAnimation(animation) {
            selection = newID
        }
    }

    private func step(_ delta: Int) {
        jump(
            to: TitledPageViewMath.stepIndex(by: delta, from: activeIndex, count: collection.entries.count),
            reduceMotion: reduceMotion)
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
            pageCount: collection.entries.count,
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
    func playSwipeHintIfNeeded(reduceMotion: Bool) async {
        guard swipeHintConfig.isEnabled, collection.entries.count > 1, !reduceMotion else { return }
        let hintDistance = swipeHintConfig.distance ?? theme.spacing.fiveUnits
        do {
            try await Task.sleep(for: .seconds(swipeHintConfig.delay))
            guard activeIndex == 0, TitledPageSwipeHintHistory.claim() else { return }
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

    let collection: TitledPageCollection<Element, ID>
    let content: (Element) -> PageContent
    let swipeHintOffset: CGFloat
    let isSwipeHintPlaying: Bool
    let activeIndex: Int

    @Binding var scrollOffsetX: CGFloat
    @Binding var selectionBinding: ID

    let layoutDirection: LayoutDirection
    let onJump: (Int) -> Void

    /// Bridges the `ID?` shape required by `scrollPosition(id:)` to the
    /// non-optional `Binding<ID>` API. Updates must name an existing page.
    private var scrollPositionBinding: Binding<ID?> {
        Binding(
            get: { selectionBinding },
            set: { value in
                guard let value, collection.indices[value] != nil else { return }
                selectionBinding = value
            })
    }

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 0) {
                ForEach(collection.entries) { page in
                    content(page.element)
                        .containerRelativeFrame(.horizontal)
                        .id(page.id)
                        .accessibilityElement(children: .contain)
                        .accessibilityLabel(Text(page.title))
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
        let delta = TitledPageViewMath.accessibilityStep(
            for: edge,
            layoutDirection: layoutDirection
        )
        let newIdx = TitledPageViewMath.stepIndex(
            by: delta,
            from: activeIndex,
            count: collection.entries.count
        )
        onJump(newIdx)
    }
}

private struct SwipeHintTaskID: Equatable {
    let configuration: TitledPageSwipeHintConfig
    let reduceMotion: Bool
    let sceneActive: Bool
    let pageCount: Int
}

struct TitledPageCrossfadeContent<Element, ID: Hashable, PageContent: View>: View {
    let entry: TitledPageCollection<Element, ID>.Entry
    let content: (Element) -> PageContent
    let onStep: (Int) -> Void
    @Environment(\.designTheme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection

    var body: some View {
        ZStack {
            content(entry.element)
                .id(entry.id)
                .transition(.opacity)
                .accessibilityElement(children: .contain)
                .accessibilityLabel(Text(entry.title))
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .animation(theme.motion.animation(reducingMotion: true), value: entry.id)
        .gesture(
            DragGesture().onEnded { value in
                guard abs(value.translation.width) > theme.motion.minimumHitTarget else { return }
                let physicalStep = value.translation.width < 0 ? 1 : -1
                onStep(layoutDirection == .rightToLeft ? -physicalStep : physicalStep)
            }
        )
        .accessibilityScrollAction { edge in
            onStep(TitledPageViewMath.accessibilityStep(for: edge, layoutDirection: layoutDirection))
        }
    }
}

// MARK: - Preference keys

struct TitledPageViewViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
