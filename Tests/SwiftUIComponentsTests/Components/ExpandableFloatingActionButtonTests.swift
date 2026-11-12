import DesignSystem
import SwiftUI
import TestCommonsUI
import Testing

@testable import Components

#if os(macOS)
    import AppKit
#endif

@Suite("Floating action layout geometry")
struct FloatingActionButtonGeometryTests {
    @Test("vertical strips reserve the trigger and gap", arguments: [FloatingActionButtonDirection.up, .down])
    func verticalFrames(direction: FloatingActionButtonDirection) {
        let frames = FloatingActionButtonLayoutMath.frames(
            container: CGSize(width: 300, height: 240), trigger: CGSize(width: 48, height: 48),
            direction: direction, layoutDirection: .leftToRight, gap: 8
        )
        #expect(frames.trigger.minX == 252)
        #expect(frames.trigger.minY == (direction == .up ? 192 : 0))
        #expect(frames.actions == CGRect(x: 0, y: direction == .up ? 0 : 56, width: 300, height: 184))
        #expect(!frames.trigger.intersects(frames.actions))
    }

    @Test("horizontal directions mirror their physical expansion", arguments: [false, true])
    func horizontalFrames(rightToLeft: Bool) {
        let layoutDirection: LayoutDirection = rightToLeft ? .rightToLeft : .leftToRight
        let leading = FloatingActionButtonLayoutMath.frames(
            container: CGSize(width: 300, height: 120), trigger: CGSize(width: 48, height: 48),
            direction: .leading, layoutDirection: layoutDirection, gap: 8
        )
        let trailing = FloatingActionButtonLayoutMath.frames(
            container: CGSize(width: 300, height: 120), trigger: CGSize(width: 48, height: 48),
            direction: .trailing, layoutDirection: layoutDirection, gap: 8
        )
        #expect(leading.trigger == CGRect(x: rightToLeft ? 0 : 252, y: 36, width: 48, height: 48))
        #expect(trailing.trigger == CGRect(x: rightToLeft ? 252 : 0, y: 36, width: 48, height: 48))
        #expect(leading.actions == CGRect(x: rightToLeft ? 56 : 0, y: 0, width: 244, height: 120))
        #expect(trailing.actions == CGRect(x: rightToLeft ? 0 : 56, y: 0, width: 244, height: 120))
    }

    @Test("vertical triggers use the logical trailing edge in right-to-left layouts")
    func verticalRightToLeft() {
        let frames = FloatingActionButtonLayoutMath.frames(
            container: CGSize(width: 300, height: 240), trigger: CGSize(width: 48, height: 48),
            direction: .up, layoutDirection: .rightToLeft, gap: 8
        )
        #expect(frames.trigger.minX == 0)
    }

    @Test(
        "insufficient presentation space never produces a negative viewport",
        arguments: FloatingActionButtonDirection.allCases)
    func insufficientSpace(direction: FloatingActionButtonDirection) {
        let frames = FloatingActionButtonLayoutMath.frames(
            container: CGSize(width: 20, height: 20), trigger: CGSize(width: 48, height: 48),
            direction: direction, layoutDirection: .leftToRight, gap: 8
        )
        #expect(frames.actions.width >= 0)
        #expect(frames.actions.height >= 0)
        #expect(direction.isHorizontal ? frames.actions.width == 0 : frames.actions.height == 0)
    }

    @Test("concealed offsets point back toward the trigger")
    func concealedOffsets() {
        #expect(offset(.up) == CGSize(width: 0, height: 8))
        #expect(offset(.down) == CGSize(width: 0, height: -8))
        #expect(offset(.leading) == CGSize(width: 8, height: 0))
        #expect(offset(.trailing) == CGSize(width: -8, height: 0))
        #expect(offset(.leading, .rightToLeft) == CGSize(width: -8, height: 0))
        #expect(offset(.trailing, .rightToLeft) == CGSize(width: 8, height: 0))
    }

    @Test("Reduce Motion removes translation in every direction", arguments: FloatingActionButtonDirection.allCases)
    func reducedMotionOffsets(direction: FloatingActionButtonDirection) {
        #expect(
            FloatingActionButtonLayoutMath.concealedOffset(
                direction: direction, layoutDirection: .leftToRight, distance: 8, reducingMotion: true
            ) == .zero
        )
    }

    @Test("item ordering and initial scroll anchors start nearest the trigger")
    func directionMetadata() {
        #expect(FloatingActionButtonDirection.up.reversesItems)
        #expect(FloatingActionButtonDirection.leading.reversesItems)
        #expect(!FloatingActionButtonDirection.down.reversesItems)
        #expect(!FloatingActionButtonDirection.trailing.reversesItems)
        #expect(FloatingActionButtonDirection.up.scrollAnchor == .bottomTrailing)
        #expect(FloatingActionButtonDirection.down.scrollAnchor == .topTrailing)
        #expect(FloatingActionButtonDirection.leading.scrollAnchor == .trailing)
        #expect(FloatingActionButtonDirection.trailing.scrollAnchor == .leading)
    }

    private func offset(
        _ direction: FloatingActionButtonDirection,
        _ layoutDirection: LayoutDirection = .leftToRight
    ) -> CGSize {
        FloatingActionButtonLayoutMath.concealedOffset(
            direction: direction, layoutDirection: layoutDirection, distance: 8
        )
    }
}

