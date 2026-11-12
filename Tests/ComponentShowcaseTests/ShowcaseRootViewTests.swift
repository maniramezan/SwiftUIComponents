import SwiftUI
import TestCommonsUI
import Testing

@testable import ComponentShowcase

@MainActor
@Suite("Showcase root", .serialized)
struct ShowcaseRootViewTests {

    @Test(
        "the sidebar renders at standard and accessibility text sizes",
        arguments: [
            DynamicTypeSize.large, .accessibility5,
        ])
    func rendersRoot(dynamicTypeSize: DynamicTypeSize) throws {
        let host = HostedView(
            ShowcaseRootView()
                .environment(\.dynamicTypeSize, dynamicTypeSize),
            size: CGSize(width: 1200, height: 900)
        )
        defer { host.close() }
        #expect(host.renderPNG() != nil)
    }
}
