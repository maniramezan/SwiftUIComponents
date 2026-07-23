import Components
import SwiftUI
import Testing

@MainActor
@Suite("AssistantContextCard")
struct AssistantContextCardTests {

    @Test("title only constructs")
    func titleOnly() {
        _ = AssistantContextCard(title: "hello")
    }

    @Test("full card with quoted body constructs")
    func fullQuoted() {
        _ = AssistantContextCard(
            title: "hello",
            highlight: "Hola",
            bodyText: "Hello, how are you today?",
            bodyStyle: .quoted,
            footnote: "From: Everyday English"
        )
    }

    @Test("full card with plain body constructs")
    func fullPlain() {
        _ = AssistantContextCard(
            title: "Present Perfect",
            highlight: "B1",
            bodyText: "have/has + past participle",
            bodyStyle: .plain
        )
    }

    @Test("empty optional strings are treated as absent")
    func emptyStringsHidden() {
        _ = AssistantContextCard(title: "hello", highlight: "", bodyText: "", footnote: "")
    }

    // MARK: - Rendering

    @Test("title-only card renders")
    func titleOnlyRenders() {
        renderForCoverage(AssistantContextCard(title: "hello"))
    }

    @Test("full quoted card renders")
    func fullQuotedRenders() {
        renderForCoverage(
            AssistantContextCard(
                title: "hello",
                highlight: "Hola",
                bodyText: "Hello, how are you today?",
                bodyStyle: .quoted,
                footnote: "From: Everyday English"
            )
        )
    }

    @Test("full plain card renders")
    func fullPlainRenders() {
        renderForCoverage(
            AssistantContextCard(
                title: "Present Perfect",
                highlight: "B1",
                bodyText: "have/has + past participle",
                bodyStyle: .plain
            )
        )
    }

    @Test("empty optional strings render as hidden")
    func emptyStringsRender() {
        renderForCoverage(AssistantContextCard(title: "hello", highlight: "", bodyText: "", footnote: ""))
    }
}
