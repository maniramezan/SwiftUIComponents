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
            Main Idea The cat sat on the mat. This is the main point.

            Examples See how the cat sits comfortably.
            """
        let result = StructuredMessageParser.sections(
            from: text,
            autoPromotingHeadings: ["Main Idea", "Examples"]
        )
        let sections = try #require(result)
        #expect(sections.count == 2)
        #expect(sections[0].title == "Main Idea")
        #expect(sections[1].title == "Examples")
    }

    @Test("does not promote headings that already have ## prefix")
    func skipsAlreadyPromoted() throws {
        let text = """
            ## Main Idea

            Existing body one.

            ## Examples

            Existing body two.
            """
        let result = StructuredMessageParser.sections(
            from: text,
            autoPromotingHeadings: ["Main Idea", "Examples"]
        )
        let sections = try #require(result)
        #expect(sections.count == 2)
        #expect(sections[0].title == "Main Idea")
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
