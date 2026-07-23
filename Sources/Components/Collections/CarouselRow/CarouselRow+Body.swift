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
    ///
    /// Delegates to ``CarouselRowScrollContent``, a dedicated `View` type
    /// (rather than an inline `@ViewBuilder` property), so SwiftUI can track
    /// and diff this subtree independently of the rest of `CarouselRow`.
    var scrollBody: some View {
        CarouselRowScrollContent(
            items: items,
            idKeyPath: idKeyPath,
            sizing: sizing,
            spacing: resolvedSpacing,
            snapping: snapping,
            rows: rows,
            rowHeight: rowHeight,
            content: content,
            viewportWidth: $viewportWidth,
            geometry: $geometry
        )
    }
}

// MARK: - Scroll content

/// The horizontal scroll view, geometry tracking, edge veil, and
/// accessibility scrolling for a ``CarouselRow``.
///
/// Extracted as its own `View` (instead of a computed property on
/// `CarouselRow`) so SwiftUI can diff and update it independently — a plain
/// `@ViewBuilder` property or method is always re-evaluated as part of its
/// owning view's `body` and never gets its own identity in the render tree.
struct CarouselRowScrollContent<Data, ID, Content>: View
where Data: RandomAccessCollection, ID: Hashable, Content: View {

    let items: Data
    let idKeyPath: KeyPath<Data.Element, ID>
    let sizing: CarouselItemSizing
    let spacing: CGFloat
    let snapping: CarouselSnapping
    let rows: Int
    let rowHeight: CGFloat?
    let content: (Data.Element) -> Content

    @Binding var viewportWidth: CGFloat
    @Binding var geometry: CarouselGeometry

    @Environment(\.designTheme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                CarouselRowLane(
                    items: items,
                    idKeyPath: idKeyPath,
                    rows: rows,
                    rowHeight: rowHeight,
                    spacing: spacing,
                    sizing: sizing,
                    viewportWidth: viewportWidth,
                    content: content
                )
                .scrollTargetLayout()
            }
            .modifier(CarouselScrollSnappingModifier(snapping: snapping))
            .contentMargins(.horizontal, spacing, for: .scrollContent)
            .background {
                GeometryReader { geometryProxy in
                    Color.clear.preference(
                        key: CarouselViewportWidthKey.self,
                        value: geometryProxy.size.width
                    )
                }
            }
            .onPreferenceChange(CarouselViewportWidthKey.self) { width in
                viewportWidth = width
            }
            .onScrollGeometryChange(for: CarouselGeometry.self) { scrollGeometry in
                CarouselGeometry(
                    offsetX: scrollGeometry.contentOffset.x,
                    contentWidth: scrollGeometry.contentSize.width,
                    viewportWidth: scrollGeometry.containerSize.width
                )
            } action: { _, new in
                geometry = new
            }
            .overlay {
                CarouselRowEdgeVeil(
                    geometry: geometry,
                    animation: veilAnimation,
                    troughColor: theme.colors.background,
                    bandWidth: theme.spacing.fourUnits
                )
            }
            .accessibilityElement(children: .contain)
            .accessibilityScrollAction { edge in
                stepScroll(edge: edge, proxy: proxy)
            }
        }
    }

    /// The animation used for the veil fade — a shorter ease under Reduce Motion.
    private var veilAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.15) : theme.motion.standardAnimation
    }

    /// Advances the row by one page of visible items in response to a VoiceOver
    /// scroll gesture, estimating the current position from the scroll offset.
    ///
    /// Not `private` so tests can drive it directly with a real
    /// `ScrollViewProxy` obtained from a hosted `ScrollViewReader`, without
    /// having to simulate an actual VoiceOver scroll gesture.
    func stepScroll(edge: Edge, proxy: ScrollViewProxy) {
        let direction = CarouselRowMath.accessibilityStep(for: edge, layoutDirection: layoutDirection)
        guard direction != 0 else { return }
        let ids = items.map { $0[keyPath: idKeyPath] }
        guard !ids.isEmpty else { return }

        let width = CarouselRowMath.itemWidth(
            viewportWidth: viewportWidth,
            sizing: sizing,
            spacing: spacing
        )
        let step = (width ?? viewportWidth) + spacing
        let current = step > 0 ? Int((geometry.offsetX / step).rounded()) : 0
        let stride = CarouselRowMath.pageStride(sizing: sizing)
        let target = CarouselRowMath.clampedIndex(current + direction * stride, count: ids.count)

        withAnimation(veilAnimation) {
            proxy.scrollTo(ids[target], anchor: .leading)
        }
    }
}

// MARK: - Scroll snapping

