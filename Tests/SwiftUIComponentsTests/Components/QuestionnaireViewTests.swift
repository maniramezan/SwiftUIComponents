import Foundation
import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("QuestionnaireView")
struct QuestionnaireViewTests {
    private let options = [
        QuestionnaireOption(id: "a", title: "Alpha"),
        QuestionnaireOption(id: "b", title: "Beta"),
        QuestionnaireOption(id: "c", title: "Gamma"),
    ]
    private let start = Date(timeIntervalSinceReferenceDate: 800_000_000)
    private var end: Date { start.addingTimeInterval(60 * 60 * 24 * 30) }

    private func single(required: Bool = true) -> QuestionnaireQuestion {
        QuestionnaireQuestion(
            id: "single", prompt: "Pick one", isRequired: required, kind: .singleChoice(options: options))
    }

    private func multiple() -> QuestionnaireQuestion {
        QuestionnaireQuestion(
            id: "multi", prompt: "Pick any", isRequired: true, kind: .multipleChoice(options: options))
    }

    private func number(step: Double = 5) -> QuestionnaireQuestion {
        QuestionnaireQuestion(
            id: "number", prompt: "How many?", isRequired: true,
            kind: .number(unitLabel: "u", range: 10...50, step: step))
    }

    private func date(required: Bool = true) -> QuestionnaireQuestion {
        QuestionnaireQuestion(id: "date", prompt: "When?", isRequired: required, kind: .date(range: start...end))
    }

    private func text(required: Bool = true) -> QuestionnaireQuestion {
        QuestionnaireQuestion(id: "text", prompt: "Notes", isRequired: required, kind: .text(placeholder: nil))
    }

    // MARK: - Validation

    @Test("drops duplicate ids, empty choices, and non-finite ranges; dedupes options")
    func validQuestions() {
        let duplicateOptions = QuestionnaireQuestion(
            id: "dupe-options",
            prompt: "Pick",
            kind: .multipleChoice(options: [options[0], options[0], options[1]])
        )
        let questions = [
            single(),
            QuestionnaireQuestion(id: "single", prompt: "Again", kind: .text(placeholder: nil)),
            QuestionnaireQuestion(id: "empty", prompt: "Nothing", kind: .singleChoice(options: [])),
            QuestionnaireQuestion(
                id: "infinite", prompt: "Huge", kind: .number(unitLabel: nil, range: 0...Double.infinity, step: 1)),
            duplicateOptions,
            date(),
            text(),
        ]
        let valid = QuestionnaireFlow.validQuestions(questions)
        #expect(valid.map(\.id) == ["single", "dupe-options", "date", "text"])
        #expect(valid[1].kind == .multipleChoice(options: [options[0], options[1]]))
        #expect(valid[0].prompt == "Pick one")
    }

    @Test("an empty question list stays empty")
    func emptyQuestions() {
        #expect(QuestionnaireFlow.validQuestions([]).isEmpty)
    }

    // MARK: - Paging

    @Test("next and back move one page and stop at the ends")
    func paging() {
        #expect(QuestionnaireFlow.nextIndex(after: 0, count: 3) == 1)
        #expect(QuestionnaireFlow.nextIndex(after: 2, count: 3) == nil)
        #expect(QuestionnaireFlow.previousIndex(before: 1) == 0)
        #expect(QuestionnaireFlow.previousIndex(before: 0) == nil)
        #expect(QuestionnaireFlow.clampedIndex(5, count: 3) == 2)
        #expect(QuestionnaireFlow.clampedIndex(-1, count: 3) == 0)
        #expect(QuestionnaireFlow.clampedIndex(4, count: 0) == 0)
    }

    // MARK: - Required answers

    @Test("required questions block advancing until answered; optional ones never do")
    func canAdvance() {
        #expect(!QuestionnaireFlow.canAdvance(from: single(), answer: nil, now: start))
        #expect(QuestionnaireFlow.canAdvance(from: single(), answer: .choices(["a"]), now: start))
        #expect(!QuestionnaireFlow.canAdvance(from: single(), answer: .choices(["zzz"]), now: start))
        #expect(QuestionnaireFlow.canAdvance(from: single(required: false), answer: nil, now: start))
        #expect(!QuestionnaireFlow.canAdvance(from: text(), answer: .text("   "), now: start))
        #expect(QuestionnaireFlow.canAdvance(from: text(), answer: .text("ok"), now: start))
        #expect(!QuestionnaireFlow.canAdvance(from: number(), answer: .number(.nan), now: start))
        #expect(!QuestionnaireFlow.canAdvance(from: number(), answer: .text("12"), now: start))
    }

    @Test("a required date question can advance on its default day")
    func dateDefault() {
        #expect(QuestionnaireFlow.canAdvance(from: date(), answer: nil, now: start))
        let later = end.addingTimeInterval(60 * 60 * 24 * 10)
        #expect(QuestionnaireFlow.defaultAnswer(for: date(), now: later) == .date(end))
        #expect(QuestionnaireFlow.defaultAnswer(for: text(), now: start) == nil)
    }

    // MARK: - Normalization

    @Test("choice answers keep known ids in option order")
    func normalizeChoices() {
        #expect(QuestionnaireFlow.normalized(.choices(["c", "x", "a"]), for: multiple()) == .choices(["a", "c"]))
        #expect(QuestionnaireFlow.normalized(.choices(["x", "b", "a"]), for: single()) == .choices(["b"]))
        #expect(QuestionnaireFlow.normalized(.choices([]), for: multiple()) == nil)
    }

