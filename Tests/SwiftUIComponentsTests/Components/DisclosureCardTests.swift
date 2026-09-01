import Components
import SwiftUI
import Testing

@Test("DisclosureCard accepts summary and detail content")
@MainActor
func disclosureCardAcceptsSummaryAndDetailContent() {
    let card = DisclosureCard(isExpanded: .constant(false)) {
        Text("Summary")
    } detail: {
        Text("Detail")
    }
    _ = card.body
}
