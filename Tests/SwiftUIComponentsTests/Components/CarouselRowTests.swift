import SwiftUI
import Testing

@testable import Components

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

// MARK: - itemWidth

@Test("itemWidth reserves the peek sliver and one spacing gap per visible item")
func itemWidthPeekReservesPeekAndSpacing() {
    let width = CarouselRowMath.itemWidth(
        viewportWidth: 390,
        sizing: .peek(visibleCount: 1, peek: 32),
        spacing: 16
    )
    // 390 - 32 (peek) - 16 (one gap) = 342
    #expect(width == 342)
}

@Test("itemWidth shrinks as more items become visible")
func itemWidthShrinksWithMoreVisibleItems() {
    let one = CarouselRowMath.itemWidth(viewportWidth: 390, sizing: .peek(visibleCount: 1), spacing: 16)
    let two = CarouselRowMath.itemWidth(viewportWidth: 390, sizing: .peek(visibleCount: 2), spacing: 16)
    let three = CarouselRowMath.itemWidth(viewportWidth: 390, sizing: .peek(visibleCount: 3), spacing: 16)
    #expect(one != nil && two != nil && three != nil)
    #expect(one! > two!)
    #expect(two! > three!)
}

@Test("itemWidth returns nil for a peeking row before the viewport is measured")
func itemWidthPeekUnmeasuredIsNil() {
    let width = CarouselRowMath.itemWidth(viewportWidth: 0, sizing: .peek(visibleCount: 1), spacing: 16)
    #expect(width == nil)
}

@Test("itemWidth returns the fixed width regardless of viewport")
func itemWidthFixedIsConstant() {
    #expect(CarouselRowMath.itemWidth(viewportWidth: 0, sizing: .fixedWidth(120), spacing: 16) == 120)
    #expect(CarouselRowMath.itemWidth(viewportWidth: 800, sizing: .fixedWidth(120), spacing: 16) == 120)
}

@Test("itemWidth returns nil for intrinsic sizing")
func itemWidthFitContentIsNil() {
    #expect(CarouselRowMath.itemWidth(viewportWidth: 390, sizing: .fitContent, spacing: 16) == nil)
}

@Test("peek clamps a visible count below one up to one")
func peekClampsVisibleCount() {
    let clamped = CarouselRowMath.itemWidth(viewportWidth: 390, sizing: .peek(visibleCount: 0), spacing: 16)
    let one = CarouselRowMath.itemWidth(viewportWidth: 390, sizing: .peek(visibleCount: 1), spacing: 16)
    #expect(clamped == one)
}

// MARK: - edgeFade

@Test("edgeFade reports no fade when content fits")
func edgeFadeNoneWhenFits() {
    let edges = CarouselRowMath.edgeFade(contentOffsetX: 0, contentWidth: 200, viewportWidth: 300)
    #expect(edges.leading == false)
    #expect(edges.trailing == false)
}

@Test("edgeFade fades only the trailing edge at the start")
func edgeFadeTrailingOnlyAtStart() {
    let edges = CarouselRowMath.edgeFade(contentOffsetX: 0, contentWidth: 600, viewportWidth: 300)
    #expect(edges.leading == false)
    #expect(edges.trailing == true)
}

@Test("edgeFade fades only the leading edge at the end")
func edgeFadeLeadingOnlyAtEnd() {
    let edges = CarouselRowMath.edgeFade(contentOffsetX: 300, contentWidth: 600, viewportWidth: 300)
    #expect(edges.leading == true)
    #expect(edges.trailing == false)
}

@Test("edgeFade fades both edges in the middle")
func edgeFadeBothInMiddle() {
    let edges = CarouselRowMath.edgeFade(contentOffsetX: 150, contentWidth: 600, viewportWidth: 300)
    #expect(edges.leading == true)
    #expect(edges.trailing == true)
}

// MARK: - accessibilityStep

@Test("accessibilityStep advances forward on the trailing edge in LTR")
func accessibilityStepTrailingLTR() {
    #expect(CarouselRowMath.accessibilityStep(for: .trailing, layoutDirection: .leftToRight) == 1)
    #expect(CarouselRowMath.accessibilityStep(for: .leading, layoutDirection: .leftToRight) == -1)
}

@Test("accessibilityStep flips leading and trailing under RTL")
func accessibilityStepFlipsRTL() {
    #expect(CarouselRowMath.accessibilityStep(for: .trailing, layoutDirection: .rightToLeft) == -1)
    #expect(CarouselRowMath.accessibilityStep(for: .leading, layoutDirection: .rightToLeft) == 1)
}

// MARK: - clampedIndex & pageStride

@Test("clampedIndex constrains to the valid range")
func clampedIndexConstrains() {
    #expect(CarouselRowMath.clampedIndex(-3, count: 5) == 0)
    #expect(CarouselRowMath.clampedIndex(10, count: 5) == 4)
    #expect(CarouselRowMath.clampedIndex(2, count: 5) == 2)
    #expect(CarouselRowMath.clampedIndex(0, count: 0) == 0)
}

@Test("pageStride matches the visible count for peeking rows and one otherwise")
func pageStrideMatchesSizing() {
    #expect(CarouselRowMath.pageStride(sizing: .peek(visibleCount: 3)) == 3)
    #expect(CarouselRowMath.pageStride(sizing: .fixedWidth(120)) == 1)
    #expect(CarouselRowMath.pageStride(sizing: .fitContent) == 1)
}

// MARK: - Construction

@MainActor
@Test("CarouselRow builds via both initializers")
func carouselRowConstruction() {
    _ = CarouselRow(1...5, id: \.self) { Text("\($0)") }
    _ = CarouselRow(CarouselTestItem.samples) { Text($0.title) }
    _ = CarouselRow([Int](), id: \.self) { Text("\($0)") }  // empty → EmptyView path
}

// MARK: - Rendering (rows / rowHeight)

@MainActor
@Test("CarouselRow with a single row renders the LazyHStack lane")
func carouselRowSingleRowRendersLane() {
    render(CarouselRow(1...6, id: \.self) { value in Text("\(value)") })
}

@MainActor
@Test("CarouselRow with rows and rowHeight renders a bounded LazyHGrid lane")
func carouselRowMultiRowRendersGridLane() {
    render(
        CarouselRow(1...6, id: \.self, rows: 2, rowHeight: 80) { value in
            Text("\(value)")
        }
    )
}

// MARK: - Fixtures

/// A minimal identifiable fixture reused across carousel tests.
struct CarouselTestItem: Identifiable, Hashable {
    let id: Int
    let title: String

    static let samples: [CarouselTestItem] = [
        CarouselTestItem(id: 1, title: "One"),
        CarouselTestItem(id: 2, title: "Two"),
        CarouselTestItem(id: 3, title: "Three"),
    ]
}

// MARK: - Helpers

/// Hosts `view` in a real platform view hierarchy and forces layout, so
/// container closures (e.g. `ScrollViewReader`, `GeometryReader`) actually run
/// instead of merely being stored for later.
@MainActor
private func render<V: View>(_ view: V, size: CGSize = CGSize(width: 320, height: 200)) {
    #if canImport(UIKit)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
    #elseif canImport(AppKit)
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        hostingController.view.needsLayout = true
        hostingController.view.layoutSubtreeIfNeeded()
    #else
        _ = view
    #endif
}