/// Applies the requested scroll-target behavior. `.free` leaves the row with
/// the platform's default momentum stop.
struct CarouselScrollSnappingModifier: ViewModifier {
    let snapping: CarouselSnapping

    func body(content: Content) -> some View {
        switch snapping {
        case .viewAligned:
            content.scrollTargetBehavior(.viewAligned)
        case .free:
            content
        }
    }
}

// MARK: - Lane

/// The scrollable content: a single `LazyHStack` lane, or a `LazyHGrid`
/// flowing items top-to-bottom across ``rows`` stacked rows. The grid needs
/// a bounded height, so it is only used when a `rowHeight` is supplied.
struct CarouselRowLane<Data, ID, ItemContent>: View
where Data: RandomAccessCollection, ID: Hashable, ItemContent: View {

    let items: Data
    let idKeyPath: KeyPath<Data.Element, ID>
    let rows: Int
    let rowHeight: CGFloat?
    let spacing: CGFloat
    let sizing: CarouselItemSizing
    let viewportWidth: CGFloat
    let content: (Data.Element) -> ItemContent

    private var itemWidth: CGFloat? {
        CarouselRowMath.itemWidth(
            viewportWidth: viewportWidth,
            sizing: sizing,
            spacing: spacing
        )
    }

    var body: some View {
        if rows > 1, let rowHeight {
            LazyHGrid(
                rows: Array(
                    repeating: GridItem(.fixed(rowHeight), spacing: spacing),
                    count: rows
                ),
                spacing: spacing
            ) {
                ForEach(items, id: idKeyPath) { element in
                    CarouselRowItem(
                        element: element,
                        idKeyPath: idKeyPath,
                        sizing: sizing,
                        itemWidth: itemWidth,
                        content: content
                    )
                }
            }
            .frame(height: rowHeight * CGFloat(rows) + spacing * CGFloat(rows - 1))
        } else {
            LazyHStack(spacing: spacing) {
                ForEach(items, id: idKeyPath) { element in
                    CarouselRowItem(
                        element: element,
                        idKeyPath: idKeyPath,
                        sizing: sizing,
                        itemWidth: itemWidth,
                        content: content
                    )
                }
            }
        }
    }
}

/// A single item, sized per ``CarouselItemSizing``. While the viewport is
/// unmeasured, a peeking item falls back to a container-relative frame so it
/// never collapses to zero width.
struct CarouselRowItem<Element, ID: Hashable, ItemContent: View>: View {

    let element: Element
    let idKeyPath: KeyPath<Element, ID>
    let sizing: CarouselItemSizing
    let itemWidth: CGFloat?
    let content: (Element) -> ItemContent

    var body: some View {
        Group {
            switch sizing.kind {
            case .fitContent:
                content(element)
            case .fixedWidth:
                content(element).frame(width: itemWidth ?? 0)
            case .peek:
                if let itemWidth {
                    content(element).frame(width: itemWidth)
                } else {
                    content(element).containerRelativeFrame(.horizontal)
                }
            }
        }
        .id(element[keyPath: idKeyPath])
    }
}

// MARK: - Edge veil

/// Two trough-colored gradient bands that veil the scrollable edges and fade
/// out once that end is reached. Decorative and non-interactive.
struct CarouselRowEdgeVeil: View {

    let geometry: CarouselGeometry
    let animation: Animation
    let troughColor: Color
    let bandWidth: CGFloat

    var body: some View {
        let edges = CarouselRowMath.edgeFade(
            contentOffsetX: geometry.offsetX,
            contentWidth: geometry.contentWidth,
            viewportWidth: geometry.viewportWidth
        )
        HStack(spacing: 0) {
            CarouselRowEdgeBand(visible: edges.leading, isLeading: true, troughColor: troughColor, width: bandWidth)
            Spacer(minLength: 0)
            CarouselRowEdgeBand(visible: edges.trailing, isLeading: false, troughColor: troughColor, width: bandWidth)
        }
        .allowsHitTesting(false)
        .animation(animation, value: edges.leading)
        .animation(animation, value: edges.trailing)
    }
}

/// A single edge-fade gradient band used by ``CarouselRowEdgeVeil``.
struct CarouselRowEdgeBand: View {

    let visible: Bool
    let isLeading: Bool
    let troughColor: Color
    let width: CGFloat

    var body: some View {
        let colors: [Color] =
            isLeading
            ? [troughColor, troughColor.opacity(0)]
            : [troughColor.opacity(0), troughColor]
        LinearGradient(
            colors: colors,
            startPoint: UnitPoint(x: 0, y: 0.5),
            endPoint: UnitPoint(x: 1, y: 0.5)
        )
        .frame(width: width)
        .opacity(visible ? 1 : 0)
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
