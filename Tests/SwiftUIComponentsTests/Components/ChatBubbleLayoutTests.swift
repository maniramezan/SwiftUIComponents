import SwiftUI
import Testing

@testable import Components

/// Regression coverage for the chat bubble's two independent direction
/// decisions: role alignment (leading/trailing, so a right-to-left interface
/// mirrors the conversation) and content direction (per bubble, so a
/// right-to-left reply inside a left-to-right app does *not* move the bubble
/// to the other side of the screen).
@MainActor
@Suite("ChatBubbleLayout")
struct ChatBubbleLayoutTests {

    // MARK: - Role alignment

    @Test("user messages hug the trailing edge")
    func userHugsTrailing() {
        #expect(ChatBubbleLayout.hugsTrailingEdge(for: .user))
    }

    @Test("assistant and system messages hug the leading edge")
    func assistantAndSystemHugLeading() {
        #expect(!ChatBubbleLayout.hugsTrailingEdge(for: .assistant))
        #expect(!ChatBubbleLayout.hugsTrailingEdge(for: .system))
    }

    // MARK: - Content direction

    @Test("no override inherits the ambient layout direction")
    func inheritsAmbient() {
        #expect(ChatBubbleLayout.contentDirection(override: nil, ambient: .leftToRight) == .leftToRight)
        #expect(ChatBubbleLayout.contentDirection(override: nil, ambient: .rightToLeft) == .rightToLeft)
    }

    @Test("an override wins over the ambient layout direction")
    func overrideWins() {
        #expect(ChatBubbleLayout.contentDirection(override: .rightToLeft, ambient: .leftToRight) == .rightToLeft)
        #expect(ChatBubbleLayout.contentDirection(override: .leftToRight, ambient: .rightToLeft) == .leftToRight)
    }

    @Test("an override matching the ambient direction is a no-op")
    func redundantOverride() {
        #expect(ChatBubbleLayout.contentDirection(override: .leftToRight, ambient: .leftToRight) == .leftToRight)
        #expect(ChatBubbleLayout.contentDirection(override: .rightToLeft, ambient: .rightToLeft) == .rightToLeft)
    }

    // MARK: - Rendering

    @Test("right-to-left content renders inside a left-to-right hierarchy")
    func rightToLeftContentInLeftToRightInterface() {
        renderForCoverage(
            VStack {
                ChatBubbleView(role: .user, content: "مرحبا", contentLayoutDirection: .rightToLeft)
                ChatBubbleView(role: .assistant, content: "أهلا بك", contentLayoutDirection: .rightToLeft)
            }
            .environment(\.layoutDirection, .leftToRight)
        )
    }

    @Test("a mirrored interface renders with inherited content direction")
    func mirroredInterface() {
        renderForCoverage(
            VStack {
                ChatBubbleView(role: .user, content: "مرحبا")
                ChatBubbleView(role: .assistant, content: "أهلا بك")
            }
            .environment(\.layoutDirection, .rightToLeft)
        )
    }

    @Test("structured bubbles forward the content direction override")
    func structuredForwardsOverride() {
        renderForCoverage(
            StructuredChatBubbleView(
                role: .assistant,
                content: """
                    ## Summary
                    First section body.

                    ## Details
                    Second section body.
                    """,
                contentLayoutDirection: .rightToLeft
            )
        )
    }

    @Test("the structured bubble's plain fallback forwards the content direction override")
    func structuredFallbackForwardsOverride() {
        renderForCoverage(
            StructuredChatBubbleView(
                role: .assistant,
                content: "A single unstructured reply.",
                contentLayoutDirection: .rightToLeft
            )
        )
    }

    @Test("ChatBubble accepts a content direction override for every role")
    func customContentOverrideForAllRoles() {
        for role in [ChatMessageRole.user, .assistant, .system] {
            renderForCoverage(
                ChatBubble(role: role, contentLayoutDirection: .rightToLeft) {
                    Text("Custom")
                }
            )
        }
    }
}
