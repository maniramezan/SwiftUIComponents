import DesignSystem
import SwiftUI

/// A horizontally laid-out, single-selection picker that renders each segment
/// using a caller-supplied view builder.
///
/// The picker sizes itself to fit its segments when there is room and falls
/// back to a horizontally scrolling row when the segments overflow. In the
/// scrolling layout, the scrollable edges are veiled by a gradient that
/// matches the trough color, signalling that more segments exist off-screen;
/// the corresponding band fades away once the scroll reaches that end.
/// Selecting a segment auto-scrolls it into the center of the visible area.
///
/// ### Badging
/// Pass a `badge` closure to overlay a small indicator on individual segments.
/// Return a non-empty string for a labeled badge, an empty string (`""`) for a
/// plain dot, or `nil` for no badge:
///
/// ```swift
/// SegmentedPicker(items: Filter.allCases, selection: $filter) { item in
///     item == .inbox ? "3" : nil   // count badge on one segment
/// }
///
/// SegmentedPicker(items: Filter.allCases, selection: $filter) { item in
///     hasUpdates(item) ? "" : nil  // dot badge, no label
/// }
/// ```
///
/// ### Basic usage
/// ```swift
/// enum Filter: String, CaseIterable, MenuPickerItem {
///     case all, recent, favorites, archived
///     var id: String { rawValue }
///     var title: String { rawValue.capitalized }
/// }
///
/// @State private var filter: Filter = .all
///
/// SegmentedPicker(items: Filter.allCases, selection: $filter)
/// ```
public struct SegmentedPicker<Item: MenuPickerItem, Label: View>: View {

    // MARK: - Stored properties

    private let items: [Item]
    @Binding private var selection: Item
    private let badge: ((Item) -> String?)?
    private let label: (Item, Bool) -> Label
    private let isFullWidth: Bool

    @State private var geometry = ScrollGeometrySnapshot()

    @Environment(\.designTheme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    // MARK: - Initializers

    /// Creates a segmented picker with a custom label for each segment.
    ///
    /// - Parameters:
    ///   - items: The selectable items. Must be non-empty and must contain
    ///     `selection`.
    ///   - selection: Two-way binding to the currently selected item.
    ///   - isFullWidth: When `true`, each segment expands equally to fill the
    ///     available width instead of sizing to its content. Defaults to `false`.
    ///   - badge: Optional closure returning a badge string for an item.
    ///     Return a non-empty string for a labeled badge, `""` for a dot
    ///     indicator, or `nil` for no badge.
    ///   - label: A view builder invoked for every item. Receives the item and
    ///     a `Bool` indicating whether it is the active selection so the caller
    ///     may render an emphasized state if desired. The picker already flips
    ///     the foreground style and fades a primary-colored capsule behind the
    ///     active segment, so most callers should return the same label
    ///     regardless of the selected flag.
    public init(
        items: some RandomAccessCollection<Item>,
        selection: Binding<Item>,
        isFullWidth: Bool = false,
        badge: ((Item) -> String?)? = nil,
        @ViewBuilder label: @escaping (Item, Bool) -> Label
    ) {
        let items = Array(items)
        precondition(!items.isEmpty, "SegmentedPicker requires at least one item.")
        precondition(
            items.contains(where: { $0.id == selection.wrappedValue.id }),
            "selection must exist in items."
        )
        self.items = items
        self._selection = selection
        self.isFullWidth = isFullWidth
        self.badge = badge
        self.label = label
    }

    // MARK: - Body

    /// The SwiftUI body for the segmented picker.
    public var body: some View {
        ViewThatFits(in: .horizontal) {
            compactRow
            scrollingRow
        }
    }
}

// MARK: - Convenience text initializer

public extension SegmentedPicker where Label == Text {
    /// Creates a segmented picker that displays each item's ``MenuPickerItem/title``
    /// using the theme's `control` font. The title is rendered semibold when
    /// the segment is active.
    ///
    /// - Parameters:
    ///   - items: The selectable items. Must be non-empty and must contain
    ///     `selection`.
    ///   - selection: Two-way binding to the currently selected item.
    ///   - isFullWidth: When `true`, each segment expands equally to fill the
    ///     available width instead of sizing to its content. Defaults to `false`.
    ///   - badge: Optional closure returning a badge string for an item.
    ///     Return a non-empty string for a labeled badge, `""` for a dot
    ///     indicator, or `nil` for no badge.
    init(
        items: some RandomAccessCollection<Item>,
        selection: Binding<Item>,
        isFullWidth: Bool = false,
        badge: ((Item) -> String?)? = nil
    ) {
        self.init(items: items, selection: selection, isFullWidth: isFullWidth, badge: badge) { item, isActive in
            Text(item.title)
                .fontWeight(isActive ? .semibold : .regular)
        }
    }
}

// MARK: - Layout branches

private extension SegmentedPicker {

