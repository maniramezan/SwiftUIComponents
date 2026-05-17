import SwiftUI
import Testing

@testable import Components
@testable import DesignSystem

// MARK: - Fixtures

private struct PagedFixturePage: Hashable, Identifiable {
    let id: Int
    let title: String
}

private func makePages(_ count: Int) -> [PagedFixturePage] {
    (0..<count).map { PagedFixturePage(id: $0, title: "Page \($0)") }
}

// MARK: - progress

@Test("progress is zero when viewport width is zero")
func progressIsZeroForUnmeasuredViewport() {
    let result = DesignPagedView<[PagedFixturePage], Int, EmptyView>.progress(
        contentOffsetX: 250,
        viewportWidth: 0
    )
    #expect(result == 0)
}

@Test("progress equals offset divided by viewport width")
func progressDividesOffsetByViewport() {
    let result = DesignPagedView<[PagedFixturePage], Int, EmptyView>.progress(
        contentOffsetX: 400,
        viewportWidth: 200
    )
    #expect(result == 2.0)
}

// MARK: - stepIndex

@Test("stepIndex returns starting index when count is zero")
func stepIndexHandlesEmptyCollection() {
    let result = DesignPagedView<[PagedFixturePage], Int, EmptyView>.stepIndex(
        by: 3,
        from: 0,
        count: 0
    )
    #expect(result == 0)
}

@Test("stepIndex clamps to upper bound")
func stepIndexClampsAtUpperBound() {
    let result = DesignPagedView<[PagedFixturePage], Int, EmptyView>.stepIndex(
        by: +5,
        from: 4,
        count: 5
    )
    #expect(result == 4)
}

@Test("stepIndex clamps to lower bound")
func stepIndexClampsAtLowerBound() {
    let result = DesignPagedView<[PagedFixturePage], Int, EmptyView>.stepIndex(
        by: -5,
        from: 0,
        count: 5
    )
    #expect(result == 0)
}

@Test("stepIndex advances by signed delta")
func stepIndexAdvancesBySignedDelta() {
    let plus = DesignPagedView<[PagedFixturePage], Int, EmptyView>.stepIndex(by: +1, from: 1, count: 5)
    let minus = DesignPagedView<[PagedFixturePage], Int, EmptyView>.stepIndex(by: -1, from: 1, count: 5)
    #expect(plus == 2)
    #expect(minus == 0)
}

// MARK: - shouldShowIndicator

@Test("shouldShowIndicator is false for the hidden style regardless of count")
func shouldShowIndicatorHiddenAlwaysFalse() {
    #expect(
        DesignPagedView<[PagedFixturePage], Int, EmptyView>.shouldShowIndicator(
            count: 5,
            style: .hidden
        ) == false
    )
    #expect(
        DesignPagedView<[PagedFixturePage], Int, EmptyView>.shouldShowIndicator(
            count: 0,
            style: .hidden
        ) == false
    )
}

@Test("shouldShowIndicator is false when there is only a single page")
func shouldShowIndicatorHidesForSinglePage() {
    #expect(
        DesignPagedView<[PagedFixturePage], Int, EmptyView>.shouldShowIndicator(
            count: 1,
            style: .dots
        ) == false
    )
    #expect(
        DesignPagedView<[PagedFixturePage], Int, EmptyView>.shouldShowIndicator(
            count: 1,
            style: .bar
        ) == false
    )
}

@Test("shouldShowIndicator is true for multiple pages with a visible style")
func shouldShowIndicatorShowsForMultiplePages() {
    #expect(
        DesignPagedView<[PagedFixturePage], Int, EmptyView>.shouldShowIndicator(
            count: 4,
            style: .dots
        ) == true
    )
    #expect(
        DesignPagedView<[PagedFixturePage], Int, EmptyView>.shouldShowIndicator(
            count: 4,
            style: .bar
        ) == true
    )
}

// MARK: - DesignPaginationMath.slotWidth / slotStride / leadingPadding

@Test("Bidirectional layout leaves room for two peeks and two gaps")
func bidirectionalSlotWidthAndStride() {
    let width = DesignPaginationMath.slotWidth(viewportWidth: 400, peek: 40, gap: 16, direction: .bidirectional)
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 40, gap: 16, direction: .bidirectional)
    let padding = DesignPaginationMath.headerLeadingPadding(peek: 40, gap: 16, direction: .bidirectional)
    // 400 − 2×40 − 2×16 = 288
    #expect(width == 288)
    // 288 + 16 = 304
    #expect(stride == 304)
    // leading padding = peek + gap = 56
    #expect(padding == 56)
}

