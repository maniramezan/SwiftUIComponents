import DesignSystem
import SwiftUI

// MARK: - Body helpers

extension CarouselRow {

    /// The resolved inter-item spacing (and leading/trailing content margin).
    var resolvedSpacing: CGFloat {
        explicitSpacing ?? theme.spacing.twoUnits
    }

    /// The horizontal scroll view, geometry tracking, edge veil, and
    /// accessibility scrolling.
    var scrollBody: some View {
        ScrollViewReader { proxy in
            let scroll = ScrollView(.horizontal, showsIndicators: false) {
                LazyHStack(spacing: resolvedSpacing) {
                    ForEach(items, id: idKeyPath) { element in
                        sizedItem(element)
                    }
                }
                .scrollTargetLayout()
            }

            snapped(scroll)
                .contentMargins(.horizontal, resolvedSpacing, for: .scrollContent)
                .background {
                    GeometryReader { proxy in
                        Color.clear.preference(
                            key: CarouselViewportWidthKey.self,
                            value: proxy.size.width
                        )
                    }
                }
                .onPreferenceChange(CarouselViewportWidthKey.self) { width in
                    viewportWidth = width
                }
                .onScrollGeometryChange(for: CarouselGeometry.self) { geometry in
                    CarouselGeometry(
                        offsetX: geometry.contentOffset.x,
                        contentWidth: geometry.contentSize.width,
                        viewportWidth: geometry.containerSize.width
                    )
                } action: { _, new in
                    geometry = new
                }
                .overlay { edgeVeil }
                .accessibilityElement(children: .contain)
                .accessibilityScrollAction { edge in
                    stepScroll(edge: edge, proxy: proxy)
                }
        }
    }

    /// Applies the requested scroll-target behavior. `.free` leaves the row with
    /// the platform's default momentum stop.
    @ViewBuilder
    private func snapped(_ scroll: some View) -> some View {
        switch snapping {
        case .viewAligned:
            scroll.scrollTargetBehavior(.viewAligned)
        case .free:
            scroll
        }
    }

    /// A single item, sized per ``CarouselItemSizing``. While the viewport is
    /// unmeasured, a peeking item falls back to a container-relative frame so it
    /// never collapses to zero width.
    @ViewBuilder
    private func sizedItem(_ element: Data.Element) -> some View {
        let width = CarouselRowMath.itemWidth(
            viewportWidth: viewportWidth,
            sizing: sizing,
            spacing: resolvedSpacing
        )
        Group {
            switch sizing.kind {
            case .fitContent:
                content(element)
            case .fixedWidth:
                content(element).frame(width: width ?? 0)
            case .peek:
                if let width {
                    content(element).frame(width: width)
                } else {
                    content(element).containerRelativeFrame(.horizontal)
                }
            }
        }
        .id(element[keyPath: idKeyPath])
    }
}

// MARK: - Edge veil

extension CarouselRow {

    /// Two trough-colored gradient bands that veil the scrollable edges and fade
    /// out once that end is reached. Decorative and non-interactive.
    @ViewBuilder
    var edgeVeil: some View {
        let edges = CarouselRowMath.edgeFade(
            contentOffsetX: geometry.offsetX,
            contentWidth: geometry.contentWidth,
            viewportWidth: geometry.viewportWidth
        )
        HStack(spacing: 0) {
            edgeBand(visible: edges.leading, isLeading: true)
            Spacer(minLength: 0)
            edgeBand(visible: edges.trailing, isLeading: false)
        }
        .allowsHitTesting(false)
        .animation(veilAnimation, value: edges.leading)
        .animation(veilAnimation, value: edges.trailing)
    }

    private func edgeBand(visible: Bool, isLeading: Bool) -> some View {
        let trough = theme.colors.background
        let colors: [Color] =
            isLeading
            ? [trough, trough.opacity(0)]
            : [trough.opacity(0), trough]
        return LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.5)
        )
        .frame(width: theme.spacing.fourUnits)
        .opacity(visible ? 1 : 0)
    }

    /// The animation used for the veil fade — a shorter ease under Reduce Motion.
    var veilAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.15) : theme.motion.standardAnimation
    }
}

// MARK: - Accessibility scrolling

extension CarouselRow {

    /// Advances the row by one page of visible items in response to a VoiceOver
    /// scroll gesture, estimating the current position from the scroll offset.
    func stepScroll(edge: Edge, proxy: ScrollViewProxy) {
        let direction = CarouselRowMath.accessibilityStep(for: edge, layoutDirection: layoutDirection)
        guard direction != 0 else { return }
        let ids = items.map { $0[keyPath: idKeyPath] }
        guard !ids.isEmpty else { return }

        let width = CarouselRowMath.itemWidth(
            viewportWidth: viewportWidth,
            sizing: sizing,
            spacing: resolvedSpacing
        )
        let step = (width ?? viewportWidth) + resolvedSpacing
        let current = step > 0 ? Int((geometry.offsetX / step).rounded()) : 0
        let stride = CarouselRowMath.pageStride(sizing: sizing)
        let target = CarouselRowMath.clampedIndex(current + direction * stride, count: ids.count)

        withAnimation(veilAnimation) {
            proxy.scrollTo(ids[target], anchor: .leading)
        }
    }
}

// MARK: - Preview

#Preview("Carousel Row") {
    let apps = Array(1...8)
    return PreviewContent { theme in
        ScrollView {
            VStack(alignment: .leading, spacing: theme.spacing.threeUnits) {
                Text("Peek — one item + sliver")
                    .designTextStyle(.headline)
                CarouselRow(apps, id: \.self, sizing: .peek(visibleCount: 1)) { value in
                    previewCard(value, theme: theme)
                }

                Text("Peek — two visible")
                    .designTextStyle(.headline)
                CarouselRow(apps, id: \.self, sizing: .peek(visibleCount: 2)) { value in
                    previewCard(value, theme: theme)
                }

                Text("Fixed width, free scroll")
                    .designTextStyle(.headline)
                CarouselRow(apps, id: \.self, sizing: .fixedWidth(120), snapping: .free) { value in
                    previewCard(value, theme: theme)
                }
            }
            .padding(.vertical, theme.spacing.twoUnits)
        }
    }
}

@MainActor
private func previewCard(_ value: Int, theme: any Theme) -> some View {
    RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
        .fill(theme.colors.containerSecondary)
        .frame(height: 140)
        .overlay {
            Text("\(value)")
                .designTextStyle(.title)
        }
}
