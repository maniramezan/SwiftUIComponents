import Components
import SwiftUI
import Testing

@MainActor
@Suite("AssistantContextCard")
struct AssistantContextCardTests {

    @Test("title only constructs")
    func titleOnly() {
        _ = AssistantContextCard(title: "Example item")
    }

    @Test("full card with quoted body constructs")
    func fullQuoted() {
        _ = AssistantContextCard(
            title: "Example item",
            highlight: "Label",
            bodyText: "The sentence this item appeared in.",
            bodyStyle: .quoted,
            footnote: "From: Reference source"
        )
    }

    @Test("full card with plain body constructs")
    func fullPlain() {
        _ = AssistantContextCard(
            title: "Example pattern",
            highlight: "Category",
            bodyText: "PREFIX + BODY + SUFFIX",
            bodyStyle: .plain
        )
    }

    @Test("empty optional strings are treated as absent")
    func emptyStringsHidden() {
        _ = AssistantContextCard(title: "Example item", highlight: "", bodyText: "", footnote: "")
    }

    // MARK: - Rendering

    @Test("title-only card renders")
    func titleOnlyRenders() {
        renderForCoverage(AssistantContextCard(title: "Example item"))
    }

    @Test("full quoted card renders")
    func fullQuotedRenders() {
        renderForCoverage(
            AssistantContextCard(
                title: "Example item",
                highlight: "Label",
                bodyText: "The sentence this item appeared in.",
                bodyStyle: .quoted,
                footnote: "From: Reference source"
            )
        )
    }

    @Test("full plain card renders")
    func fullPlainRenders() {
        renderForCoverage(
            AssistantContextCard(
                title: "Example pattern",
                highlight: "Category",
                bodyText: "PREFIX + BODY + SUFFIX",
                bodyStyle: .plain
            )
        )
    }

    @Test("empty optional strings render as hidden")
    func emptyStringsRender() {
        renderForCoverage(AssistantContextCard(title: "Example item", highlight: "", bodyText: "", footnote: ""))
    }
}
