import Foundation
import SwiftUI
import TestCommonsUI
import Testing

@testable import Components

#if canImport(AppKit)
    import AppKit
#endif

@MainActor
@Suite("QuestionnaireView", .serialized)
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

    @Test("repairing duplicate choices preserves their presentation and metadata")
    func repairedChoiceStyle() throws {
        let question = QuestionnaireQuestion(
            id: "choices", prompt: "Options", detail: "Details", isRequired: true,
            kind: .singleChoice(options: [options[0], options[0]]), choiceStyle: .chips)
        let repaired = try #require(QuestionnaireFlow.validQuestions([question]).first)
        #expect(repaired.choiceStyle == .chips)
        #expect(repaired.isRequired)
        #expect(repaired.detail == "Details")
        #expect(repaired.kind == .singleChoice(options: [options[0]]))
    }

    @Test("custom questions require a renderer and non-finite date ranges are dropped")
    func validatesCustomAndDates() {
        let custom = QuestionnaireQuestion(id: "custom", prompt: "Custom", kind: .custom)
        let invalidDate = QuestionnaireQuestion(
            id: "date", prompt: "Date",
            kind: .date(range: start...Date(timeIntervalSinceReferenceDate: .infinity)))
        #expect(QuestionnaireFlow.validQuestions([custom, invalidDate]).isEmpty)
        #expect(QuestionnaireFlow.validQuestions([custom], supportsCustomInput: true) == [custom])
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

    @Test("submission revisits required questions invalidated after leaving their page")
    func revalidatesEarlierRequiredAnswers() {
        let questions = [single(), text()]
        #expect(
            QuestionnaireFlow.firstUnansweredRequiredIndex(
                answers: ["single": .choices(["removed"]), "text": .text("Complete")],
                questions: questions, now: start) == 0)
        #expect(
            QuestionnaireFlow.firstUnansweredRequiredIndex(
                answers: ["single": .choices(["a"]), "text": .text(" \n")],
                questions: questions, now: start) == 1)
        #expect(
            QuestionnaireFlow.firstUnansweredRequiredIndex(
                answers: ["single": .choices(["a"]), "text": .text("Complete")],
                questions: questions, now: start) == nil)
    }

    @Test("booleans require an explicit answer and false is valid")
    func booleans() {
        let question = QuestionnaireQuestion(
            id: "boolean", prompt: "Include?", isRequired: true, kind: .boolean(trueTitle: "Yes", falseTitle: "No"))
        #expect(QuestionnaireFlow.validQuestions([question]) == [question])
        #expect(!QuestionnaireFlow.canAdvance(from: question, answer: nil, now: start))
        #expect(QuestionnaireFlow.canAdvance(from: question, answer: .boolean(false), now: start))
        #expect(QuestionnaireFlow.canAdvance(from: question, answer: .boolean(true), now: start))
        #expect(!QuestionnaireFlow.canAdvance(from: question, answer: .choices(["false"]), now: start))
        #expect(QuestionnaireFlow.defaultAnswer(for: question, now: start) == nil)
        #expect(
            QuestionnaireFlow.submission(answers: [question.id: .boolean(false)], questions: [question], now: start)
                == [question.id: .boolean(false)])
    }

    @Test("custom inputs normalize supported answer cases without assuming a default")
    func customAnswers() {
        let question = QuestionnaireQuestion(id: "custom", prompt: "Custom", isRequired: true, kind: .custom)
        #expect(!QuestionnaireFlow.canAdvance(from: question, answer: nil, now: start))
        #expect(QuestionnaireFlow.defaultAnswer(for: question, now: start) == nil)
        #expect(QuestionnaireFlow.normalized(.boolean(false), for: question) == .boolean(false))
        #expect(QuestionnaireFlow.normalized(.text("  Answer\n"), for: question) == .text("Answer"))
        #expect(QuestionnaireFlow.normalized(.text(" \n"), for: question) == nil)
        #expect(QuestionnaireFlow.normalized(.number(0), for: question) == .number(0))
        #expect(QuestionnaireFlow.normalized(.number(.infinity), for: question) == nil)
        #expect(QuestionnaireFlow.normalized(.date(start), for: question) == .date(start))
        #expect(
            QuestionnaireFlow.normalized(.date(Date(timeIntervalSinceReferenceDate: .infinity)), for: question) == nil)
        #expect(QuestionnaireFlow.normalized(.choices(["b", "a", "b"]), for: question) == .choices(["b", "a"]))
        #expect(QuestionnaireFlow.normalized(.choices([]), for: question) == nil)
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
        #expect(QuestionnaireFlow.normalized(.number(23.4), for: number(step: .infinity)) == .number(23.4))
        #expect(QuestionnaireFlow.normalized(.number(23.4), for: number(step: .nan)) == .number(23.4))
        let largest = Double.greatestFiniteMagnitude
        #expect(QuestionnaireFlow.snapped(largest, range: -largest...largest, step: 1) == largest)
    }

    @Test("dates clamp and text trims")
    func normalizeDatesAndText() {
        let before = start.addingTimeInterval(-100)
        #expect(QuestionnaireFlow.normalized(.date(before), for: date()) == .date(start))
        #expect(QuestionnaireFlow.normalized(.text("  hi \n"), for: text()) == .text("hi"))
        #expect(QuestionnaireFlow.normalized(.date(start), for: text()) == nil)
        #expect(
            QuestionnaireFlow.normalized(.date(Date(timeIntervalSinceReferenceDate: .infinity)), for: date()) == nil)
        #expect(QuestionnaireFlow.effectiveAnswer(.date(before), for: date(), now: start) == .date(start))
        #expect(QuestionnaireFlow.effectiveAnswer(.text("wrong kind"), for: date(), now: end) == .date(end))
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
            questions: questions,
            now: start
        )
        #expect(result == ["single": .choices(["b"]), "number": .number(10)])
    }

    @Test("submission records the date default when a caller clears or replaces an earlier date answer")
    func submissionPreservesRequiredDate() {
        let question = date()
        #expect(
            QuestionnaireFlow.submission(answers: [:], questions: [question], now: start)
                == [question.id: .date(start)])
        #expect(
            QuestionnaireFlow.submission(answers: [question.id: .text("wrong kind")], questions: [question], now: end)
                == [question.id: .date(end)])
    }

    // MARK: - Inputs

    @Test("single-choice taps select and deselect")
    func toggleSingle() {
        let first = QuestionnaireFlow.toggling("a", in: nil, options: options, allowsMultiple: false)
        #expect(first == .choices(["a"]))
        #expect(QuestionnaireFlow.toggling("b", in: first, options: options, allowsMultiple: false) == .choices(["b"]))
        #expect(QuestionnaireFlow.toggling("a", in: first, options: options, allowsMultiple: false) == nil)
        #expect(QuestionnaireFlow.toggling("unknown", in: first, options: options, allowsMultiple: false) == first)
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
        #expect(QuestionnaireFlow.stepped(20, increment: true, range: 10...50, step: .infinity) == 21)
        #expect(QuestionnaireFlow.stepped(20, increment: false, range: 10...50, step: .nan) == 19)
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
        let preciseValue = 0.12345678901234567
        let formatted = QuestionnaireFlow.formatNumber(preciseValue, locale: english)
        #expect(QuestionnaireFlow.parseNumber(formatted, locale: english) == preciseValue)
    }

    @Test("automatic choice presentation uses rows and explicit styles preserve selection semantics")
    func choicePresentation() {
        #expect(QuestionnaireFlow.resolvedChoiceStyle(.automatic, allowsMultiple: false) == .bullets)
        #expect(QuestionnaireFlow.resolvedChoiceStyle(.automatic, allowsMultiple: true) == .checkmarks)
        for style in [QuestionnaireChoiceStyle.bullets, .checkmarks, .chips] {
            #expect(QuestionnaireFlow.resolvedChoiceStyle(style, allowsMultiple: false) == style)
            #expect(QuestionnaireFlow.resolvedChoiceStyle(style, allowsMultiple: true) == style)
        }
        #expect(QuestionnaireFlow.choiceSymbol(style: .bullets, isSelected: false) == "circle")
        #expect(QuestionnaireFlow.choiceSymbol(style: .bullets, isSelected: true) == "largecircle.fill.circle")
        #expect(QuestionnaireFlow.choiceSymbol(style: .checkmarks, isSelected: false) == "square")
        #expect(QuestionnaireFlow.choiceSymbol(style: .checkmarks, isSelected: true) == "checkmark.square.fill")
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

    @Test(
        "renders choices in every style with selected and unselected rows", arguments: QuestionnaireChoiceStyle.allCases
    )
    func rendersChoiceStyles(style: QuestionnaireChoiceStyle) {
        for kind in [
            QuestionnaireQuestionKind.singleChoice(options: options), .multipleChoice(options: options),
            .boolean(trueTitle: "Yes", falseTitle: "No"),
        ] {
            let question = QuestionnaireQuestion(id: "choice", prompt: "Options", kind: kind, choiceStyle: style)
            let answer: QuestionnaireAnswer = if case .boolean = kind { .boolean(false) } else { .choices(["a"]) }
            renderForCoverage(
                QuestionnaireView(questions: [question], answers: .constant([question.id: answer]), onSubmit: { _ in }),
                size: CGSize(width: 360, height: 640))
        }
    }

    @Test("renders caller-supplied inputs and preserves their answer binding")
    func rendersCustomInput() {
        let question = QuestionnaireQuestion(id: "custom", prompt: "Custom", kind: .custom)
        var answers: [String: QuestionnaireAnswer] = [:]
        var receivedQuestion: QuestionnaireQuestion?
        var receivedBinding: Binding<QuestionnaireAnswer?>?
        renderForCoverage(
            QuestionnaireView(
                questions: [question], answers: Binding(get: { answers }, set: { answers = $0 }),
                customInput: { question, answer in
                    Color.clear.onAppear {
                        receivedQuestion = question
                        receivedBinding = answer
                    }
                },
                onSubmit: { _ in }),
            size: CGSize(width: 360, height: 640))
        #expect(receivedQuestion == question)
        receivedBinding?.wrappedValue = .boolean(false)
        #expect(answers == [question.id: .boolean(false)])
    }

    @Test("a visible numeric field reflects externally replaced answers without losing precision")
    func numberReflectsBindingChanges() throws {
        let question = number(step: 0)
        let makeView: (Double) -> QuestionnaireView = { value in
            QuestionnaireView(
                questions: [question], answers: .constant([question.id: .number(value)]), onSubmit: { _ in })
        }
        let host = HostedView(makeView(20.1234567), size: CGSize(width: 360, height: 300))
        defer { host.close() }
        #expect(host.waitForStableRender(timeout: .seconds(2), minimumFrames: 3, requiredStableFrames: 2))
        let before = try #require(host.renderPNG())
        host.hosting.rootView = makeView(40.7654321)
        #expect(host.waitForStableRender(timeout: .seconds(2), minimumFrames: 3, requiredStableFrames: 2))
        #expect(host.rendersDifferently(from: before))
    }

    #if canImport(AppKit)
        @Test("negative caller-provided answers keep their sign until submission clamps them")
        func preservesNegativeAnswersOutsideNonnegativeRange() throws {
            let model = QuestionnaireNumericTestModel()
            let question = number(step: 0)
            model.answers[question.id] = .number(-40)
            let host = HostedView(
                QuestionnaireNumericTestView(question: question, model: model),
                size: CGSize(width: 360, height: 300))
            defer { host.close() }
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            let field = try #require(editableTextField(in: host.hosting))
            #expect(field.stringValue == "-40")
            #expect(model.answers[question.id] == .number(-40))
            let answer = try #require(model.answers[question.id])
            #expect(QuestionnaireFlow.normalized(answer, for: question) == .number(10))

            model.answers[question.id] = .number(-30)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == "-30")
            #expect(model.answers[question.id] == .number(-30))

            try replaceText("", in: field, window: host.window)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            try replaceText("-20", in: field, window: host.window)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == "20")
            #expect(model.answers[question.id] == .number(20))
        }

        @Test(
            "numeric questions filter mixed input before parsing without losing localized decimals",
            arguments: [
                ("en_US", "-1a2.5!", "-12.5"),
                ("de_DE", "-1a2,5!", "-12,5"),
                ("ar_EG", "؜-١a٢٫٥!", "-١٢٫٥"),
            ])
        func filtersNumberInput(localeIdentifier: String, input: String, expectedText: String) throws {
            let model = QuestionnaireNumericTestModel()
            model.locale = Locale(identifier: localeIdentifier)
            let question = QuestionnaireQuestion(
                id: "number", prompt: "Value", isRequired: true,
                kind: .number(unitLabel: nil, range: -100...100, step: 0))
            let host = HostedView(
                QuestionnaireNumericTestView(question: question, model: model),
                size: CGSize(width: 360, height: 300))
            defer { host.close() }
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            let field = try #require(editableTextField(in: host.hosting))

            try replaceText(input, in: field, window: host.window)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == expectedText)
            #expect(model.answers[question.id] == .number(-12.5))

            try replaceText(expectedText + "x", in: field, window: host.window)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == expectedText)
            #expect(model.answers[question.id] == .number(-12.5))

            try replaceText("abc", in: field, window: host.window)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue.isEmpty)
            #expect(model.answers[question.id] == nil)
            #expect(!QuestionnaireFlow.canAdvance(from: question, answer: model.answers[question.id], now: start))
        }

        @Test("nonnegative numeric questions remove minus signs and preserve values across locale changes")
        func filtersNonnegativeInputAndPreservesLocaleChanges() throws {
            let model = QuestionnaireNumericTestModel()
            let question = QuestionnaireQuestion(
                id: "number", prompt: "Value", kind: .number(unitLabel: nil, range: 0...100, step: 0))
            let host = HostedView(
                QuestionnaireNumericTestView(question: question, model: model),
                size: CGSize(width: 360, height: 300))
            defer { host.close() }
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            let field = try #require(editableTextField(in: host.hosting))

            try replaceText("-12a.5", in: field, window: host.window)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == "12.5")
            #expect(model.answers[question.id] == .number(12.5))

            model.locale = Locale(identifier: "de_DE")
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == "12,5")
            #expect(model.answers[question.id] == .number(12.5))

            model.answers[question.id] = .number(40.7654321)
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == "40,7654321")

            model.locale = Locale(identifier: "en_US")
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(field.stringValue == "40.7654321")
            #expect(model.answers[question.id] == .number(40.7654321))
        }
    #endif
}

@MainActor
@Observable
private final class QuestionnaireNumericTestModel {
    var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer] = [:]
    var locale = Locale(identifier: "en_US")
}

private struct QuestionnaireNumericTestView: View {
    let question: QuestionnaireQuestion
    @Bindable var model: QuestionnaireNumericTestModel

    var body: some View {
        QuestionnaireView(questions: [question], answers: $model.answers, onSubmit: { _ in })
            .environment(\.locale, model.locale)
    }
}