@MainActor
@Suite("Floating action interactions")
struct FloatingActionButtonInteractionTests {
    @Test("repeated activation reverses expansion immediately")
    func toggleExpansion() {
        let state = FloatingActionTestState()
        let binding = Binding(get: { state.expanded }, set: { state.expanded = $0 })
        for _ in 0..<5 {
            FloatingActionButtonInteraction.toggle(isExpanded: binding, hasItems: true, isEnabled: true)
        }
        #expect(state.expanded)
        FloatingActionButtonInteraction.toggle(isExpanded: binding, hasItems: true, isEnabled: true)
        #expect(!state.expanded)
    }

    @Test("empty and disabled triggers cannot toggle")
    func disabledToggle() {
        let state = FloatingActionTestState()
        let binding = Binding(get: { state.expanded }, set: { state.expanded = $0 })
        FloatingActionButtonInteraction.toggle(isExpanded: binding, hasItems: false, isEnabled: true)
        FloatingActionButtonInteraction.toggle(isExpanded: binding, hasItems: true, isEnabled: false)
        #expect(!state.expanded)
    }

    @Test("selection invokes once and applies collapse before the callback", arguments: [false, true])
    func selectionPolicy(collapses: Bool) {
        let state = FloatingActionTestState()
        state.expanded = true
        let binding = Binding(get: { state.expanded }, set: { state.expanded = $0 })
        var calls = 0
        FloatingActionButtonInteraction.select(
            7, isExpanded: binding, isEnabled: true, collapsesOnSelection: collapses
        ) { selected in
            #expect(selected == 7)
            #expect(state.expanded == !collapses)
            calls += 1
        }
        #expect(calls == 1)
    }

    @Test("disabled or collapsed actions cannot dispatch callbacks")
    func preventsHiddenSelection() {
        let state = FloatingActionTestState()
        let binding = Binding(get: { state.expanded }, set: { state.expanded = $0 })
        var calls = 0
        FloatingActionButtonInteraction.select(
            0, isExpanded: binding, isEnabled: true, collapsesOnSelection: true
        ) { _ in calls += 1 }
        state.expanded = true
        FloatingActionButtonInteraction.select(
            0, isExpanded: binding, isEnabled: false, collapsesOnSelection: true
        ) { _ in calls += 1 }
        #expect(calls == 0)
        #expect(state.expanded)
    }
}

