import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("AvatarView")
struct AvatarViewTests {

    @Test("takes the first and last word initials, uppercased")
    func twoWordInitials() {
        #expect(AvatarView.initials(from: "ada lovelace") == "AL")
        #expect(AvatarView.initials(from: "Mary Ann Evans") == "ME")
    }

    @Test("uses a single initial for a one-word name")
    func oneWordInitial() {
        #expect(AvatarView.initials(from: "Cher") == "C")
    }

    @Test("skips punctuation, extra whitespace, and non-letter words")
    func ignoresNonLetters() {
        #expect(AvatarView.initials(from: "  Jean-Luc   Picard ") == "JP")
        #expect(AvatarView.initials(from: "🙂 Sam") == "S")
        #expect(AvatarView.initials(from: "42 Team") == "T")
    }

    @Test("returns no initials when there are no letters")
    func emptyInitials() {
        #expect(AvatarView.initials(from: "").isEmpty)
        #expect(AvatarView.initials(from: "123 !!").isEmpty)
    }

    @Test("renders monogram, placeholder, and image variants at every size")
    func rendersVariants() {
        renderForCoverage(
            HStack {
                ForEach(AvatarView.Size.allCases, id: \.self) { size in
                    AvatarView(name: "Ada Lovelace", size: size)
                    AvatarView(name: "", size: size)
                    AvatarView(name: "Image", image: Image(systemName: "photo"), size: size)
                }
            }
        )
    }
}
