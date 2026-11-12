import DesignSystem
import OSLog
import SwiftUI

/// An anchored floating action button that reveals a scrollable strip of labeled actions.
///
/// Use a finite frame to define the presentation area, normally inside an overlay.
/// The trigger remains at the opposite end of the expansion direction: bottom
/// trailing for `.up`, top trailing for `.down`, and centered vertically for
/// horizontal expansion. The first item is nearest the trigger. Leading and
/// trailing mirror with the layout direction. Empty items log a fault and render
/// a disabled, collapsed trigger.
///
/// ```swift
/// ExpandableFloatingActionButton(
///     items: actions, isExpanded: $isExpanded, onSelect: performAction
/// ) { expanded in
///     Label("Actions", systemImage: expanded ? "xmark" : "plus")
/// } itemLabel: { item in
///     Label(item.title, systemImage: item.symbol)
/// }
/// .frame(width: 280, height: 320)
/// ```
public struct ExpandableFloatingActionButton<Item: Identifiable, TriggerLabel: View, ItemLabel: View>: View {
    private let items: [Item]
    @Binding private var isExpanded: Bool
    private let direction: FloatingActionButtonDirection
    private let showsTitle: Bool
    private let collapsesOnSelection: Bool
    private let isItemDisabled: (Item) -> Bool
    private let onSelect: (Item) -> Void
    private let collapsedLabel: TriggerLabel
    private let expandedLabel: TriggerLabel
    private let itemLabel: (Item) -> ItemLabel
    @FocusState private var isTriggerFocused: Bool
    @Environment(\.designTheme) private var theme
    @Environment(\.isEnabled) private var isEnabled
    @Environment(\.layoutDirection) private var layoutDirection
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates an expandable floating action button using caller-owned item identities.
    ///
    /// - Parameters:
    ///   - items: Actions with unique, stable identities, ordered nearest the trigger first.
    ///   - isExpanded: Two-way expansion state. Empty items reset this binding to `false`.
    ///   - direction: Expansion direction. Defaults to `.up`.
    ///   - showsTitle: Whether the trigger shows its title in an extended capsule.
    ///   - collapsesOnSelection: Whether to collapse before invoking `onSelect`. Defaults to `true`.
    ///   - isItemDisabled: Returns whether an item is disabled. Defaults to all items enabled.
    ///   - onSelect: Invoked once when an enabled action is activated while expanded.
    ///   - label: Trigger content for collapsed and expanded states, normally a SwiftUI
    ///     `Label`. Both states are measured together to keep the trigger's dimensions stable.
    ///   - itemLabel: Icon-and-text content for each action, normally a SwiftUI `Label`.
    ///     All caller-supplied content is rendered verbatim and must already be localized.
    public init(
        items: [Item],
        isExpanded: Binding<Bool>,
        direction: FloatingActionButtonDirection = .up,
        showsTitle: Bool = false,
        collapsesOnSelection: Bool = true,
        isItemDisabled: @escaping (Item) -> Bool = { _ in false },
        onSelect: @escaping (Item) -> Void,
        @ViewBuilder label: (Bool) -> TriggerLabel,
        @ViewBuilder itemLabel: @escaping (Item) -> ItemLabel
    ) {
        self.items = items
        self._isExpanded = isExpanded
        self.direction = direction
        self.showsTitle = showsTitle
        self.collapsesOnSelection = collapsesOnSelection
        self.isItemDisabled = isItemDisabled
        self.onSelect = onSelect
        self.collapsedLabel = label(false)
        self.expandedLabel = label(true)
        self.itemLabel = itemLabel
    }

    /// The stationary trigger and independently scrollable action strip.
    public var body: some View {
        let expanded = isExpanded && !items.isEmpty
        let offset = FloatingActionButtonLayoutMath.concealedOffset(
            direction: direction, layoutDirection: layoutDirection, distance: theme.spacing.oneUnit,
            reducingMotion: reduceMotion
        )
        FloatingActionButtonLayout(
            direction: direction, layoutDirection: layoutDirection, gap: theme.spacing.oneUnit
        ) {
            FloatingActionButton(showsTitle: showsTitle) {
                FloatingActionButtonInteraction.toggle(
                    isExpanded: $isExpanded, hasItems: !items.isEmpty, isEnabled: isEnabled
                )
                if isExpanded {
                    isTriggerFocused = true
                }
            } label: {
                ZStack {
                    collapsedLabel
                        .opacity(expanded ? 0 : 1)
                        .accessibilityHidden(expanded)
                    expandedLabel
                        .opacity(expanded ? 1 : 0)
                        .accessibilityHidden(!expanded)
                }
            }
            .disabled(items.isEmpty)
            .focusable()
            .focused($isTriggerFocused)
            .accessibilityValue(Text(expanded ? Strings.FloatingAction.expanded : Strings.FloatingAction.collapsed))
            .layoutPriority(1)
            .zIndex(1)

            FloatingActionStrip(
                items: items,
                direction: direction,
                isItemDisabled: isItemDisabled,
                onSelect: { item in
                    FloatingActionButtonInteraction.select(
                        item,
                        isExpanded: $isExpanded,
                        isEnabled: isEnabled && !isItemDisabled(item),
                        collapsesOnSelection: collapsesOnSelection,
                        onSelect: onSelect
                    )
                },
                itemLabel: itemLabel
            )
            .opacity(expanded ? 1 : 0)
            .offset(expanded ? .zero : offset)
            .allowsHitTesting(expanded && isEnabled)
            .accessibilityHidden(!expanded || !isEnabled)
            .disabled(!expanded)
        }
        .animation(theme.motion.animation(reducingMotion: reduceMotion), value: expanded)
        .accessibilityElement(children: .contain)
        .accessibilityAction(.escape) { isExpanded = false }
        .onKeyPress(.escape) {
            guard expanded else { return .ignored }
            isExpanded = false
            return .handled
        }
        #if os(macOS)
            .onExitCommand { isExpanded = false }
        #endif
        .onChange(of: items.isEmpty, initial: true) { _, isEmpty in
            if isEmpty {
                Logger(subsystem: "com.swiftuicomponents", category: "FloatingActionButton")
                    .fault("ExpandableFloatingActionButton received no items; disabling the trigger.")
                isExpanded = false
            }
        }
        .onChange(of: isExpanded) { _, value in
            if value && items.isEmpty {
                isExpanded = false
            }
        }
    }
}

