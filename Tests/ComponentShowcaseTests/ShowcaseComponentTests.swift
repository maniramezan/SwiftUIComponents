import SwiftUI
import TestCommonsUI
import Testing

@testable import ComponentShowcase

#if canImport(AppKit)
    import AppKit
#elseif canImport(UIKit)
    import UIKit
#endif

@Suite("ShowcaseComponent routing")
struct ShowcaseComponentTests {

    @Test("empty and whitespace searches include every component in sidebar order", arguments: ["", " \n\t "])
    func emptySearchIncludesEveryComponent(query: String) {
        let groups = ShowcaseComponent.groups(matching: query)

        #expect(
            groups.map(\.title) == [
                "Actions", "Controls", "Display", "Surfaces", "Feedback", "Pagination", "Chat", "Collections",
            ])
        #expect(groups.flatMap(\.items) == ShowcaseComponent.allCases)
    }

    @Test("search matches partial component names regardless of case and surrounding whitespace")
    func searchMatchesComponentNames() {
        let groups = ShowcaseComponent.groups(matching: "  PiCkEr \n")

        #expect(groups.map(\.title) == ["Controls", "Pagination"])
        #expect(groups.flatMap(\.items) == [.menuPicker, .segmentedPicker])
    }

    @Test("search matches group names and preserves the group's component order")
    func searchMatchesGroupNames() {
        let groups = ShowcaseComponent.groups(matching: "feedBACK")

        #expect(groups.map(\.title) == ["Feedback"])
        #expect(
            groups.flatMap(\.items) == [
                .errorBanner, .errorSection, .loading, .ghostLoading, .emptyState, .toast, .progress, .asyncContent,
            ])
    }

    @Test("unmatched searches return no sections and clearing restores the list")
    func unmatchedAndClearedSearches() {
        #expect(ShowcaseComponent.groups(matching: "no matching component").isEmpty)
        #expect(ShowcaseComponent.groups(matching: "").flatMap(\.items) == ShowcaseComponent.allCases)
    }

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

    @Test("every sidebar icon resolves to a system image", arguments: ShowcaseComponent.allCases)
    func systemImagesResolve(component: ShowcaseComponent) {
        #if canImport(AppKit)
            #expect(
                NSImage(systemSymbolName: component.systemImage, accessibilityDescription: component.rawValue) != nil)
        #elseif canImport(UIKit)
            #expect(UIImage(systemName: component.systemImage) != nil)
        #endif
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
