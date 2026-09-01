import Components
import SwiftUI
import Testing

@Test("DisclosureCard accepts summary and detail content")
@MainActor
func disclosureCardAcceptsSummaryAndDetailContent() {
    _ = DisclosureCard(isExpanded: .constant(false)) {
        Text("Summary")
    } detail: {
        Text("Detail")
    }
}