@Test("Unidirectional layout reserves a single peek plus gap on the trailing edge")
func unidirectionalSlotWidthAndStride() {
    let width = DesignPaginationMath.slotWidth(viewportWidth: 400, peek: 40, gap: 16, direction: .unidirectional)
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 40, gap: 16, direction: .unidirectional)
    let padding = DesignPaginationMath.headerLeadingPadding(peek: 40, gap: 16, direction: .unidirectional)
    // 400 − 40 − 16 = 344
    #expect(width == 344)
    // 344 + 16 = 360
    #expect(stride == 360)
    // unidirectional has no leading padding — slot 0 starts at the leading edge
    #expect(padding == 0)
}

@Test("None peek mode fills the viewport with each slot and uses no gap")
func noneSlotWidthAndStride() {
    let width = DesignPaginationMath.slotWidth(viewportWidth: 400, peek: 0, gap: 0, direction: .none)
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 0, gap: 0, direction: .none)
    let padding = DesignPaginationMath.headerLeadingPadding(peek: 0, gap: 0, direction: .none)
    #expect(width == 400)
    #expect(stride == 400)
    #expect(padding == 0)
}

@Test("slotWidth clamps to zero when the viewport is too small for the peek and gap")
func slotWidthClampsToZeroForTinyViewport() {
    let width = DesignPaginationMath.slotWidth(viewportWidth: 50, peek: 40, gap: 16, direction: .bidirectional)
    #expect(width == 0)
}

// MARK: - DesignPaginationMath.headerOffset

@Test("Header offset is zero at progress zero for every peek mode")
func headerOffsetZeroAtZeroProgress() {
    for direction in DesignPaginationPeekDirection.allCases {
        let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 40, gap: 16, direction: direction)
        let offset = DesignPaginationMath.headerOffset(progress: 0, stride: stride, layoutSign: 1)
        #expect(offset == 0, "expected 0 offset at progress=0 for \(direction)")
    }
}

@Test("Bidirectional header offset at progress one equals negative stride in LTR")
func bidirectionalFullProgressInLTR() {
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 40, gap: 16, direction: .bidirectional)
    let offset = DesignPaginationMath.headerOffset(progress: 1, stride: stride, layoutSign: 1)
    #expect(offset == -304)
}

@Test("Unidirectional header offset at progress one equals negative stride in LTR")
func unidirectionalFullProgressInLTR() {
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 40, gap: 16, direction: .unidirectional)
    let offset = DesignPaginationMath.headerOffset(progress: 1, stride: stride, layoutSign: 1)
    #expect(offset == -360)
}

@Test("None header offset at progress one equals negative viewport width")
func noneFullProgressInLTR() {
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 0, gap: 0, direction: .none)
    let offset = DesignPaginationMath.headerOffset(progress: 1, stride: stride, layoutSign: 1)
    #expect(offset == -400)
}

@Test("RTL flips the sign of the header offset")
func rtlFlipsHeaderOffset() {
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 40, gap: 16, direction: .bidirectional)
    let ltr = DesignPaginationMath.headerOffset(progress: 1, stride: stride, layoutSign: 1)
    let rtl = DesignPaginationMath.headerOffset(progress: 1, stride: stride, layoutSign: -1)
    #expect(ltr == -304)
    #expect(rtl == 304)
}

@Test("Header offset is linear in progress")
func headerOffsetLinearInProgress() {
    let stride = DesignPaginationMath.slotStride(viewportWidth: 400, peek: 40, gap: 16, direction: .bidirectional)
    let offsets: [(CGFloat, CGFloat)] = [
        (0.0, 0),
        (0.25, -76),
        (0.5, -152),
        (0.75, -228),
        (1.0, -304),
    ]
    for (progress, expected) in offsets {
        let value = DesignPaginationMath.headerOffset(progress: progress, stride: stride, layoutSign: 1)
        #expect(abs(value - expected) < 0.0001, "progress=\(progress) → \(value), expected \(expected)")
    }
}

// MARK: - DesignPaginationMath.effectivePeek

@Test("Effective peek collapses to zero under Reduce Motion when crossfade is enabled")
func effectivePeekCollapsesUnderReduceMotion() {
    let value = DesignPaginationMath.effectivePeek(
        configured: 40,
        direction: .bidirectional,
        reduceMotion: true,
        usesCrossfade: true
    )
    #expect(value == 0)
}

