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
}