private struct FloatingActionStrip<Item: Identifiable, ItemLabel: View>: View {
    let items: [Item]
    let direction: FloatingActionButtonDirection
    let isItemDisabled: (Item) -> Bool
    let onSelect: (Item) -> Void
    let itemLabel: (Item) -> ItemLabel
    @Environment(\.layoutDirection) private var layoutDirection
    @State private var scrollGeometry = ScrollGeometrySnapshot()

    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { proxy in
                ScrollView(direction.isHorizontal ? .horizontal : .vertical) {
                    FloatingActionItems(
                        items: items, direction: direction, viewport: geometry.size,
                        isItemDisabled: isItemDisabled, onSelect: onSelect, itemLabel: itemLabel
                    )
                }
                .scrollIndicators(.hidden)
                .defaultScrollAnchor(direction.scrollAnchor)
                .onScrollGeometryChange(for: ScrollGeometrySnapshot.self) { value in
                    ScrollGeometrySnapshot(
                        offsetX: value.contentOffset.x + value.contentInsets.leading,
                        contentWidth: value.contentSize.width,
                        viewportWidth: value.containerSize.width
                    )
                } action: { _, value in
                    scrollGeometry = value
                }
                .modifier(FloatingActionScrollVeil(isHorizontal: direction.isHorizontal, geometry: scrollGeometry))
                .onChange(of: direction) {
                    if let first = items.first {
                        proxy.scrollTo(first.id, anchor: direction.scrollAnchor)
                    }
                }
                .onChange(of: layoutDirection) {
                    if let first = items.first {
                        proxy.scrollTo(first.id, anchor: direction.scrollAnchor)
                    }
                }
            }
        }
    }
}

private struct FloatingActionItems<Item: Identifiable, ItemLabel: View>: View {
    let items: [Item]
    let direction: FloatingActionButtonDirection
    let viewport: CGSize
    let isItemDisabled: (Item) -> Bool
    let onSelect: (Item) -> Void
    let itemLabel: (Item) -> ItemLabel
    @Environment(\.designTheme) private var theme

    var body: some View {
        let orderedItems = direction.reversesItems ? Array(items.reversed()) : items
        let layout =
            direction.isHorizontal
            ? AnyLayout(HStackLayout(spacing: theme.spacing.oneUnit))
            : AnyLayout(VStackLayout(alignment: .trailing, spacing: theme.spacing.oneUnit))
        layout {
            ForEach(orderedItems) { item in
                Button {
                    onSelect(item)
                } label: {
                    itemLabel(item)
                        .labelStyle(.titleAndIcon)
                        .font(theme.typography.subheadlineMedium)
                        .designPillMetrics()
                        .fixedSize(horizontal: false, vertical: true)
                        .designCapsuleSurface()
                        .frame(maxWidth: viewport.width, alignment: .trailing)
                }
                .buttonStyle(FloatingActionPressStyle())
                .disabled(isItemDisabled(item))
                .id(item.id)
                .accessibilitySortPriority(Double(items.count - (items.firstIndex { $0.id == item.id } ?? 0)))
            }
        }
        .frame(
            minWidth: direction.isHorizontal ? nil : viewport.width,
            minHeight: direction.isHorizontal ? viewport.height : nil,
            alignment: .trailing
        )
    }
}

private struct FloatingActionScrollVeil: ViewModifier {
    let isHorizontal: Bool
    let geometry: ScrollGeometrySnapshot
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    func body(content: Content) -> some View {
        content.scrollEdgeVeil(
            geometry: isHorizontal ? geometry : ScrollGeometrySnapshot(),
            animation: theme.motion.animation(reducingMotion: reduceMotion),
            troughColor: theme.colors.background,
            bandWidth: theme.spacing.twoUnits
        )
    }
}

#Preview("Expandable floating action button") {
    PreviewContent { theme in
        ExpandableFloatingActionButton(
            items: FloatingActionPreviewItem.allCases, isExpanded: .constant(true), onSelect: { _ in }
        ) { expanded in
            Label("Actions", systemImage: expanded ? "xmark" : "plus")
        } itemLabel: { item in
            Label(item.rawValue, systemImage: "star")
        }
        .frame(width: 280, height: 280)
        .padding(theme.spacing.twoUnits)
    }
}

private enum FloatingActionPreviewItem: String, CaseIterable, Identifiable {
    case first = "First action"
    case second = "Second action"
    case third = "Third action"

    var id: Self { self }
}