@Test("Effective peek is preserved when Reduce Motion is off")
func effectivePeekPreservedWithoutReduceMotion() {
    let value = DesignPaginationMath.effectivePeek(
        configured: 40,
        direction: .bidirectional,
        reduceMotion: false,
        usesCrossfade: true
    )
    #expect(value == 40)
}

@Test("Effective peek respects the .none direction regardless of configuration")
func effectivePeekIsZeroForNoneDirection() {
    let value = DesignPaginationMath.effectivePeek(
        configured: 40,
        direction: .none,
        reduceMotion: false,
        usesCrossfade: true
    )
    #expect(value == 0)
}

@Test("Effective peek preserves configured value under Reduce Motion when crossfade is opted out")
func effectivePeekHonorsCrossfadeOptOut() {
    let value = DesignPaginationMath.effectivePeek(
        configured: 40,
        direction: .bidirectional,
        reduceMotion: true,
        usesCrossfade: false
    )
    #expect(value == 40)
}

// MARK: - resolveStyle

@Test("resolveStyle falls back to theme tokens when overrides are nil")
@MainActor
func resolveStyleFallsBackToTheme() {
    let theme = DefaultDesignTheme()
    let resolved = DesignPagedView<[PagedFixturePage], Int, EmptyView>.resolveStyle(
        override: DesignPaginationStyle(),
        theme: theme
    )
    #expect(resolved.peekDirection == .unidirectional)
    #expect(resolved.peekWidth == theme.spacing.fiveUnits)
    #expect(resolved.headerSpacing == theme.spacing.twoUnits)
    #expect(resolved.titleGap == theme.spacing.twoUnits)
    #expect(resolved.reduceMotionUsesCrossfade == true)
}

@Test("resolveStyle prefers explicit overrides over theme tokens")
@MainActor
func resolveStylePrefersOverrides() {
    let theme = DefaultDesignTheme()
    var override = DesignPaginationStyle()
    override.peekDirection = .unidirectional
    override.peekWidth = 12
    override.headerSpacing = 7
    override.titleGap = 5
    override.reduceMotionUsesCrossfade = false

    let resolved = DesignPagedView<[PagedFixturePage], Int, EmptyView>.resolveStyle(
        override: override,
        theme: theme
    )
    #expect(resolved.peekDirection == .unidirectional)
    #expect(resolved.peekWidth == 12)
    #expect(resolved.headerSpacing == 7)
    #expect(resolved.titleGap == 5)
    #expect(resolved.reduceMotionUsesCrossfade == false)
}

// MARK: - API construction smoke tests

@Test("DesignPagedView is constructible with a KeyPath-based id")
@MainActor
func designPagedViewConstructibleWithKeyPathID() {
    let pages = makePages(3)
    var selected = pages[0].id
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = DesignPagedView(
        pages,
        selection: binding,
        id: \PagedFixturePage.id,
        title: \PagedFixturePage.title,
        indicatorStyle: .dots
    ) { page in
        Text(page.title)
    }
}

@Test("DesignPagedView Identifiable convenience initializer compiles and runs")
@MainActor
func designPagedViewConstructibleWithIdentifiableConvenience() {
    let pages = makePages(4)
    var selected = pages[1].id
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = DesignPagedView(
        pages,
        selection: binding,
        title: \PagedFixturePage.title
    ) { page in
        Text(page.title)
    }
}

@Test("DesignPagedView accepts the bar and hidden indicator styles")
@MainActor
func designPagedViewAcceptsAllIndicatorStyles() {
    let pages = makePages(2)
    var selected = pages[0].id
    let binding = Binding(get: { selected }, set: { selected = $0 })
    _ = DesignPagedView(pages, selection: binding, title: \PagedFixturePage.title, indicatorStyle: .bar) { p in
        Text(p.title)
    }
    _ = DesignPagedView(pages, selection: binding, title: \PagedFixturePage.title, indicatorStyle: .hidden) { p in
        Text(p.title)
    }
}

@Test("designPaginationStyle modifier returns a configured view")
@MainActor
func designPaginationStyleModifierApplies() {
    var style = DesignPaginationStyle()
    style.peekDirection = .unidirectional
    style.indicatorActiveColor = .orange

    let view = Color.clear.designPaginationStyle(style)
    _ = view  // smoke: must compile and produce a valid View
}