    @Test("numbers clamp into range and snap to the step")
    func normalizeNumbers() {
        #expect(QuestionnaireFlow.normalized(.number(23), for: number()) == .number(25))
        #expect(QuestionnaireFlow.normalized(.number(999), for: number()) == .number(50))
        #expect(QuestionnaireFlow.normalized(.number(-4), for: number()) == .number(10))
        #expect(QuestionnaireFlow.normalized(.number(23.4), for: number(step: 0)) == .number(23.4))
        #expect(QuestionnaireFlow.normalized(.number(.infinity), for: number()) == nil)
    }

    @Test("dates clamp and text trims")
    func normalizeDatesAndText() {
        let before = start.addingTimeInterval(-100)
        #expect(QuestionnaireFlow.normalized(.date(before), for: date()) == .date(start))
        #expect(QuestionnaireFlow.normalized(.text("  hi \n"), for: text()) == .text("hi"))
        #expect(QuestionnaireFlow.normalized(.date(start), for: text()) == nil)
    }

    @Test("submission keeps only normalized answers to known questions")
    func submission() {
        let questions = [single(), number(), text(required: false)]
        let result = QuestionnaireFlow.submission(
            answers: [
                "single": .choices(["b"]),
                "number": .number(12),
                "text": .text("   "),
                "unknown": .text("drop me"),
            ],
            questions: questions
        )
        #expect(result == ["single": .choices(["b"]), "number": .number(10)])
    }

    // MARK: - Inputs

    @Test("single-choice taps select and deselect")
    func toggleSingle() {
        let first = QuestionnaireFlow.toggling("a", in: nil, options: options, allowsMultiple: false)
        #expect(first == .choices(["a"]))
        #expect(QuestionnaireFlow.toggling("b", in: first, options: options, allowsMultiple: false) == .choices(["b"]))
        #expect(QuestionnaireFlow.toggling("a", in: first, options: options, allowsMultiple: false) == nil)
    }

    @Test("multiple-choice taps toggle and keep option order")
    func toggleMultiple() {
        let one = QuestionnaireFlow.toggling("c", in: nil, options: options, allowsMultiple: true)
        let two = QuestionnaireFlow.toggling("a", in: one, options: options, allowsMultiple: true)
        #expect(two == .choices(["a", "c"]))
        let back = QuestionnaireFlow.toggling("c", in: two, options: options, allowsMultiple: true)
        #expect(back == .choices(["a"]))
        #expect(QuestionnaireFlow.toggling("a", in: back, options: options, allowsMultiple: true) == nil)
        #expect(QuestionnaireFlow.selectedIDs(in: .number(1)).isEmpty)
    }

    @Test("stepping starts from the lower bound and stays in range")
    func stepping() {
        #expect(QuestionnaireFlow.stepped(nil, increment: true, range: 10...50, step: 5) == 10)
        #expect(QuestionnaireFlow.stepped(20, increment: true, range: 10...50, step: 5) == 25)
        #expect(QuestionnaireFlow.stepped(12, increment: false, range: 10...50, step: 5) == 10)
        #expect(QuestionnaireFlow.stepped(49, increment: true, range: 10...50, step: 0) == 50)
    }

    @Test("numbers round-trip through the locale's separators")
    func numberText() {
        let german = Locale(identifier: "de_DE")
        #expect(QuestionnaireFlow.parseNumber("82,5", locale: german) == 82.5)
        #expect(QuestionnaireFlow.formatNumber(1234.5, locale: german) == "1234,5")
        let english = Locale(identifier: "en_US")
        #expect(QuestionnaireFlow.parseNumber(" 7.25 ", locale: english) == 7.25)
        #expect(QuestionnaireFlow.parseNumber("", locale: english) == nil)
        #expect(QuestionnaireFlow.parseNumber("abc", locale: english) == nil)
    }

    // MARK: - Strings

    @Test("package strings resolve in English")
    func strings() {
        #expect(String(localized: Strings.Questionnaire.back) == "Back")
        #expect(String(localized: Strings.Questionnaire.next) == "Next")
        #expect(String(localized: Strings.Questionnaire.done) == "Done")
        #expect(String(localized: Strings.Questionnaire.skip) == "Skip")
        #expect(String(localized: Strings.Questionnaire.optional) == "Optional")
        #expect(String(localized: Strings.Questionnaire.progress(2, 4)) == "Question 2 of 4")
    }

    // MARK: - Rendering

    @Test("renders every question kind and the empty state")
    func rendersVariants() {
        let questions = [single(), multiple(), number(), date(), text(required: false)]
        for question in questions {
            renderForCoverage(
                QuestionnaireView(
                    questions: [question],
                    answers: .constant([:]),
                    onSubmit: { _ in },
                    onSkip: {}
                ),
                size: CGSize(width: 360, height: 640)
            )
        }
        renderForCoverage(
            QuestionnaireView(
                questions: questions,
                answers: .constant(["single": .choices(["a"]), "number": .number(20), "text": .text("hi")]),
                submitTitle: "Finish",
                onSubmit: { _ in }
            ),
            size: CGSize(width: 360, height: 640)
        )
        renderForCoverage(
            QuestionnaireView(questions: [], answers: .constant([:]), onSubmit: { _ in }),
            size: CGSize(width: 360, height: 200)
        )
    }
}
