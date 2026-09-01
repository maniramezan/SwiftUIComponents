import Components
import SwiftUI
import Testing

@Test("ActionPill accepts dynamic label content")
@MainActor
func actionPillAcceptsDynamicLabelContent() {
    let pill = ActionPill(action: {}) {
        HStack {
            Text("Status")
            Text("Active")
        }
    }
    _ = pill.body
}
