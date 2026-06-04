import SwiftUI

/// A single `List` cell that renders an expandable parent: a tappable label row with
/// its child rows revealed inline below it, as one continuously-resizing cell.
///
/// The cell conforms to `Animatable` and drives its own height from ``progress``
/// (`0` collapsed … `1` expanded). Because `progress` is the `animatableData`, SwiftUI
/// interpolates the cell's height on **every frame** of the transition, so the rows
/// below slide up or down in lockstep with the children fading and clipping away. This
/// avoids the abrupt "hide the children, then close the gap" jump that `List` row
/// removal (and `DisclosureGroup`) produce on collapse, where the content disappears
/// before the height finishes animating.
///
/// The children are always present in the hierarchy; the cell simply clips them to an
/// animating height (measured with `onGeometryChange`) rather than inserting or
/// removing rows, which is what keeps the collapse smooth.
struct ExpandableNodeRow<Label: View, Children: View>: View, Animatable {

    /// Disclosure progress, `0` (collapsed) through `1` (expanded). Interpolated by SwiftUI.
    var progress: CGFloat
    /// The always-visible parent label row.
    @ViewBuilder var label: Label
    /// The child rows revealed below the label as `progress` grows.
    @ViewBuilder var children: Children

    @State private var labelHeight: CGFloat = 0
    @State private var childrenHeight: CGFloat = 0

    /// Creates an expandable cell.
    /// - Parameters:
    ///   - progress: Disclosure progress from `0` (collapsed) to `1` (expanded).
    ///   - label: The always-visible parent label row.
    ///   - children: The child rows revealed inline as `progress` increases.
    init(
        progress: CGFloat,
        @ViewBuilder label: () -> Label,
        @ViewBuilder children: () -> Children
    ) {
        self.progress = progress
        self.label = label()
        self.children = children()
    }

    /// The interpolated disclosure progress that animates the cell height.
    ///
    /// `nonisolated` because `Animatable` is a non-isolated protocol requirement while
    /// `View` conformance is `@MainActor`; the backing `progress` is a `Sendable`
    /// `CGFloat`, so reading and writing it off the main actor is safe.
    nonisolated var animatableData: CGFloat {
        get { progress }
        set { progress = newValue }
    }

    /// The SwiftUI body for the expandable cell.
    var body: some View {
        label
            .onGeometryChange(for: CGFloat.self, of: { $0.size.height }, action: { labelHeight = $0 })
            .frame(maxWidth: .infinity, alignment: .leading)
            .overlay(alignment: .top) {
                children
                    // Adopt the children's natural stacked height instead of the
                    // smaller, animating height the overlay proposes — otherwise the
                    // measured height would track the clip and feed back into itself.
                    .fixedSize(horizontal: false, vertical: true)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .onGeometryChange(for: CGFloat.self, of: { $0.size.height }, action: { childrenHeight = $0 })
                    .opacity(progress)
                    .offset(y: labelHeight)
                    .allowsHitTesting(progress > 0.01)
                    .accessibilityHidden(progress <= 0.01)
            }
            .frame(height: labelHeight + childrenHeight * progress, alignment: .top)
            .clipped()
    }
}