@MainActor
@Suite("Expandable floating action rendering", .serialized)
struct ExpandableFloatingActionButtonTests {
    @Test(
        "all directions render expanded and collapsed", arguments: FloatingActionButtonDirection.allCases,
        [false, true])
    func rendersDirections(direction: FloatingActionButtonDirection, expanded: Bool) {
        let state = FloatingActionTestState()
        state.direction = direction
        state.expanded = expanded
        renderForCoverage(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
        state.showsTitle = true
        renderForCoverage(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
    }

    @Test("overflowing long labels render in both layout directions", arguments: [false, true])
    func rendersOverflow(rightToLeft: Bool) {
        let state = FloatingActionTestState()
        state.expanded = true
        state.direction = .leading
        state.rightToLeft = rightToLeft
        state.items = (0..<8).map {
            FloatingActionTestItem(id: $0, title: "Action \($0) with a long descriptive label")
        }
        renderForCoverage(
            FloatingActionTestView(state: state)
                .dynamicTypeSize(.accessibility2)
                .preferredColorScheme(.dark),
            size: CGSize(width: 300, height: 240)
        )
    }

    @Test("an empty list resets expansion on installation and after external writes")
    func emptyItemsCollapse() {
        let state = FloatingActionTestState()
        state.expanded = true
        state.items = []
        let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
        defer { host.close() }
        _ = host.waitForStableRender()
        #expect(!state.expanded)
        state.expanded = true
        _ = host.waitForStableRender()
        #expect(!state.expanded)
    }

    @Test("hosted views respond to external binding, direction, and item changes")
    func externalChanges() throws {
        let state = FloatingActionTestState()
        state.showsTitle = true
        let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
        defer { host.close() }
        _ = host.waitForStableRender()
        let collapsed = try #require(host.renderPNG())
        let appearances = state.itemAppearances
        state.expanded = true
        _ = host.waitForStableRender()
        #expect(host.renderPNG() != collapsed)
        state.direction = .trailing
        state.items = Array(state.items.reversed())
        _ = host.waitForStableRender()
        #expect(host.renderPNG() != collapsed)
        #expect(state.itemAppearances == appearances)
        state.items = []
        _ = host.waitForStableRender()
        #expect(!state.expanded)
    }

    @Test(
        "overflow initially reveals the nearest action in either layout language",
        arguments: FloatingActionButtonDirection.allCases, [false, true])
    func firstActionVisible(direction: FloatingActionButtonDirection, rightToLeft: Bool) throws {
        let state = FloatingActionTestState()
        state.expanded = true
        state.direction = direction
        state.rightToLeft = rightToLeft
        state.items = (0..<8).map { FloatingActionTestItem(id: $0, title: "Action \($0)") }
        let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
        defer { host.close() }
        _ = host.waitForStableRender()
        let first = try #require(state.itemFrames[0])
        #expect(CGRect(x: 0, y: 0, width: 300, height: 240).contains(first))
        state.rightToLeft.toggle()
        _ = host.waitForStableRender()
        let mirroredFirst = try #require(state.itemFrames[0])
        #expect(CGRect(x: 0, y: 0, width: 300, height: 240).contains(mirroredFirst))
    }

    @Test(
        "rendered custom layouts mirror exactly once", arguments: FloatingActionButtonDirection.allCases, [false, true])
    func renderedPlacement(direction: FloatingActionButtonDirection, rightToLeft: Bool) {
        let state = FloatingActionTestState()
        let layoutDirection: LayoutDirection = rightToLeft ? .rightToLeft : .leftToRight
        let view = FloatingActionButtonLayout(direction: direction, layoutDirection: layoutDirection, gap: 8) {
            Color.clear
                .frame(width: 48, height: 48)
                .onGeometryChange(for: CGRect.self) { geometry in
                    geometry.frame(in: .named("presentation"))
                } action: {
                    state.triggerFrame = $0
                }
            Color.clear
        }
        .coordinateSpace(name: "presentation")
        .environment(\.layoutDirection, layoutDirection)
        let host = HostedView(view, size: CGSize(width: 300, height: 240))
        defer { host.close() }
        _ = host.waitForStableRender()
        let expected = FloatingActionButtonLayoutMath.frames(
            container: CGSize(width: 300, height: 240), trigger: CGSize(width: 48, height: 48),
            direction: direction, layoutDirection: layoutDirection, gap: 8
        )
        #expect(state.triggerFrame == expected.trigger)
    }

    #if os(macOS)
        @Test(
            "overflow can scroll to the final action", arguments: FloatingActionButtonDirection.allCases, [false, true])
        func scrollsToLastAction(direction: FloatingActionButtonDirection, rightToLeft: Bool) throws {
            let state = FloatingActionTestState()
            state.expanded = true
            state.direction = direction
            state.rightToLeft = rightToLeft
            state.items = (0..<8).map { FloatingActionTestItem(id: $0, title: "Action \($0)") }
            let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
            defer { host.close() }
            _ = host.waitForStableRender()
            let scroll = try #require(scrollViews(in: host.hosting).first)
            let document = try #require(scroll.documentView)
            let initial = scroll.contentView.bounds.origin
            let horizontalEnd = max(0, document.bounds.width - scroll.contentView.bounds.width)
            let verticalEnd = max(0, document.bounds.height - scroll.contentView.bounds.height)
            let destination =
                direction.isHorizontal
                ? CGPoint(x: initial.x < horizontalEnd / 2 ? horizontalEnd : 0, y: initial.y)
                : CGPoint(x: initial.x, y: initial.y < verticalEnd / 2 ? verticalEnd : 0)
            scroll.contentView.scroll(to: destination)
            scroll.reflectScrolledClipView(scroll.contentView)
            _ = host.waitForStableRender()
            let last = try #require(state.itemFrames[7])
            #expect(CGRect(x: 0, y: 0, width: 300, height: 240).contains(last))
        }

        @Test("real button clicks toggle and select while hidden actions cannot activate")
        func pointerInteraction() throws {
            let state = FloatingActionTestState()
            let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
            defer { host.close() }
            _ = host.waitForStableRender()
            try click(host, at: CGPoint(x: 276, y: 24))
            _ = host.waitForStableRender()
            #expect(state.expanded)
            try click(host, at: CGPoint(x: 250, y: 78))
            _ = host.waitForStableRender()
            #expect(state.selections == [0])
            #expect(!state.expanded)
            try click(host, at: CGPoint(x: 250, y: 78))
            #expect(state.selections == [0])
        }

        @Test("disabled actions and a disabled component ignore clicks")
        func disabledPointerInteraction() throws {
            let state = FloatingActionTestState()
            state.expanded = true
            state.firstItemDisabled = true
            let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
            defer { host.close() }
            _ = host.waitForStableRender()
            try click(host, at: CGPoint(x: 250, y: 78))
            #expect(state.selections.isEmpty)
            state.disabled = true
            _ = host.waitForStableRender()
            try click(host, at: CGPoint(x: 276, y: 24))
            #expect(state.expanded)
        }

        @Test("rapid trigger clicks reverse an animation without queued state changes")
        func rapidPointerInteraction() throws {
            let state = FloatingActionTestState()
            let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
            defer { host.close() }
            _ = host.waitForStableRender()
            for _ in 0..<5 {
                try click(host, at: CGPoint(x: 276, y: 24))
                RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.01))
            }
            _ = host.waitForStableRender()
            #expect(state.expanded)
            #expect(state.selections.isEmpty)
        }

