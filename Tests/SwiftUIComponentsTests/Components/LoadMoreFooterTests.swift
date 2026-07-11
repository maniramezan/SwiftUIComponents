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

    // MARK: - Rendering (exercises the sentinel and spinner branches)

    @Test("has more, idle renders the sentinel without a spinner and fires onTrigger")
    func rendersSentinelIdleAndFires() {
        var triggerCount = 0
        renderForCoverage(
            LoadMoreFooter(triggerID: "page-2", isLoadingMore: false) { triggerCount += 1 }
        )
        #expect(triggerCount == 1)
    }

    @Test("has more, loading renders the sentinel and spinner")
    func rendersSentinelLoading() {
        renderForCoverage(LoadMoreFooter(triggerID: "page-2", isLoadingMore: true) {})
    }

    @Test("no more content omits the sentinel and never fires onTrigger")
    func rendersNoMoreContent() {
        var triggerCount = 0
        renderForCoverage(
            LoadMoreFooter(triggerID: nil, isLoadingMore: false) { triggerCount += 1 }
        )
        #expect(triggerCount == 0)
    }
}
