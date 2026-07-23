import Components
import DesignSystem
import SwiftUI

private struct DemoTurn: Identifiable, Equatable {
    let id: Int
    let label: String
    let state: AssistantConversationState
}

struct AssistantConversationDetailView: View {
    @State private var turns: [DemoTurn] = [
        DemoTurn(id: 0, label: "Translate", state: .complete("Hola")),
        DemoTurn(id: 1, label: "Explain", state: .streaming("This word means...")),
    ]
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Conversation") {
                AssistantConversationList(
                    turns: turns,
                    isInteractionEnabled: true,
                    idleHint: "Tap an action below to get started.",
                    userLabel: { $0.label },
                    responseState: { $0.state },
                    retryTitle: "Retry",
                    onRetry: { _ in }
                )
            }

            ShowcaseSection("Structured completed response") {
                AssistantConversationList(
                    turns: [
                        DemoTurn(
                            id: 2, label: "Explain",
                            state: .complete(
                                """
                                ## Main Idea
                                Used for actions that happened at an unspecified time before now.

                                ## Examples
                                - I have visited Paris.
                                - She has finished her homework.
                                """
                            ))
                    ],
                    isInteractionEnabled: true,
                    userLabel: { $0.label },
                    responseState: { $0.state },
                    retryTitle: "Retry",
                    onRetry: { _ in },
                    autoPromotingHeadings: ["Main Idea", "Examples"]
                )
            }

            ShowcaseSection("Error with retry") {
                AssistantConversationList(
                    turns: [DemoTurn(id: 3, label: "Grammar", state: .error("Something went wrong."))],
                    isInteractionEnabled: true,
                    userLabel: { $0.label },
                    responseState: { $0.state },
                    retryTitle: "Retry",
                    onRetry: { _ in }
                )
            }

            ShowcaseSection("Typewriter reveal") {
                TypewriterReveal(text: "The assistant is composing a response.") { text in
                    ChatBubbleView(role: .assistant, content: text)
                }
            }

            ShowcaseSection("Empty state") {
                AssistantConversationList(
                    turns: [DemoTurn](),
                    isInteractionEnabled: true,
                    idleHint: "Tap an action below to get started.",
                    userLabel: { $0.label },
                    responseState: { $0.state },
                    retryTitle: "Retry",
                    onRetry: { _ in }
                )
            }
        }
    }
}

#Preview {
    ScrollView {
        AssistantConversationDetailView()
            .padding()
    }
}
