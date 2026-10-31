import SwiftUI
import TestCommonsUI
import Testing

@testable import ComponentShowcase

@Suite("ShowcaseComponent routing")
struct ShowcaseComponentTests {

    @Test("only full-page and overlay-anchoring pages own their ScrollView")
    func ownsScrollViewSet() {
        let owners = Set(ShowcaseComponent.allCases.filter(\.ownsScrollView))
        #expect(owners == [.chat, .toast])
    }

    @Test("toast owns its scroll view so its overlays anchor to the visible pane")
    func toastOwnsScrollView() {
        #expect(ShowcaseComponent.toast.ownsScrollView)
        #expect(!ShowcaseComponent.toast.fillsDetailPane)
    }

    @Test("only the chat playground fills the detail pane")
    func fillsDetailPaneSet() {
        let fillers = Set(ShowcaseComponent.allCases.filter(\.fillsDetailPane))
        #expect(fillers == [.chat])
    }

    @Test("every component has a system image and an existing sidebar group")
    func metadataIsComplete() {
        let groups: Set<String> = [
            "Actions", "Controls", "Display", "Surfaces", "Feedback", "Pagination", "Chat", "Collections",
        ]
        for component in ShowcaseComponent.allCases {
            #expect(!component.systemImage.isEmpty)
            #expect(groups.contains(component.group))
        }
    }
}

@MainActor
@Suite("Showcase pages", .serialized)
struct ShowcasePageRenderTests {

    @Test("every showcase page renders in a hosted window", arguments: ShowcaseComponent.allCases)
    func rendersPage(component: ShowcaseComponent) throws {
        let host = HostedView(
            NavigationStack { ShowcaseDetailView(component: component) },
            size: CGSize(width: 600, height: 900)
        )
        defer { host.close() }
        _ = host.renderPNG()
        RunLoop.current.run(until: Date(timeIntervalSinceNow: 0.05))
        #expect(host.renderPNG() != nil)
    }
}
