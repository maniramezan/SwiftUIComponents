import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("Structured chat presentation")
struct StructuredChatPresentationTests {
    @Test("An unchanged request reuses its prepared sections and attributed text")
    func reusesPreparation() throws {
        var parses = 0
        let presentation = StructuredChatPresentation { text, labels, minimum in
            parses += 1
            return StructuredMessageParser.sections(
                from: text, autoPromotingHeadings: labels, minimumSectionCount: minimum)
        }
        let request = request()
        for _ in 0..<10 { presentation.update(request) }
        #expect(parses == 1)
        let sections = try #require(presentation.sections)
        #expect(sections.map(\.title) == ["A", "B"])
        #expect(String(sections[0].body.characters) == "First")
        #expect(presentation.text == nil)

        let plain = self.request(content: "**Plain**")
        for _ in 0..<10 { presentation.update(plain) }
        #expect(parses == 2)
        #expect(presentation.sections == nil)
        #expect(presentation.text == AttributedString(markdownOrPlainText: "**Plain**"))
    }

    @Test("Content and parsing policy changes invalidate the retained presentation")
    func invalidatesInputs() throws {
        let presentation = StructuredChatPresentation()
        presentation.update(request())
        #expect(presentation.sections?.count == 2)
        presentation.update(request(minimum: 3))
        #expect(presentation.sections == nil)
        #expect(presentation.text != nil)
        presentation.update(request(content: "Summary First\nDetails Second", labels: ["Summary", "Details"]))
        #expect(presentation.sections?.map(\.title) == ["Summary", "Details"])
        presentation.update(request(content: "Summary First\nDetails Second"))
        #expect(presentation.sections == nil)
        presentation.update(request(content: "## New\nChanged\n## Other\nBody"))
        #expect(presentation.sections?.first?.title == "New")
        #expect(String(try #require(presentation.sections?.first?.body.characters)) == "Changed")
    }

    @Test("Role and typing updates clear stale sections without parsing user or system messages")
    func respectsRoleAndTyping() {
        var parses = 0
        let presentation = StructuredChatPresentation { text, labels, minimum in
            parses += 1
            return StructuredMessageParser.sections(
                from: text, autoPromotingHeadings: labels, minimumSectionCount: minimum)
        }
        presentation.update(request())
        for role in [ChatMessageRole.user, .system] {
            presentation.update(request(role: role))
            #expect(presentation.sections == nil)
            #expect(presentation.text == nil)
        }
        presentation.update(request(isTyping: true))
        #expect(presentation.sections == nil)
        #expect(presentation.text != nil)
        #expect(parses == 1)
        presentation.update(request())
        #expect(presentation.sections?.count == 2)
        #expect(parses == 2)
    }

    private func request(
        role: ChatMessageRole = .assistant, content: String = "## A\n**First**\n## B\nSecond",
        isTyping: Bool = false, labels: [String] = [], minimum: Int = 2
    ) -> StructuredChatRequest {
        StructuredChatRequest(
            role: role, content: content, isTyping: isTyping,
            autoPromotingHeadings: labels, minimumSectionCount: minimum)
    }
}
