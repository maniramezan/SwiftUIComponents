import DesignSystem
import SwiftUI

// MARK: - Body helpers

extension TitledPageView {

    /// The main paged layout: title header → scroll view → indicator/footer.
    @ViewBuilder
    var pagedBody: some View {
        let resolved = Self.resolveStyle(
            override: styleOverride,
            theme: theme,
            titleAlignment: titleAlignment
        )
        let showIndicator = Self.shouldShowIndicator(count: pages.count, style: indicatorStyle)
        let titles = pages.map { $0[keyPath: titleKeyPath] }
        let activeIdx = activeIndex
        let rawProgress = Self.progress(contentOffsetX: scrollOffsetX, viewportWidth: viewportWidth)
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
        .task {
            await playSwipeHintIfNeeded()
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
            let sign: CGFloat = layoutDirection == .rightToLeft ? 1 : -1
            withAnimation(.easeOut(duration: 0.3)) {
                swipeHintOffset = sign * hintDistance
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

// MARK: - Preference keys

struct TitledPageViewViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
