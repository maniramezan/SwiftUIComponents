import SwiftUI

enum FloatingActionButtonLayoutMath {
    struct Frames: Equatable {
        let trigger: CGRect
        let actions: CGRect
    }

    nonisolated static func frames(
        container: CGSize,
        trigger: CGSize,
        direction: FloatingActionButtonDirection,
        layoutDirection: LayoutDirection,
        gap: CGFloat
    ) -> Frames {
        let width = max(0, container.width)
        let height = max(0, container.height)
        let triggerWidth = max(0, trigger.width)
        let triggerHeight = max(0, trigger.height)
        let isRightToLeft = layoutDirection == .rightToLeft
        let trailingX = isRightToLeft ? 0 : max(0, width - triggerWidth)
        let centeredY = max(0, (height - triggerHeight) / 2)
        let verticalSpace = max(0, height - triggerHeight - gap)
        let horizontalSpace = max(0, width - triggerWidth - gap)

        switch direction {
        case .up:
            return Frames(
                trigger: CGRect(
                    x: trailingX, y: max(0, height - triggerHeight),
                    width: triggerWidth, height: triggerHeight),
                actions: CGRect(x: 0, y: 0, width: width, height: verticalSpace)
            )
        case .down:
            return Frames(
                trigger: CGRect(x: trailingX, y: 0, width: triggerWidth, height: triggerHeight),
                actions: CGRect(x: 0, y: min(height, triggerHeight + gap), width: width, height: verticalSpace)
            )
        case .leading, .trailing:
            let expandsLeft = (direction == .leading) != isRightToLeft
            return Frames(
                trigger: CGRect(
                    x: expandsLeft ? max(0, width - triggerWidth) : 0, y: centeredY,
                    width: triggerWidth, height: triggerHeight),
                actions: CGRect(
                    x: expandsLeft ? 0 : min(width, triggerWidth + gap), y: 0,
                    width: horizontalSpace, height: height)
            )
        }
    }

    nonisolated static func concealedOffset(
        direction: FloatingActionButtonDirection,
        layoutDirection: LayoutDirection,
        distance: CGFloat,
        reducingMotion: Bool = false
    ) -> CGSize {
        guard !reducingMotion else { return .zero }
        switch direction {
        case .up: return CGSize(width: 0, height: distance)
        case .down: return CGSize(width: 0, height: -distance)
        case .leading: return CGSize(width: layoutDirection == .rightToLeft ? -distance : distance, height: 0)
        case .trailing: return CGSize(width: layoutDirection == .rightToLeft ? distance : -distance, height: 0)
        }
    }
}

struct FloatingActionButtonLayout: Layout {
    let direction: FloatingActionButtonDirection
    let layoutDirection: LayoutDirection
    let gap: CGFloat

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let trigger = subviews[0].sizeThatFits(.unspecified)
        let actions = subviews[1].sizeThatFits(.unspecified)
        let ideal = CGSize(
            width: direction.isHorizontal ? trigger.width + gap + actions.width : max(trigger.width, actions.width),
            height: direction.isHorizontal ? max(trigger.height, actions.height) : trigger.height + gap + actions.height
        )
        return proposal.replacingUnspecifiedDimensions(by: ideal)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let frames = FloatingActionButtonLayoutMath.frames(
            container: bounds.size,
            trigger: subviews[0].sizeThatFits(.unspecified),
            direction: direction,
            layoutDirection: layoutDirection,
            gap: gap
        )
        for (subview, frame) in zip(subviews, [frames.trigger, frames.actions]) {
            let placementX = layoutDirection == .rightToLeft ? bounds.width - frame.maxX : frame.minX
            subview.place(
                at: CGPoint(x: bounds.minX + placementX, y: bounds.minY + frame.minY),
                anchor: .topLeading,
                proposal: ProposedViewSize(frame.size)
            )
        }
    }
}

enum FloatingActionButtonInteraction {
    @MainActor
    static func toggle(isExpanded: Binding<Bool>, hasItems: Bool, isEnabled: Bool) {
        guard isEnabled, hasItems else { return }
        isExpanded.wrappedValue.toggle()
    }

    @MainActor
    static func select<Item>(
        _ item: Item,
        isExpanded: Binding<Bool>,
        isEnabled: Bool,
        collapsesOnSelection: Bool,
        onSelect: (Item) -> Void
    ) {
        guard isEnabled, isExpanded.wrappedValue else { return }
        if collapsesOnSelection {
            isExpanded.wrappedValue = false
        }
        onSelect(item)
    }
}