    var compactRow: some View {
        row
            .background(theme.colors.containerSecondary, in: Capsule(style: .continuous))
            .overlay { troughBorder }
    }

    var scrollingRow: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                row
                    .scrollTargetLayout()
            }
            .onScrollGeometryChange(for: ScrollGeometrySnapshot.self) { scroll in
                ScrollGeometrySnapshot(
                    offsetX: scroll.contentOffset.x,
                    contentWidth: scroll.contentSize.width,
                    viewportWidth: scroll.containerSize.width
                )
            } action: { _, new in
                geometry = new
            }
            .background(theme.colors.containerSecondary, in: Capsule(style: .continuous))
            .overlay { troughBorder }
            .overlay { edgeIndicators }
            .clipShape(Capsule(style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityScrollAction { edge in
                step(by: Self.accessibilityStep(for: edge, layoutDirection: layoutDirection))
            }
            .onChange(of: selection) { _, newValue in
                scrollTo(newValue, proxy: proxy)
            }
            .task {
                await Task.yield()
                scrollTo(selection, proxy: proxy)
            }
        }
    }

    var row: some View {
        HStack(spacing: theme.spacing.halfUnit) {
            ForEach(items) { item in
                segment(for: item)
            }
        }
        .padding(theme.spacing.halfUnit)
    }

    var troughBorder: some View {
        Capsule(style: .continuous)
            .strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
    }

    @ViewBuilder
    func segment(for item: Item) -> some View {
        let isActive = item.id == selection.id
        Button {
            withAnimation(activeAnimation) {
                selection = item
            }
        } label: {
            label(item, isActive)
                .font(theme.typography.control)
                .lineLimit(1)
                .fixedSize(horizontal: !isFullWidth, vertical: false)
                .frame(maxWidth: isFullWidth ? .infinity : nil)
                .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                .padding(.vertical, theme.spacing.oneUnit)
                .overlay(alignment: .topTrailing) {
                    segmentBadgeView(for: item)
                        .padding([.top, .trailing], theme.spacing.halfUnit)
                }
                .frame(minHeight: theme.motion.minimumHitTarget)
                .foregroundStyle(isActive ? theme.colors.onPrimary : theme.colors.textPrimary)
                .background {
                    Capsule(style: .continuous)
                        .fill(theme.colors.primary)
                        .opacity(isActive ? 1 : 0)
                }
                .animation(activeAnimation, value: isActive)
                .contentShape(Capsule(style: .continuous))
        }
        .buttonStyle(.plain)
        .id(item.id)
        .accessibilityAddTraits(isActive ? [.isSelected] : [])
        .accessibilityLabel(segmentAccessibilityLabel(for: item))
    }

    /// Badge view rendered at the top-trailing corner of a segment. Returns
    /// `EmptyView` when no badge is configured for the item.
    @ViewBuilder
    func segmentBadgeView(for item: Item) -> some View {
        if let text = badge?(item) {
            if text.isEmpty {
                Circle()
                    .fill(theme.colors.error)
                    .frame(width: theme.spacing.oneUnit, height: theme.spacing.oneUnit)
            } else {
                Text(text)
                    .font(theme.typography.badge)
                    .foregroundStyle(theme.colors.onError)
                    .padding(.horizontal, theme.spacing.halfUnit)
                    .padding(.vertical, 2)
                    .background(theme.colors.error, in: Capsule(style: .continuous))
                    .fixedSize()
            }
        }
    }

    /// Accessibility label that appends the badge value when present so
    /// VoiceOver reads e.g. "Inbox, 3" instead of just "Inbox".
    func segmentAccessibilityLabel(for item: Item) -> Text {
        guard let text = badge?(item), !text.isEmpty else {
            return Text(item.title)
        }
        return Text("\(item.title), \(text)")
    }
}

// MARK: - Edge indicators

private extension SegmentedPicker {

    var edgeIndicators: some View {
        let edges = Self.edgeFade(
            contentOffsetX: geometry.offsetX,
            contentWidth: geometry.contentWidth,
            viewportWidth: geometry.viewportWidth
        )
        return HStack(spacing: 0) {
            edgeBand(visible: edges.leading, isLeading: true)
            Spacer(minLength: 0)
            edgeBand(visible: edges.trailing, isLeading: false)
        }
        .allowsHitTesting(false)
        .animation(activeAnimation, value: edges.leading)
        .animation(activeAnimation, value: edges.trailing)
    }

