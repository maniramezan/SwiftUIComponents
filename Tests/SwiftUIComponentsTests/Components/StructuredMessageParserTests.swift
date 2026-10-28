import Components
import Foundation
import Testing

@Suite("StructuredMessageParser")
struct StructuredMessageParserTests {

    @Test("returns nil for plain text without H2 headings")
    func plainText() {
        let result = StructuredMessageParser.sections(
            from: "Just one paragraph of plain text. No headings here."
        )
        #expect(result == nil)
    }

    @Test("returns nil for a single H2 section (below minimum)")
    func singleSection() {
        let result = StructuredMessageParser.sections(
            from: """
                ## Title

                Body content.
                """
        )
        #expect(result == nil)
    }

    @Test("returns sections for two or more H2 sections")
    func twoSections() throws {
        let result = StructuredMessageParser.sections(
            from: """
                ## First

                First body.

                ## Second

                Second body.
                """
        )
        let sections = try #require(result)
        #expect(sections.count == 2)
        #expect(sections[0].title == "First")
        #expect(sections[0].body == "First body.")
        #expect(sections[1].title == "Second")
        #expect(sections[1].body == "Second body.")
    }

    @Test("strips bold/italic/code markers from titles")
    func cleansTitleMarkers() throws {
        let result = StructuredMessageParser.sections(
            from: """
                ## **Bold Title**

                body one

                ## `Code Title`

                body two
                """
        )
        let sections = try #require(result)
        #expect(sections[0].title == "Bold Title")
        #expect(sections[1].title == "Code Title")
    }

    @Test("skips empty leading lines inside a section")
    func skipsLeadingBlankLines() throws {
        let result = StructuredMessageParser.sections(
            from: """
                ## A



                content for A

                ## B


                content for B
                """
        )
        let sections = try #require(result)
        #expect(sections[0].body == "content for A")
        #expect(sections[1].body == "content for B")
    }

    @Test("normalizes Windows CRLF line endings")
    func normalizesCRLF() throws {
        let crlf = "## One\r\n\r\nfirst\r\n\r\n## Two\r\n\r\nsecond"
        let sections = try #require(StructuredMessageParser.sections(from: crlf))
        #expect(sections.count == 2)
        #expect(sections[0].body == "first")
        #expect(sections[1].body == "second")
    }

    @Test("auto-promotes provided heading phrases when emitted without ##")
    func autoPromotesHeadings() throws {
        let text = """
            Summary The cat sat on the mat. This is the main point.

            Details See how the cat sits comfortably.
            """
        let result = StructuredMessageParser.sections(
            from: text,
            autoPromotingHeadings: ["Summary", "Details"]
        )
        let sections = try #require(result)
        #expect(sections.count == 2)
        #expect(sections[0].title == "Summary")
        #expect(sections[1].title == "Details")
    }

    @Test("does not promote headings that already have ## prefix")
    func skipsAlreadyPromoted() throws {
        let text = """
            ## Summary

            Existing body one.

            ## Details

            Existing body two.
            """
        let result = StructuredMessageParser.sections(
            from: text,
            autoPromotingHeadings: ["Summary", "Details"]
        )
        let sections = try #require(result)
        #expect(sections.count == 2)
        #expect(sections[0].title == "Summary")
        #expect(sections[0].body == "Existing body one.")
    }

    @Test("respects custom minimumSectionCount")
    func customMinimum() throws {
        let text = """
            ## Only One

            body
            """
        let strict = StructuredMessageParser.sections(from: text)
        #expect(strict == nil)
        let lenient = StructuredMessageParser.sections(from: text, minimumSectionCount: 1)
        let sections = try #require(lenient)
        #expect(sections.count == 1)
    }
}

@Test("Structured parsing preserves preambles by choosing the complete fallback")
func structuredPreambleFallsBack() {
    #expect(StructuredMessageParser.sections(from: "Keep this warning.\n## A\none\n## B\ntwo") == nil)
}

@Test("Promoted labels never match ordinary prose or lowercase body openings")
func promotionRequiresLeadingLabel() throws {
    let source = "## A\nA summary explains this.\n## B\nSummary explains this too."
    let sections = try #require(StructuredMessageParser.sections(from: source, autoPromotingHeadings: ["Summary"]))
    #expect(sections.count == 2)
    #expect(sections[0].body == "A summary explains this.")
    #expect(sections[1].body == "Summary explains this too.")
}

@Test("Fenced headings and repeated blank lines remain body content")
func fencedHeadingsRemainContent() throws {
    let source = "## A\n```markdown\n## Example\n```\n\n\nend\n## B\nbody"
    let sections = try #require(StructuredMessageParser.sections(from: source))
    #expect(sections.count == 2)
    #expect(sections[0].body == "```markdown\n## Example\n```\n\n\nend")
    #expect(StructuredMessageParser.sections(from: "## A\n```\n## B\nbody") == nil)
}

@Test("Repeated heading identities are distinct and stable across parses and unrelated insertions")
func structuredIdentitiesAreStable() throws {
    let source = "## A\none\n## A\ntwo"
    let first = try #require(StructuredMessageParser.sections(from: source))
    let second = try #require(StructuredMessageParser.sections(from: "## Other\nextra\n" + source))
    #expect(Set(first.map(\.id)).count == 2)
    #expect(first.map(\.id) == Array(second.dropFirst()).map(\.id))
    #expect(StructuredMessageParser.sections(from: source) == first)
}

@Test("Empty sections retain their headings")
func emptyStructuredSectionsRemain() throws {
    let sections = try #require(StructuredMessageParser.sections(from: "## A\n## B\nbody"))
    #expect(sections.map(\.title) == ["A", "B"])
    #expect(sections[0].body.isEmpty)
}
