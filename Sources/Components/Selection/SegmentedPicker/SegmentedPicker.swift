import DesignSystem
import SwiftUI

/// Controls how a ``SegmentedPicker`` sizes its segments along the horizontal axis.
public enum SegmentSizing {
    /// Each segment sizes to fit its content (default).
    case fit
    /// All segments expand to an equal width, together filling the available space.
    case fillEqually
    /// Segments fill the available width while remaining proportional to their intrinsic content sizes.
    case fillProportionally
}

/// Controls the vertical density (height) of a ``SegmentedPicker``.
public enum SegmentDensity {
    /// Standard height with a 44pt minimum tap target (default).
    case regular
    /// Reduced height (~32pt), matching the platform's native segmented control.
    /// The tap target shrinks with the control, so prefer ``regular`` where a
    /// generous tap area matters.
    case compact
}

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
    private let sizing: SegmentSizing
    private let density: SegmentDensity

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
    ///   - sizing: Controls how segments are sized along the horizontal axis.
    ///     See ``SegmentSizing`` for available options. Defaults to `.fit`.
    ///   - density: Controls the vertical height of the segments. See
    ///     ``SegmentDensity``. Defaults to `.regular`.
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
        sizing: SegmentSizing = .fit,
        density: SegmentDensity = .regular,
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
        self.sizing = sizing
        self.density = density
        self.badge = badge
        self.label = label
    }

    // MARK: - Body

    /// The SwiftUI body for the segmented picker.
    public var body: some View {
        ViewThatFits(in: .horizontal) {
            SegmentedPickerCompactRow(
                items: items, selection: $selection, badge: badge, label: label, sizing: sizing, density: density)
            SegmentedPickerScrollingRow(
                items: items, selection: $selection, badge: badge, label: label, sizing: sizing, density: density)
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
    ///   - sizing: Controls how segments are sized along the horizontal axis.
    ///     See ``SegmentSizing`` for available options. Defaults to `.fit`.
    ///   - density: Controls the vertical height of the segments. See
    ///     ``SegmentDensity``. Defaults to `.regular`.
    ///   - badge: Optional closure returning a badge string for an item.
    ///     Return a non-empty string for a labeled badge, `""` for a dot
    ///     indicator, or `nil` for no badge.
    init(
        items: some RandomAccessCollection<Item>,
        selection: Binding<Item>,
        sizing: SegmentSizing = .fit,
        density: SegmentDensity = .regular,
        badge: ((Item) -> String?)? = nil
    ) {
        self.init(
            items: items,
            selection: selection,
            sizing: sizing,
            density: density,
            badge: badge
        ) { item, isActive in
            Text(item.title)
                .fontWeight(isActive ? .semibold : .regular)
        }
    }
}

// MARK: - Layout branches

/// The non-scrolling layout used when all segments fit the available width:
/// the shared row over a themed capsule background and trough border.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the scrolling variant.
private struct SegmentedPickerCompactRow<Item: MenuPickerItem, Label: View>: View {
    let items: [Item]
    @Binding var selection: Item
    let badge: ((Item) -> String?)?
    let label: (Item, Bool) -> Label
    let sizing: SegmentSizing
    let density: SegmentDensity

    @Environment(\.designTheme) private var theme

    var body: some View {
        SegmentedPickerRow(
            items: items,
            selection: $selection,
            badge: badge,
            label: label,
            sizing: sizing,
            density: density
        )
        .background(theme.colors.segmentUnselectedBackground, in: Capsule(style: .continuous))
        .overlay { SegmentedPickerTroughBorder() }
    }
}

/// The horizontally-scrolling layout used when segments overflow the
/// available width: the shared row inside a `ScrollView`, with geometry
/// tracking for the edge veil, auto-scroll-to-selection, and accessibility
/// scrolling.
///
/// A dedicated `View` type — rather than an inline `@ViewBuilder` property —
/// so SwiftUI can diff and update it independently of the compact variant.
struct SegmentedPickerScrollingRow<Item: MenuPickerItem, Label: View>: View {
    let items: [Item]
    @Binding var selection: Item
    let badge: ((Item) -> String?)?
    let label: (Item, Bool) -> Label
    let sizing: SegmentSizing
    let density: SegmentDensity

    @State private var geometry = ScrollGeometrySnapshot()

    @Environment(\.designTheme) private var theme
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView(.horizontal, showsIndicators: false) {
                SegmentedPickerRow(
                    items: items,
                    selection: $selection,
                    badge: badge,
                    label: label,
                    sizing: sizing,
                    density: density
                )
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
            .background(theme.colors.segmentUnselectedBackground, in: Capsule(style: .continuous))
            .overlay { SegmentedPickerTroughBorder() }
            .scrollEdgeVeil(
                geometry: geometry,
                animation: activeAnimation,
                troughColor: theme.colors.segmentUnselectedBackground,
                bandWidth: theme.spacing.fourUnits
            )
            .clipShape(Capsule(style: .continuous))
            .accessibilityElement(children: .contain)
            .accessibilityScrollAction { edge in
                step(by: SegmentedPicker<Item, Label>.accessibilityStep(for: edge, layoutDirection: layoutDirection))
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

    private var activeAnimation: Animation {
        theme.motion.animation(reducingMotion: reduceMotion)
    }

    /// Scrolls the picker to the given item, positioning it near the trailing
    /// edge so subsequent segments remain partially visible off-screen.
    /// The last item is centered instead since nothing follows it.
    private func scrollTo(_ item: Item, proxy: ScrollViewProxy) {
        let isLast = item.id == items.last?.id
        let anchor: UnitPoint = isLast ? .center : .init(x: 0.75, y: 0.5)
        withAnimation(activeAnimation) {
            proxy.scrollTo(item.id, anchor: anchor)
        }
    }

    /// Not `private` so tests can drive it directly without simulating a
    /// real VoiceOver accessibility scroll gesture.
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

/// The shared row of segment buttons, used by both the compact and scrolling
/// layouts.
private struct SegmentedPickerRow<Item: MenuPickerItem, Label: View>: View {
    let items: [Item]
    @Binding var selection: Item
    let badge: ((Item) -> String?)?
    let label: (Item, Bool) -> Label
    let sizing: SegmentSizing
    let density: SegmentDensity

    @Environment(\.designTheme) private var theme

    var body: some View {
        HStack(spacing: theme.spacing.halfUnit) {
            ForEach(items) { item in
                SegmentedPickerSegment(
                    item: item,
                    selection: $selection,
                    badge: badge,
                    label: label,
                    sizing: sizing,
                    density: density
                )
            }
        }
        .padding(theme.spacing.halfUnit)
    }
}

/// The capsule stroke drawn around both the compact and scrolling layouts.
private struct SegmentedPickerTroughBorder: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        Capsule(style: .continuous)
            .strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
    }
}

/// A single tappable segment, with its active-state capsule background and
/// optional badge overlay.
private struct SegmentedPickerSegment<Item: MenuPickerItem, Label: View>: View {
    let item: Item
    @Binding var selection: Item
    let badge: ((Item) -> String?)?
    let label: (Item, Bool) -> Label
    let sizing: SegmentSizing
    let density: SegmentDensity

    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    private var isActive: Bool { item.id == selection.id }

    private var activeAnimation: Animation {
        theme.motion.animation(reducingMotion: reduceMotion)
    }

    var body: some View {
        Button {
            withAnimation(activeAnimation) {
                selection = item
            }
        } label: {
            label(item, isActive)
                .font(theme.typography.control)
                .lineLimit(1)
                .fixedSize(horizontal: sizing == .fit, vertical: false)
                .frame(maxWidth: sizing == .fillEqually ? .infinity : nil)
                .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                .padding(.vertical, density == .compact ? theme.spacing.halfUnit : theme.spacing.oneUnit)
                .overlay(alignment: .topTrailing) {
                    SegmentedPickerBadge(text: badge?(item))
                        .padding([.top, .trailing], theme.spacing.halfUnit)
                }
                .frame(minHeight: density == .compact ? theme.spacing.fourUnits : theme.motion.minimumHitTarget)
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
        .accessibilityLabel(accessibilityLabel)
    }

    /// Accessibility label that appends the badge value when present so
    /// VoiceOver reads e.g. "Inbox, 3" instead of just "Inbox".
    private var accessibilityLabel: Text {
        guard let text = badge?(item), !text.isEmpty else {
            return Text(item.title)
        }
        return Text("\(item.title), \(text)")
    }
}

/// Badge shown at the top-trailing corner of a segment: a labeled capsule
/// for non-empty text, a plain dot for empty text, or nothing for `nil`.
private struct SegmentedPickerBadge: View {
    let text: String?

    @Environment(\.designTheme) private var theme

    var body: some View {
        if let text {
            if text.isEmpty {
                Circle()
                    .fill(theme.colors.error)
                    .frame(width: theme.spacing.oneUnit, height: theme.spacing.oneUnit)
            } else {
                Text(text)
                    .font(theme.typography.badge)
                    .foregroundStyle(theme.colors.onError)
                    .padding(.horizontal, theme.spacing.halfUnit)
                    .padding(.vertical, theme.spacing.halfUnit / 2)
                    .background(theme.colors.error, in: Capsule(style: .continuous))
                    .fixedSize()
            }
        }
    }
}

// MARK: - Pure helpers

/// Pure geometry/accessibility math shared by ``SegmentedPicker``'s scrolling
/// layout. Kept in a non-generic namespace so decorative subviews can call it
/// without needing to know `SegmentedPicker`'s `Item`/`Label` generic
/// parameters.
enum SegmentedPickerMath {

    /// Determines which scrollable edges should fade based on the current
    /// scroll geometry. Returns `(false, false)` whenever the content fits
    /// inside the viewport.
    ///
    /// Delegates to the shared ``ScrollLayoutMath`` so every scrollable
    /// component resolves edge fades identically.
    static func edgeFade(
        contentOffsetX: CGFloat,
        contentWidth: CGFloat,
        viewportWidth: CGFloat,
        threshold: CGFloat = 1
    ) -> (leading: Bool, trailing: Bool) {
        ScrollLayoutMath.edgeFade(
            contentOffsetX: contentOffsetX,
            contentWidth: contentWidth,
            viewportWidth: viewportWidth,
            threshold: threshold
        )
    }

    /// Converts an accessibility scroll edge into a logical selection delta.
    /// Leading/trailing edges flip in right-to-left layouts so VoiceOver users
    /// always advance forward through the items.
    ///
    /// Delegates to the shared ``ScrollLayoutMath``.
    static func accessibilityStep(
        for edge: Edge,
        layoutDirection: LayoutDirection
    ) -> Int {
        ScrollLayoutMath.accessibilityStep(for: edge, layoutDirection: layoutDirection)
    }
}

extension SegmentedPicker {

    /// See ``SegmentedPickerMath/edgeFade(contentOffsetX:contentWidth:viewportWidth:threshold:)``.
    nonisolated static func edgeFade(
        contentOffsetX: CGFloat,
        contentWidth: CGFloat,
        viewportWidth: CGFloat,
        threshold: CGFloat = 1
    ) -> (leading: Bool, trailing: Bool) {
        SegmentedPickerMath.edgeFade(
            contentOffsetX: contentOffsetX,
            contentWidth: contentWidth,
            viewportWidth: viewportWidth,
            threshold: threshold
        )
    }

    /// See ``SegmentedPickerMath/accessibilityStep(for:layoutDirection:)``.
    nonisolated static func accessibilityStep(
        for edge: Edge,
        layoutDirection: LayoutDirection
    ) -> Int {
        SegmentedPickerMath.accessibilityStep(for: edge, layoutDirection: layoutDirection)
    }
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

            Text("Fill equally")
                .designTextStyle(.headline)
            SegmentedPicker(items: 1...4, selection: $fullWidthSelection, sizing: .fillEqually)

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
