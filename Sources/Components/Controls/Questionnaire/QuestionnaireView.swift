import DesignSystem
import SwiftUI

/// A paged, one-question-at-a-time questionnaire with a progress bar and Back, Next, and
/// Skip controls.
///
/// Each ``QuestionnaireQuestion`` gets its own page: wrapping chips for choice questions,
/// a field with a stepper for numbers, a calendar for dates, and a multi-line field for
/// text. Next stays disabled on a required question until it has a valid answer; the last
/// page shows Done instead, which normalizes the answers (see ``QuestionnaireAnswer``),
/// writes them back to `answers`, and passes them to `onSubmit`.
///
/// ```swift
/// @State private var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer] = [:]
///
/// QuestionnaireView(
///     questions: [
///         QuestionnaireQuestion(
///             id: "level",
///             prompt: "How experienced are you?",
///             isRequired: true,
///             kind: .singleChoice(options: [QuestionnaireOption("New"), QuestionnaireOption("Some")])
///         ),
///         QuestionnaireQuestion(
///             id: "minutes",
///             prompt: "How many minutes a day?",
///             kind: .number(unitLabel: "min", range: 5...120, step: 5)
///         ),
///     ],
///     answers: $answers,
///     onSubmit: { submitted in
///         save(submitted)
///     },
///     onSkip: {
///         skipQuestions()
///     }
/// )
/// ```
///
/// Questions with a repeated identifier, choice questions without options, and number
/// questions with non-finite bounds are dropped with a logged fault. The view owns its
/// scroll view, so place it in a fixed-height slot such as a navigation destination rather
/// than inside another vertical `ScrollView`. The progress label, buttons, and "Optional"
/// caption are localized by the package; question text is rendered verbatim.
public struct QuestionnaireView: View {
    private let questions: [QuestionnaireQuestion]
    @Binding private var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer]
    private let submitTitle: String?
    private let onSubmit: ([QuestionnaireQuestion.ID: QuestionnaireAnswer]) -> Void
    private let onSkip: (() -> Void)?

    @State private var currentIndex = 0
    @State private var movesForward = true
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates a questionnaire.
    ///
    /// - Parameters:
    ///   - questions: The questions in display order. Invalid entries are dropped with a
    ///     logged fault.
    ///   - answers: Two-way binding to the answers keyed by question identifier. Seed it to
    ///     prefill answers. On submit it is replaced with the normalized answers.
    ///   - submitTitle: Title of the button on the last page. When `nil` (the default), the
    ///     package's localized "Done" is used.
    ///   - onSubmit: Called from the last page with the normalized answers. Unanswered
    ///     optional questions have no entry.
    ///   - onSkip: When non-`nil`, a Skip button is shown on every page and calls this to
    ///     abandon the remaining questions. Defaults to `nil`.
    public init(
        questions: [QuestionnaireQuestion],
        answers: Binding<[QuestionnaireQuestion.ID: QuestionnaireAnswer]>,
        submitTitle: String? = nil,
        onSubmit: @escaping ([QuestionnaireQuestion.ID: QuestionnaireAnswer]) -> Void,
        onSkip: (() -> Void)? = nil
    ) {
        self.questions = QuestionnaireFlow.validQuestions(questions)
        self._answers = answers
        self.submitTitle = submitTitle
        self.onSubmit = onSubmit
        self.onSkip = onSkip
    }

    /// The progress header, the current question page, and the navigation controls.
    public var body: some View {
        let index = QuestionnaireFlow.clampedIndex(currentIndex, count: questions.count)
        let question = questions.indices.contains(index) ? questions[index] : nil
        let canAdvance =
            question.map {
                QuestionnaireFlow.canAdvance(from: $0, answer: answers[$0.id], now: Date())
            } ?? true

        VStack(spacing: theme.spacing.twoUnits) {
            if !questions.isEmpty {
                QuestionnaireProgressHeader(index: index, count: questions.count)
                    .padding(.horizontal, theme.spacing.twoUnits)
            }

            ScrollView {
                if let question {
                    QuestionnairePage(question: question, answer: answerBinding(for: question))
                        .id(question.id)
                        .transition(pageTransition)
                        .padding(.horizontal, theme.spacing.twoUnits)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            QuestionnaireControls(
                canGoBack: QuestionnaireFlow.previousIndex(before: index) != nil,
                isLastPage: QuestionnaireFlow.nextIndex(after: index, count: questions.count) == nil,
                canAdvance: canAdvance,
                submitTitle: submitTitle ?? String(localized: Strings.Questionnaire.done),
                showsSkip: onSkip != nil,
                onBack: { goBack(from: index) },
                onAdvance: { advance(from: index) },
                onSkip: { onSkip?() }
            )
            .padding(.horizontal, theme.spacing.twoUnits)
        }
        .padding(.vertical, theme.spacing.twoUnits)
        .animation(theme.motion.animation(reducingMotion: reduceMotion), value: index)
    }

    private var pageTransition: AnyTransition {
        guard !reduceMotion else { return .opacity }
        return .asymmetric(
            insertion: .move(edge: movesForward ? .trailing : .leading).combined(with: .opacity),
            removal: .opacity
        )
    }

    private func answerBinding(for question: QuestionnaireQuestion) -> Binding<QuestionnaireAnswer?> {
        Binding(
            get: { answers[question.id] },
            set: { answers[question.id] = $0 }
        )
    }

    private func goBack(from index: Int) {
        guard let previous = QuestionnaireFlow.previousIndex(before: index) else { return }
        movesForward = false
        currentIndex = previous
    }

    private func advance(from index: Int) {
        if questions.indices.contains(index) {
            let question = questions[index]
            if answers[question.id] == nil, let fallback = QuestionnaireFlow.defaultAnswer(for: question, now: Date()) {
                answers[question.id] = fallback
            }
        }
        if let next = QuestionnaireFlow.nextIndex(after: index, count: questions.count) {
            movesForward = true
            currentIndex = next
            return
        }
        let submitted = QuestionnaireFlow.submission(answers: answers, questions: questions)
        answers = submitted
        onSubmit(submitted)
    }
}

// MARK: - Header

/// "Question N of M" above a themed progress bar.
private struct QuestionnaireProgressHeader: View {
    let index: Int
    let count: Int

    var body: some View {
        ProgressView(value: Double(index + 1), total: Double(max(count, 1))) {
            Text(Strings.Questionnaire.progress(index + 1, count))
        }
        .progressViewStyle(ThemeProgressViewStyle())
    }
}

// MARK: - Page

/// The prompt, detail, optional caption, and input for one question.
private struct QuestionnairePage: View {
    let question: QuestionnaireQuestion
    @Binding var answer: QuestionnaireAnswer?

    @Environment(\.designTheme) private var theme
    @AccessibilityFocusState private var promptIsFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
                Text(question.prompt)
                    .font(theme.typography.title3Semibold)
                    .foregroundStyle(theme.colors.textPrimary)
                    .fixedSize(horizontal: false, vertical: true)
                    .accessibilityAddTraits(.isHeader)
                    .accessibilityFocused($promptIsFocused)
                if let detail = question.detail, !detail.isEmpty {
                    Text(detail)
                        .font(theme.typography.subheadline)
                        .foregroundStyle(theme.colors.textSecondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                if !question.isRequired {
                    Text(Strings.Questionnaire.optional)
                        .font(theme.typography.caption)
                        .foregroundStyle(theme.colors.textTertiary)
                }
            }
            QuestionnaireInput(question: question, answer: $answer)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { promptIsFocused = true }
    }
}

/// Routes a question to the input for its kind.
private struct QuestionnaireInput: View {
    let question: QuestionnaireQuestion
    @Binding var answer: QuestionnaireAnswer?

    var body: some View {
        switch question.kind {
        case .singleChoice(let options):
            QuestionnaireChoiceInput(options: options, allowsMultiple: false, answer: $answer)
        case .multipleChoice(let options):
            QuestionnaireChoiceInput(options: options, allowsMultiple: true, answer: $answer)
        case .number(let unitLabel, let range, let step):
            QuestionnaireNumberInput(
                label: question.prompt,
                unitLabel: unitLabel,
                range: range,
                step: step,
                answer: $answer
            )
        case .date(let range):
            QuestionnaireDateInput(label: question.prompt, range: range, question: question, answer: $answer)
        case .text(let placeholder):
            QuestionnaireTextInput(label: question.prompt, placeholder: placeholder, answer: $answer)
        }
    }
}

// MARK: - Inputs

/// Wrapping option chips for single- and multiple-choice questions.
private struct QuestionnaireChoiceInput: View {
    let options: [QuestionnaireOption]
    let allowsMultiple: Bool
    @Binding var answer: QuestionnaireAnswer?

    @Environment(\.designTheme) private var theme

    var body: some View {
        let selected = QuestionnaireFlow.selectedIDs(in: answer)
        FlowLayout(spacing: theme.spacing.oneUnit, lineSpacing: theme.spacing.oneUnit) {
            ForEach(options) { option in
                PillChip(option.title, isSelected: selected.contains(option.id)) {
                    answer = QuestionnaireFlow.toggling(
                        option.id,
                        in: answer,
                        options: options,
                        allowsMultiple: allowsMultiple
                    )
                }
            }
        }
    }
}

/// A numeric field with an optional unit label and a stepper.
private struct QuestionnaireNumberInput: View {
    let label: String
    let unitLabel: String?
    let range: ClosedRange<Double>
    let step: Double
    @Binding var answer: QuestionnaireAnswer?

    @State private var text = ""
    @Environment(\.designTheme) private var theme
    @Environment(\.locale) private var locale

    var body: some View {
        HStack(spacing: theme.spacing.oneAndHalfUnits) {
            HStack(spacing: theme.spacing.oneUnit) {
                TextField(label, text: $text, prompt: Text(verbatim: ""))
                    .font(theme.typography.field)
                    .foregroundStyle(theme.colors.textPrimary)
                    .modifier(QuestionnaireDecimalKeyboard())
                if let unitLabel, !unitLabel.isEmpty {
                    Text(unitLabel)
                        .font(theme.typography.body)
                        .foregroundStyle(theme.colors.textSecondary)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, theme.spacing.oneAndHalfUnits)
            .frame(minHeight: theme.motion.minimumHitTarget)
            .designInputSurface()
            .accessibilityElement(children: .combine)
            .accessibilityValue(Text(verbatim: [text, unitLabel ?? ""].joined(separator: " ")))

            Stepper(label) {
                setValue(QuestionnaireFlow.stepped(currentValue, increment: true, range: range, step: step))
            } onDecrement: {
                setValue(QuestionnaireFlow.stepped(currentValue, increment: false, range: range, step: step))
            }
            .labelsHidden()
        }
        .onAppear {
            if case .number(let value) = answer {
                text = QuestionnaireFlow.formatNumber(value, locale: locale)
            }
        }
        .onChange(of: text) { _, newText in
            let parsed = QuestionnaireFlow.parseNumber(newText, locale: locale)
            let current: Double? = if case .number(let value) = answer { value } else { nil }
            if parsed != current {
                answer = parsed.map { .number($0) }
            }
        }
    }

    private var currentValue: Double? {
        if case .number(let value) = answer { return value }
        return QuestionnaireFlow.parseNumber(text, locale: locale)
    }

    private func setValue(_ value: Double) {
        answer = .number(value)
        text = QuestionnaireFlow.formatNumber(value, locale: locale)
    }
}

/// Shows a decimal keyboard where the platform has one.
private struct QuestionnaireDecimalKeyboard: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
            content.keyboardType(.decimalPad)
        #else
            content
        #endif
    }
}

