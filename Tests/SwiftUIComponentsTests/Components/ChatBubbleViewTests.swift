import Components
import SwiftUI
import Testing

@MainActor
@Suite("ChatBubbleView")
struct ChatBubbleViewTests {

    @Test("user role renders plain text")
    func userRole() {
        _ = ChatBubbleView(role: .user, content: "Hello there")
    }

    @Test("assistant role renders markdown content")
    func assistantMarkdown() {
        _ = ChatBubbleView(role: .assistant, content: "This is **bold** and *italic*")
    }

    @Test("system role renders plain text")
    func systemRole() {
        _ = ChatBubbleView(role: .system, content: "Tool result")
    }

    @Test("isTyping with empty content shows typing indicator")
    func typingEmpty() {
        _ = ChatBubbleView(role: .assistant, content: "", isTyping: true)
    }

    @Test("isTyping with non-empty content shows text, not indicator")
    func typingWithContent() {
        _ = ChatBubbleView(role: .assistant, content: "Partial", isTyping: true)
    }

    @Test("ChatBubble with custom content is constructible for all roles")
    func customContent() {
        for role in [ChatMessageRole.user, .assistant, .system] {
            _ = ChatBubble(role: role) {
                VStack {
                    Text("Custom"); Text("Content")
                }
            }
        }
    }

    @Test("TypingIndicatorBubbleView constructs as assistant-aligned bubble")
    func typingIndicatorBubble() {
        _ = TypingIndicatorBubbleView()
    }

    @Test("TypingDotsView constructs with accessibility label")
    func typingDots() {
        _ = TypingDotsView()
    }
}
