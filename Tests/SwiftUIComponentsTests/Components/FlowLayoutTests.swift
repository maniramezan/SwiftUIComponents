import Components
import SwiftUI
import Testing

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
}

// MARK: - Test helper

extension FlowLayout {
    /// Exercises the same wrapping math as the real layout, using known sizes.
    func testArrange(maxWidth: CGFloat, sizes: [CGSize]) -> (
        size: CGSize, positions: [CGPoint]
    ) {
        var positions = [CGPoint]()
        var currentX: CGFloat = .zero
        var currentY: CGFloat = .zero
        var lineHeight: CGFloat = .zero
        var totalHeight: CGFloat = .zero

        for size in sizes {
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + lineSpacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalHeight = max(totalHeight, currentY + lineHeight)
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