/// A calendar picker for a date question.
private struct QuestionnaireDateInput: View {
    let label: String
    let range: ClosedRange<Date>
    let question: QuestionnaireQuestion
    @Binding var answer: QuestionnaireAnswer?

    @Environment(\.designTheme) private var theme

    var body: some View {
        DatePicker(
            label,
            selection: Binding(
                get: {
                    let shown = QuestionnaireFlow.effectiveAnswer(answer, for: question, now: Date())
                    if case .date(let date) = shown { return date }
                    return range.lowerBound
                },
                set: { answer = .date($0) }
            ),
            in: range,
            displayedComponents: .date
        )
        .datePickerStyle(.graphical)
        .labelsHidden()
        .tint(theme.colors.primary)
    }
}

/// A multi-line field for a free-form text question.
private struct QuestionnaireTextInput: View {
    let label: String
    let placeholder: String?
    @Binding var answer: QuestionnaireAnswer?

    @Environment(\.designTheme) private var theme

    var body: some View {
        TextField(
            label,
            text: Binding(
                get: {
                    if case .text(let text) = answer { return text }
                    return ""
                },
                set: { answer = $0.isEmpty ? nil : .text($0) }
            ),
            prompt: placeholder.map { Text($0) },
            axis: .vertical
        )
        .lineLimit(3, reservesSpace: true)
        .font(theme.typography.field)
        .foregroundStyle(theme.colors.textPrimary)
        .padding(theme.spacing.oneAndHalfUnits)
        .designInputSurface()
    }
}

