import DesignSystem
import SwiftUI

/// A horizontally scrolling row of items that reveals a sliver of the next item
/// to signal more content off-screen — the reusable building block behind a
/// ``CarouselBoard`` shelf, and usable on its own.
///
/// The row is **browse-only**: it holds no selection and reports nothing back.
/// Size its items with ``CarouselItemSizing`` (a peeking layout, a fixed width,
/// or intrinsic width) and control how it settles with ``CarouselSnapping``.
/// The scrollable edges are veiled by a gradient that fades away once that end
/// is reached, matching the affordance used by `SegmentedPicker`.
///
/// ```swift
/// // Peeking featured cards
/// CarouselRow(apps, sizing: .peek(visibleCount: 1)) { app in
///     FeaturedCard(app)
/// }
///
/// // Fixed-width tiles, free-scrolling
/// CarouselRow(icons, sizing: .fixedWidth(120), snapping: .free) { app in
///     IconTile(app)
/// }
/// ```
///
/// The row measures its own allocated width, so it lays out correctly in any
/// parent that gives it a finite width — a full-bleed column, a `List` row, or a
/// flexible `HStack` slot alongside fixed siblings. The only unsupported case is
/// a parent that proposes an *unbounded* width along the scroll axis (for
/// example, nesting it inside another horizontal `ScrollView`), where there is no
/// finite viewport to size against.
public struct CarouselRow<Data, ID, Content>: View
where Data: RandomAccessCollection, ID: Hashable, Content: View {

    // MARK: - Stored properties

    let items: Data
    let idKeyPath: KeyPath<Data.Element, ID>
    let sizing: CarouselItemSizing
    let explicitSpacing: CGFloat?
    let snapping: CarouselSnapping
    let rows: Int
    let rowHeight: CGFloat?
    let content: (Data.Element) -> Content

    @State var geometry = CarouselGeometry()
    @State var viewportWidth: CGFloat = 0

    @Environment(\.designTheme) var theme
    @Environment(\.layoutDirection) var layoutDirection
    @Environment(\.accessibilityReduceMotion) var reduceMotion

    // MARK: - Initializer

    /// Creates a carousel row over a collection keyed by an explicit key path.
    ///
    /// - Parameters:
    ///   - items: The items to display. An empty collection renders nothing.
    ///   - id: A key path to a stable, hashable identifier for each item.
    ///   - sizing: How each item is sized along the scroll axis. Defaults to
    ///     ``CarouselItemSizing/peek(visibleCount:peek:)`` with one visible item.
    ///   - spacing: The gap between items and the leading/trailing inset. When
    ///     `nil` (the default), the theme's `spacing.twoUnits` is used.
    ///   - snapping: How the row settles after a drag. Defaults to
    ///     ``CarouselSnapping/viewAligned``.
    ///   - rows: The number of stacked rows items flow into, filling
    ///     top-to-bottom before advancing horizontally. Values below `1` are
    ///     clamped to `1`. Defaults to a single row.
    ///   - rowHeight: The height of one row. Required when `rows` is greater
    ///     than `1` so the horizontal grid has a bounded height; ignored for a
    ///     single row, which sizes to its tallest item.
    ///   - content: A view builder invoked for each item.
    public init(
        _ items: Data,
        id: KeyPath<Data.Element, ID>,
        sizing: CarouselItemSizing = .peek(),
        spacing: CGFloat? = nil,
        snapping: CarouselSnapping = .viewAligned,
        rows: Int = 1,
        rowHeight: CGFloat? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.items = items
        self.idKeyPath = id
        self.sizing = sizing
        self.explicitSpacing = spacing
        self.snapping = snapping
        self.rows = max(1, rows)
        self.rowHeight = rowHeight
        self.content = content
    }

    // MARK: - Body

    /// The SwiftUI body for the carousel row.
    public var body: some View {
        if items.isEmpty {
            EmptyView()
        } else {
            scrollBody
        }
    }
}

// MARK: - Identifiable convenience

public extension CarouselRow where Data.Element: Identifiable, ID == Data.Element.ID {
    /// Creates a carousel row over a collection of `Identifiable` items, using
    /// each element's `id` automatically.
    ///
    /// - Parameters:
    ///   - items: The items to display. An empty collection renders nothing.
    ///   - sizing: How each item is sized along the scroll axis. Defaults to
    ///     ``CarouselItemSizing/peek(visibleCount:peek:)`` with one visible item.
    ///   - spacing: The gap between items and the leading/trailing inset. When
    ///     `nil` (the default), the theme's `spacing.twoUnits` is used.
    ///   - snapping: How the row settles after a drag. Defaults to
    ///     ``CarouselSnapping/viewAligned``.
    ///   - rows: The number of stacked rows items flow into. Defaults to `1`.
    ///   - rowHeight: The height of one row; required when `rows` > `1`.
    ///   - content: A view builder invoked for each item.
    init(
        _ items: Data,
        sizing: CarouselItemSizing = .peek(),
        spacing: CGFloat? = nil,
        snapping: CarouselSnapping = .viewAligned,
        rows: Int = 1,
        rowHeight: CGFloat? = nil,
        @ViewBuilder content: @escaping (Data.Element) -> Content
    ) {
        self.init(
            items,
            id: \.id,
            sizing: sizing,
            spacing: spacing,
            snapping: snapping,
            rows: rows,
            rowHeight: rowHeight,
            content: content
        )
    }
}

// MARK: - Scroll geometry snapshot

/// A snapshot of the row's scroll geometry, tracked via
/// `onScrollGeometryChange` to drive the edge-fade veil and accessibility
/// scrolling.
struct CarouselGeometry: Equatable {
    var offsetX: CGFloat = 0
    var contentWidth: CGFloat = 0
    var viewportWidth: CGFloat = 0
}

/// Preference key that reports the row's allocated width. Measuring the width
/// with a `GeometryReader` (rather than the scroll-geometry callback) yields a
/// correct item width on the very first layout pass and works in any parent
/// that allocates the row a finite width — including a flexible `HStack` slot.
struct CarouselViewportWidthKey: PreferenceKey {
    static var defaultValue: CGFloat { 0 }

    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}