        @Test("keyboard Escape dismisses the expanded action strip")
        func keyboardEscape() throws {
            let state = FloatingActionTestState()
            let host = HostedView(FloatingActionTestView(state: state), size: CGSize(width: 300, height: 240))
            defer { host.close() }
            host.window.makeKeyAndOrderFront(nil)
            _ = host.waitForStableRender()
            try click(host, at: CGPoint(x: 276, y: 24))
            _ = host.waitForStableRender()
            #expect(state.expanded)
            let event = try #require(
                NSEvent.keyEvent(
                    with: .keyDown, location: .zero, modifierFlags: [],
                    timestamp: ProcessInfo.processInfo.systemUptime,
                    windowNumber: host.window.windowNumber, context: nil,
                    characters: "\u{1b}", charactersIgnoringModifiers: "\u{1b}",
                    isARepeat: false, keyCode: 53
                )
            )
            host.window.sendEvent(event)
            _ = host.waitForStableRender()
            #expect(!state.expanded)
        }

        private func click<Content: View>(_ host: HostedView<Content>, at point: CGPoint) throws {
            for type in [NSEvent.EventType.leftMouseDown, .leftMouseUp] {
                let event = try #require(
                    NSEvent.mouseEvent(
                        with: type, location: point, modifierFlags: [],
                        timestamp: ProcessInfo.processInfo.systemUptime,
                        windowNumber: host.window.windowNumber, context: nil,
                        eventNumber: 0, clickCount: 1, pressure: type == .leftMouseDown ? 1 : 0
                    )
                )
                host.window.sendEvent(event)
            }
        }

        private func scrollViews(in view: NSView) -> [NSScrollView] {
            (view as? NSScrollView).map { [$0] } ?? view.subviews.flatMap { scrollViews(in: $0) }
        }
    #endif
}

private struct FloatingActionTestItem: Identifiable {
    let id: Int
    let title: String
}

@MainActor
@Observable
private final class FloatingActionTestState {
    var expanded = false
    var direction = FloatingActionButtonDirection.up
    var disabled = false
    var firstItemDisabled = false
    var showsTitle = false
    var triggerFrame = CGRect.zero
    var rightToLeft = false
    var itemFrames: [Int: CGRect] = [:]
    var itemAppearances: [Int: Int] = [:]
    var selections: [Int] = []
    var items = [
        FloatingActionTestItem(id: 0, title: "First action"),
        FloatingActionTestItem(id: 1, title: "Second action"),
        FloatingActionTestItem(id: 2, title: "Third action"),
    ]
}

private struct FloatingActionTestView: View {
    @Bindable var state: FloatingActionTestState

    var body: some View {
        ExpandableFloatingActionButton(
            items: state.items,
            isExpanded: $state.expanded,
            direction: state.direction,
            showsTitle: state.showsTitle,
            isItemDisabled: { state.firstItemDisabled && $0.id == 0 },
            onSelect: { state.selections.append($0.id) }
        ) { expanded in
            Label(expanded ? "Actions" : "More actions", systemImage: expanded ? "xmark" : "plus")
        } itemLabel: { item in
            Label(item.title, systemImage: "star")
                .onGeometryChange(for: CGRect.self) { geometry in
                    geometry.frame(in: .named("fabActions"))
                } action: {
                    state.itemFrames[item.id] = $0
                }
                .onAppear { state.itemAppearances[item.id, default: 0] += 1 }
        }
        .coordinateSpace(name: "fabActions")
        .environment(\.layoutDirection, state.rightToLeft ? .rightToLeft : .leftToRight)
        .disabled(state.disabled)
    }
}
