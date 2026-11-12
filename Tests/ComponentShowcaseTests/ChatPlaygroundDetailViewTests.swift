import SwiftUI
import TestCommonsUI
import Testing

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

@testable import ComponentShowcase

@MainActor
@Suite("Chat playground settings", .serialized)
struct ChatPlaygroundDetailViewTests {

    @Test("the chat settings sheet renders its captioned controls")
    func rendersSettingsSheet() throws {
        let host = HostedView(
            NavigationStack {
                ChatPlaygroundDetailView(isShowingSettingsInitially: true)
            },
            size: CGSize(width: 600, height: 900)
        )
        defer { host.close() }
        _ = host.renderPNG()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        #if canImport(AppKit)
            let sheet = try #require(host.window.attachedSheet)
            defer { host.window.endSheet(sheet) }
            let content = try #require(sheet.contentView)
            #expect(ViewRendering.pngData(of: content) != nil)
        #elseif canImport(UIKit)
            let sheet = try #require(host.hosting.presentedViewController)
            #expect(ViewRendering.pngData(of: sheet.view) != nil)
            sheet.dismiss(animated: false)
        #endif
    }
}
