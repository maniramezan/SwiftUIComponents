import Components
import DesignSystem
import SwiftUI

struct ChatBubbleDetailView: View {
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Conversation") {
                VStack(spacing: theme.spacing.oneUnit) {
                    ChatBubbleView(role: .user, content: "What's the weather like today?")
                    ChatBubbleView(role: .assistant, content: "It's currently **sunny and 22 °C**. A great day to go outside!")
                    ChatBubbleView(role: .user, content: "Any chance of rain this afternoon?")
                    ChatBubbleView(role: .assistant, content: "There's a **30 % chance** of light showers after 5 PM.")
                }
            }

            ShowcaseSection("System message") {
                ChatBubbleView(role: .system, content: "Conversation started.")
            }

            ShowcaseSection("Custom content bubble") {
                ChatBubble(role: .assistant) {
                    HStack(spacing: theme.spacing.oneUnit) {
                        Image(systemName: "map.fill")
                            .foregroundStyle(theme.colors.primary)
                        Text("San Francisco, CA")
                            .designTextStyle(.body)
                    }
                    .padding(theme.spacing.oneAndHalfUnits)
                }
            }
        }
    }
}
