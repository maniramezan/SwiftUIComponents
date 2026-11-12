import SwiftUI
import Testing

@testable import ComponentShowcase

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

@Suite("Floating action icon choices")
struct FloatingActionIconTests {
    @Test("every selectable icon resolves to a system image", arguments: FloatingActionIcon.allCases)
    func resolvesSystemImage(icon: FloatingActionIcon) {
        #if canImport(AppKit)
            #expect(NSImage(systemSymbolName: icon.rawValue, accessibilityDescription: icon.title) != nil)
        #elseif canImport(UIKit)
            #expect(UIImage(systemName: icon.rawValue) != nil)
        #endif
    }
}
