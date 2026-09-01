import Components
import SwiftUI
import Testing

@Test("ActionPill accepts dynamic label content")
@MainActor
func actionPillAcceptsDynamicLabelContent() {
    _ = ActionPill(action: {}) {
        HStack {
            Text("past")
            Text("walked")
        }
    }
}
