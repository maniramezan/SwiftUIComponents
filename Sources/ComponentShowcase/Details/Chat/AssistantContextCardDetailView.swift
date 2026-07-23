import Components
import DesignSystem
import SwiftUI

struct AssistantContextCardDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Word context (quoted body)") {
                AssistantContextCard(
                    title: "hello",
                    highlight: "Hola",
                    bodyText: "Hello, how are you today?",
                    bodyStyle: .quoted,
                    footnote: "From: Everyday English"
                )
            }

            ShowcaseSection("Grammar context (plain body)") {
                AssistantContextCard(
                    title: "Present Perfect",
                    highlight: "B1",
                    bodyText: "have/has + past participle",
                    bodyStyle: .plain
                )
            }

            ShowcaseSection("Title only") {
                AssistantContextCard(title: "hello")
            }
        }
    }
}

#Preview {
    ScrollView {
        AssistantContextCardDetailView()
            .padding()
    }
}
