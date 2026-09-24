import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("ListRow")
struct ListRowTests {

    @Test("renders every combination of icon, subtitle, and accessory")
    func rendersVariants() {
        renderForCoverage(
            VStack {
                ListRow("Title")
                ListRow("Title", subtitle: "Subtitle")
                ListRow("Title", subtitle: "", systemImage: "gear")
                ListRow("Title", systemImage: "bell", iconTint: .orange) {
                    Toggle("Enabled", isOn: .constant(true)).labelsHidden()
                }
                ListRow("Title", subtitle: "Subtitle", systemImage: "internaldrive") {
                    Text("1.2 GB")
                }
            }
        )
    }
}
