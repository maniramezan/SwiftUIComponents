import Components
import DesignSystem
import SwiftUI

struct TypingIndicatorDetailView: View {
    @State private var showTyping = true
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Typing indicator bubble") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    ChatBubbleView(role: .user, content: "Are you there?")
                    if showTyping {
                        TypingIndicatorBubbleView()
                    }
                }
            }

            ShowcaseSection("Dots only") {
                TypingDotsView()
            }

            ShowcaseSection("ChatBubbleView typing state") {
                ChatBubbleView(role: .assistant, content: "", isTyping: true)
            }

            ShowcaseSection("Controls") {
                Toggle("Show typing indicator", isOn: $showTyping)
                    .toggleStyle(ThemeToggleStyle())
            }
        }
    }
}
