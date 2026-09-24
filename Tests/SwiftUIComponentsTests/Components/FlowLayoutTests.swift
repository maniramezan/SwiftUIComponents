import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("FlowLayout")
struct FlowLayoutTests {

    @Test("constructs with default and explicit spacings")
    func constructs() {
        _ = FlowLayout()
        _ = FlowLayout(spacing: 4)
        _ = FlowLayout(spacing: 8, lineSpacing: 12) {
            Text("A")
            Text("B")
        }
    }

    @Test("default spacings are zero")
    func defaultSpacings() {
        let layout = FlowLayout()
        #expect(layout.spacing == 0)
        #expect(layout.lineSpacing == 0)
    }

    @Test("explicit spacings round-trip")
    func explicitSpacings() {
        let layout = FlowLayout(spacing: 8, lineSpacing: 12)
        #expect(layout.spacing == 8)
        #expect(layout.lineSpacing == 12)
    }

    @Test("wrapping produces correct height for multiple lines")
    func wrappingHeight() {
        let layout = FlowLayout(spacing: 10, lineSpacing: 5)
        // 3 items each 50pt wide in 120pt container:
        // Line 1: 50 + 10 + 50 = 110 (fits), Line 2: 50 (wraps)
        // Height = 20 + 5 + 20 = 45
        let result = layout.testArrange(
            maxWidth: 120,
            sizes: [
                CGSize(width: 50, height: 20),
                CGSize(width: 50, height: 20),
                CGSize(width: 50, height: 20),
            ]
        )
        #expect(result.size.width == 120)
        #expect(result.size.height == 45)
        #expect(result.positions[0] == CGPoint(x: 0, y: 0))
        #expect(result.positions[1] == CGPoint(x: 60, y: 0))
        #expect(result.positions[2] == CGPoint(x: 0, y: 25))
    }

    @Test("oversized item does not wrap to empty line")
    func oversizedItem() {
        let layout = FlowLayout(spacing: 0, lineSpacing: 0)
        let result = layout.testArrange(
            maxWidth: 50,
            sizes: [CGSize(width: 100, height: 30)]
        )
        #expect(result.size.height == 30)
        #expect(result.positions[0] == .zero)
    }

    @Test("all items fit on one line when width is sufficient")
    func singleLine() {
        let layout = FlowLayout(spacing: 4, lineSpacing: 10)
        let result = layout.testArrange(
            maxWidth: 500,
            sizes: [
                CGSize(width: 40, height: 20),
                CGSize(width: 40, height: 25),
                CGSize(width: 40, height: 20),
            ]
        )
        #expect(result.size.height == 25)
    }

    @Test("mixed heights picks tallest per line")
    func mixedHeights() {
        let layout = FlowLayout(spacing: 0, lineSpacing: 2)
        // Width 60: item0(40) fits, item1(40) wraps because 40+0+40=80>60
        let result = layout.testArrange(
            maxWidth: 60,
            sizes: [
                CGSize(width: 40, height: 10),
                CGSize(width: 40, height: 30),
            ]
        )
        #expect(result.size.height == 42)
    }

    @Test("unbounded width keeps one line and reports its width")
    func unboundedWidthHugsContent() {
        let layout = FlowLayout(spacing: 10, lineSpacing: 5)
        let result = layout.testArrange(
            maxWidth: FlowLayout.boundedWidth(nil),
            sizes: [CGSize(width: 50, height: 20), CGSize(width: 30, height: 10)]
        )
        #expect(result.size == CGSize(width: 90, height: 20))
        #expect(result.positions == [CGPoint(x: 0, y: 0), CGPoint(x: 60, y: 0)])
    }

    @Test("infinite and missing proposals are both treated as unbounded")
    func boundedWidthNormalizesProposals() {
        #expect(FlowLayout.boundedWidth(nil) == .infinity)
        #expect(FlowLayout.boundedWidth(.infinity) == .infinity)
        #expect(FlowLayout.boundedWidth(240) == 240)
    }

    @Test("renders wrapped and fixed-size content")
    func rendersInHost() {
        let tags = ["Alpha", "Beta", "Gamma", "Delta", "A much longer label that must wrap on its own"]
        renderForCoverage(
            FlowLayout(spacing: 8, lineSpacing: 8) {
                ForEach(tags, id: \.self) { Text($0) }
            }
        )
        renderForCoverage(
            FlowLayout(spacing: 8) {
                ForEach(tags, id: \.self) { Text($0) }
            }
            .fixedSize()
        )
    }
}

// MARK: - Test helper

extension FlowLayout {
    /// Runs the layout's real wrapping math against known item sizes.
    func testArrange(maxWidth: CGFloat, sizes: [CGSize]) -> (size: CGSize, positions: [CGPoint]) {
        Self.arrange(sizes: sizes, maxWidth: maxWidth, spacing: spacing, lineSpacing: lineSpacing)
    }
}
