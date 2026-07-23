import Components
import DesignSystem
import SwiftUI

struct StructuredChatBubbleDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Structured response") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    ChatBubbleView(role: .user, content: "Explain the present perfect tense")
                    StructuredChatBubbleView(
                        role: .assistant,
                        content: """
                            ## Main Idea
                            Used for actions that happened at an unspecified time before now.

                            ## Examples
                            - I have visited Paris.
                            - She has finished her homework.
                            """
                    )
                }
            }

            ShowcaseSection("Auto-promoting bare labels") {
                StructuredChatBubbleView(
                    role: .assistant,
                    content: "Main Idea This word means hello. Examples Used as a greeting.",
                    autoPromotingHeadings: ["Main Idea", "Examples"]
                )
            }

            ShowcaseSection("Falls back to plain markdown") {
                StructuredChatBubbleView(
                    role: .assistant,
                    content: "A single unstructured reply renders like a normal chat bubble."
                )
            }
        }
    }
}

#Preview {
    ScrollView {
        StructuredChatBubbleDetailView()
            .padding()
    }
}
