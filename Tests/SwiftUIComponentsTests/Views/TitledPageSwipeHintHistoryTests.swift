import Foundation
import Testing
@testable import Components

@MainActor
struct TitledPageSwipeHintHistoryTests {
    @Test func hintPlaysOnlyOnceAcrossStorageInstances() throws {
        let suiteName = "TitledPageSwipeHintHistoryTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(TitledPageSwipeHintHistory.claim(in: defaults))
        #expect(!TitledPageSwipeHintHistory.claim(in: defaults))

        let reopenedDefaults = try #require(UserDefaults(suiteName: suiteName))
        #expect(!TitledPageSwipeHintHistory.claim(in: reopenedDefaults))
    }

    @Test func separateInstallStorageStartsWithAnUnseenHint() throws {
        let suiteName = "TitledPageSwipeHintHistoryTests.\(UUID().uuidString)"
        let defaults = try #require(UserDefaults(suiteName: suiteName))
        defer { defaults.removePersistentDomain(forName: suiteName) }

        #expect(!defaults.bool(forKey: TitledPageSwipeHintHistory.storageKey))
        #expect(TitledPageSwipeHintHistory.claim(in: defaults))
    }
}