// MARK: - Controls

/// Back, Next/Done, and Skip buttons along the bottom of the questionnaire.
private struct QuestionnaireControls: View {
    let canGoBack: Bool
    let isLastPage: Bool
    let canAdvance: Bool
    let submitTitle: String
    let showsSkip: Bool
    let onBack: () -> Void
    let onAdvance: () -> Void
    let onSkip: () -> Void

    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(spacing: theme.spacing.oneUnit) {
            HStack(spacing: theme.spacing.oneAndHalfUnits) {
                if canGoBack {
                    ThemeButton(String(localized: Strings.Questionnaire.back), role: .secondary, action: onBack)
                }
                ThemeButton(
                    isLastPage ? submitTitle : String(localized: Strings.Questionnaire.next),
                    action: onAdvance
                )
                .disabled(!canAdvance)
            }
            if showsSkip {
                ThemeButton(String(localized: Strings.Questionnaire.skip), role: .tertiary, action: onSkip)
            }
        }
    }
}

#Preview("Questionnaire") {
    @Previewable @State var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer] = [:]

    PreviewContent { _ in
        QuestionnaireView(
            questions: [
                QuestionnaireQuestion(
                    id: "level",
                    prompt: "How experienced are you?",
                    detail: "Pick the closest match.",
                    isRequired: true,
                    kind: .singleChoice(options: [
                        QuestionnaireOption("New"), QuestionnaireOption("Some"), QuestionnaireOption("Lots"),
                    ])
                ),
                QuestionnaireQuestion(
                    id: "minutes",
                    prompt: "How many minutes a day?",
                    kind: .number(unitLabel: "min", range: 5...120, step: 5)
                ),
                QuestionnaireQuestion(
                    id: "start",
                    prompt: "When do you want to start?",
                    kind: .date(range: Date()...Date().addingTimeInterval(60 * 60 * 24 * 90))
                ),
                QuestionnaireQuestion(id: "notes", prompt: "Anything else?", kind: .text(placeholder: "Notes")),
            ],
            answers: $answers,
            onSubmit: { _ in },
            onSkip: {}
        )
    }
}