    func edgeBand(visible: Bool, isLeading: Bool) -> some View {
        let trough = theme.colors.containerSecondary
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

    var activeAnimation: Animation {
        reduceMotion ? .easeInOut(duration: 0.15) : theme.motion.standardAnimation
    }

    /// Scrolls the picker to the given item, positioning it near the trailing
    /// edge so subsequent segments remain partially visible off-screen.
    /// The last item is centered instead since nothing follows it.
    func scrollTo(_ item: Item, proxy: ScrollViewProxy) {
        let isLast = item.id == items.last?.id
        let anchor: UnitPoint = isLast ? .center : .init(x: 0.75, y: 0.5)
        withAnimation(activeAnimation) {
            proxy.scrollTo(item.id, anchor: anchor)
        }
    }

    func step(by delta: Int) {
        guard delta != 0,
            let currentIndex = items.firstIndex(where: { $0.id == selection.id })
        else { return }
        let target = max(0, min(items.count - 1, currentIndex + delta))
        guard target != currentIndex else { return }
        withAnimation(activeAnimation) {
            selection = items[target]
        }
    }
}

// MARK: - Pure helpers

extension SegmentedPicker {

    /// Determines which scrollable edges should fade based on the current
    /// scroll geometry. Returns `(false, false)` whenever the content fits
    /// inside the viewport.
    ///
    /// - Parameters:
    ///   - contentOffsetX: The current horizontal content offset.
    ///   - contentWidth: The total scrollable content width.
    ///   - viewportWidth: The visible width of the scroll view.
    ///   - threshold: Slop, in points, used to ignore sub-pixel offsets that
    ///     could otherwise trigger a fade as soon as the user lifts a finger.
    /// - Returns: A pair of booleans indicating whether the leading and
    ///   trailing edges, respectively, should render an indicator band.
    nonisolated static func edgeFade(
        contentOffsetX: CGFloat,
        contentWidth: CGFloat,
        viewportWidth: CGFloat,
        threshold: CGFloat = 1
    ) -> (leading: Bool, trailing: Bool) {
        guard contentWidth > viewportWidth + threshold else { return (false, false) }
        let canScrollLeading = contentOffsetX > threshold
        let canScrollTrailing = contentOffsetX + viewportWidth < contentWidth - threshold
        return (canScrollLeading, canScrollTrailing)
    }

    /// Converts an accessibility scroll edge into a logical selection delta.
    /// Leading/trailing edges flip in right-to-left layouts so VoiceOver users
    /// always advance forward through the items.
    nonisolated static func accessibilityStep(
        for edge: Edge,
        layoutDirection: LayoutDirection
    ) -> Int {
        switch edge {
        case .leading:
            return layoutDirection == .rightToLeft ? +1 : -1
        case .trailing:
            return layoutDirection == .rightToLeft ? -1 : +1
        case .top:
            return -1
        case .bottom:
            return +1
        @unknown default:
            return +1
        }
    }
}

// MARK: - Private types

private struct ScrollGeometrySnapshot: Equatable {
    var offsetX: CGFloat = 0
    var contentWidth: CGFloat = 0
    var viewportWidth: CGFloat = 0
}

// MARK: - Preview

#Preview("Segmented Picker") {
    @Previewable @State var compactSelection: Int = 2
    @Previewable @State var overflowSelection: Int = 5
    @Previewable @State var fullWidthSelection: Int = 2

    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.threeUnits) {
            Text("Fits in the row")
                .designTextStyle(.headline)
            SegmentedPicker(items: 1...4, selection: $compactSelection)

            Text("Full width")
                .designTextStyle(.headline)
            SegmentedPicker(items: 1...4, selection: $fullWidthSelection, isFullWidth: true)

            Text("Scrolls horizontally")
                .designTextStyle(.headline)
            SegmentedPicker(items: 1...12, selection: $overflowSelection)
        }
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Segmented Picker — Badges") {
    @Previewable @State var selection: Int = 1

    let badgeCounts: [Int: String] = [2: "3", 4: "", 5: "99+"]

    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.threeUnits) {
            Text("Count badge, dot badge, no badge")
                .designTextStyle(.headline)
            SegmentedPicker(items: 1...6, selection: $selection) { item in
                badgeCounts[item]
            }
        }
        .padding(theme.spacing.twoUnits)
    }
}
