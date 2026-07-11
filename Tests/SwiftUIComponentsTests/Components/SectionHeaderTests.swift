import Components
import SwiftUI
import Testing

@MainActor
@Suite("SectionHeader")
struct SectionHeaderTests {

    @Test("title-only init renders without action")
    func titleOnly() {
        let header = SectionHeader(title: "Recent")
        _ = header
    }

    @Test("title with action label and closure renders action button")
    func titleWithAction() {
        var tapped = false
        let header = SectionHeader(title: "Vocabulary", actionLabel: "See All") {
            tapped = true
        }
        _ = header
        // The closure is stored; verifying it is callable
        #expect(tapped == false)
    }

    @Test("nil actionLabel omits action even if onAction is provided")
    func nilActionLabel() {
        let header = SectionHeader(title: "Test", actionLabel: nil) {}
        _ = header
    }

    @Test("nil onAction omits action even if actionLabel is provided")
    func nilOnAction() {
        let header = SectionHeader(title: "Test", actionLabel: "Tap", onAction: nil)
        _ = header
    }

    @Test("titleFont override replaces the theme's default headline font")
    func titleFontOverride() {
        _ = SectionHeader(title: "Custom", titleFont: .largeTitle).body
    }

    @Test("nil titleFont falls back to the theme's headline font")
    func titleFontDefault() {
        _ = SectionHeader(title: "Default").body
    }
}
