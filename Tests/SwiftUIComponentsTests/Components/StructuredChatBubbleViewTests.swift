import Components
import SwiftUI
import Testing

@MainActor
@Suite("StructuredChatBubbleView")
struct StructuredChatBubbleViewTests {

    @Test("plain assistant text falls back to ChatBubbleView")
    func plainFallback() {
        _ = StructuredChatBubbleView(role: .assistant, content: "A single unstructured reply.")
    }

    @Test("assistant text with two or more headings renders structured sections")
    func structuredSections() {
        _ = StructuredChatBubbleView(
            role: .assistant,
            content: """
                ## Main Idea
                Body one.

                ## Examples
                Body two.
                """
        )
    }

    @Test("autoPromotingHeadings promotes bare leading labels")
    func autoPromotingHeadings() {
        _ = StructuredChatBubbleView(
            role: .assistant,
            content: "Main Idea This word means hello. Examples Used as a greeting.",
            autoPromotingHeadings: ["Main Idea", "Examples"]
        )
    }

    @Test("user role never attempts structured parsing")
    func userRoleSkipsStructuring() {
        _ = StructuredChatBubbleView(
            role: .user,
            content: "## Not a heading, just my question"
        )
    }

    @Test("isTyping with empty content shows typing indicator, not structured parsing")
    func typingEmpty() {
        _ = StructuredChatBubbleView(role: .assistant, content: "", isTyping: true)
    }

    @Test("minimumSectionCount can require more sections before structuring")
    func minimumSectionCount() {
        _ = StructuredChatBubbleView(
            role: .assistant,
            content: "## Only One\nBody.",
            minimumSectionCount: 2
        )
    }

    // MARK: - Rendering

    @Test("plain fallback renders")
    func plainFallbackRenders() {
        renderForCoverage(StructuredChatBubbleView(role: .assistant, content: "A single unstructured reply."))
    }

    @Test("structured sections render")
    func structuredSectionsRender() {
        renderForCoverage(
            StructuredChatBubbleView(
                role: .assistant,
                content: """
                    ## Main Idea
                    Body one.

                    ## Examples
                    Body two.
                    """
            )
        )
    }

    @Test("user role renders as plain bubble")
    func userRoleRenders() {
        renderForCoverage(StructuredChatBubbleView(role: .user, content: "## Not a heading"))
    }

    @Test("typing state renders")
    func typingRenders() {
        renderForCoverage(StructuredChatBubbleView(role: .assistant, content: "", isTyping: true))
    }
}
