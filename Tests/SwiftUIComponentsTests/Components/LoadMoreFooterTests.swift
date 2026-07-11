import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("LoadMoreFooter")
struct LoadMoreFooterTests {

    @Test("constructs with a trigger id, idle")
    func constructsIdle() {
        _ = LoadMoreFooter(triggerID: 20, isLoadingMore: false) {}
    }

    @Test("constructs with a trigger id, loading")
    func constructsLoading() {
        _ = LoadMoreFooter(triggerID: 20, isLoadingMore: true) {}
    }

    @Test("constructs with a nil trigger id (no more content)")
    func constructsNoMoreContent() {
        _ = LoadMoreFooter(triggerID: nil, isLoadingMore: false) {}
    }

    @Test("stores the supplied trigger id and loading flag")
    func storesConfiguration() {
        let footer = LoadMoreFooter(triggerID: "page-2", isLoadingMore: true) {}
        #expect(footer.triggerID == AnyHashable("page-2"))
        #expect(footer.isLoadingMore)
    }

    @Test("onTrigger closure is the one supplied at init")
    func onTriggerFiresSuppliedClosure() {
        var triggerCount = 0
        let footer = LoadMoreFooter(triggerID: "page-2", isLoadingMore: false) {
            triggerCount += 1
        }
        footer.onTrigger()
        footer.onTrigger()
        #expect(triggerCount == 2)
    }
}
