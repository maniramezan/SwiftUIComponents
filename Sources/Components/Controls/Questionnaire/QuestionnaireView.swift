import DesignSystem
import SwiftUI

private typealias QuestionnaireCustomInput = (QuestionnaireQuestion, Binding<QuestionnaireAnswer?>) -> AnyView

/// A paged, one-question-at-a-time questionnaire with a progress bar and Back, Next, and
/// Skip controls.
///
/// Each ``QuestionnaireQuestion`` gets its own page: separate option rows for choices,
/// explicit true/false choices, a field with a stepper for numbers, a calendar for dates,
/// and a multi-line field for text. Choice questions can opt into wrapping chips with
/// ``QuestionnaireQuestion/choiceStyle``. Use the `customInput` initializer for a caller-owned input.
/// Next stays disabled on a required question until it has a valid answer; the last
/// page shows Done instead, which normalizes the answers (see ``QuestionnaireAnswer``),
/// writes them back to `answers`, and passes them to `onSubmit`.
///
/// ```swift
/// @State private var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer] = [:]
///
/// QuestionnaireView(
///     questions: [
///         QuestionnaireQuestion(
///             id: "option",
///             prompt: "Which option do you prefer?",
///             isRequired: true,
///             kind: .singleChoice(options: [QuestionnaireOption("Option A"), QuestionnaireOption("Option B")])
///         ),
///         QuestionnaireQuestion(
///             id: "count",
///             prompt: "How many items?",
///             kind: .number(unitLabel: nil, range: 0...100, step: 1)
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
/// Questions with a repeated identifier, choice questions without options, number/date
/// questions with non-finite bounds, and custom questions without a builder are dropped
/// with a logged fault. The view owns its
/// scroll view, so place it in a fixed-height slot such as a navigation destination rather
/// than inside another vertical `ScrollView`. The progress label, buttons, and "Optional"
/// caption are localized by the package; question text is rendered verbatim.
public struct QuestionnaireView: View {
    private let questions: [QuestionnaireQuestion]
    @Binding private var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer]
    private let submitTitle: String?
    private let onSubmit: ([QuestionnaireQuestion.ID: QuestionnaireAnswer]) -> Void
    private let onSkip: (() -> Void)?
    private let customInput: QuestionnaireCustomInput?

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
        self.customInput = nil
    }

    /// Creates a questionnaire that can include caller-supplied input views.
    ///
    /// - Parameters:
    ///   - questions: Questions in display order. Invalid entries are dropped with a logged fault.
    ///   - answers: Two-way binding to answers keyed by question identifier; normalized on submit.
    ///   - submitTitle: Last-page button title. `nil` uses the package's localized "Done".
    ///   - customInput: Builds the input for each ``QuestionnaireQuestionKind/custom`` question.
    ///     Write a supported answer case through its binding when valid, or `nil` while incomplete.
    ///     The caller owns custom validation, labels, and accessibility. Built-in kinds use their normal inputs.
    ///   - onSubmit: Called with normalized answers once all required questions are answered.
    ///   - onSkip: Optional action that shows a Skip button on every page.
    public init<CustomInput: View>(
        questions: [QuestionnaireQuestion],
        answers: Binding<[QuestionnaireQuestion.ID: QuestionnaireAnswer]>,
        submitTitle: String? = nil,
        @ViewBuilder customInput: @escaping (QuestionnaireQuestion, Binding<QuestionnaireAnswer?>) -> CustomInput,
        onSubmit: @escaping ([QuestionnaireQuestion.ID: QuestionnaireAnswer]) -> Void,
        onSkip: (() -> Void)? = nil
    ) {
        self.questions = QuestionnaireFlow.validQuestions(questions, supportsCustomInput: true)
        self._answers = answers
        self.submitTitle = submitTitle
        self.customInput = { AnyView(customInput($0, $1)) }
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
                    QuestionnairePage(
                        question: question,
                        answer: answerBinding(for: question),
                        customInput: customInput
                    )
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
            guard QuestionnaireFlow.canAdvance(from: question, answer: answers[question.id], now: Date()) else {
                return
            }
            if answers[question.id] == nil, let fallback = QuestionnaireFlow.defaultAnswer(for: question, now: Date()) {
                answers[question.id] = fallback
            }
        }
        if let next = QuestionnaireFlow.nextIndex(after: index, count: questions.count) {
            movesForward = true
            currentIndex = next
            return
        }
        if let unanswered = QuestionnaireFlow.firstUnansweredRequiredIndex(
            answers: answers, questions: questions, now: Date()
        ) {
            movesForward = false
            currentIndex = unanswered
            return
        }
        let submitted = QuestionnaireFlow.submission(answers: answers, questions: questions, now: Date())
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
    let customInput: QuestionnaireCustomInput?

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
            QuestionnaireInput(question: question, answer: $answer, customInput: customInput)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .onAppear { promptIsFocused = true }
    }
}

/// Routes a question to the input for its kind.
private struct QuestionnaireInput: View {
    let question: QuestionnaireQuestion
    @Binding var answer: QuestionnaireAnswer?
    let customInput: QuestionnaireCustomInput?

    var body: some View {
        switch question.kind {
        case .singleChoice(let options):
            QuestionnaireChoiceInput(
                options: options, allowsMultiple: false, style: question.choiceStyle, answer: $answer)
        case .multipleChoice(let options):
            QuestionnaireChoiceInput(
                options: options, allowsMultiple: true, style: question.choiceStyle, answer: $answer)
        case .boolean(let trueTitle, let falseTitle):
            QuestionnaireBooleanInput(
                trueTitle: trueTitle, falseTitle: falseTitle, style: question.choiceStyle, answer: $answer)
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
        case .custom:
            if let customInput {
                customInput(question, $answer)
            }
        }
    }
}

// MARK: - Inputs

/// Separate option rows, or wrapping chips when requested.
private struct QuestionnaireChoiceInput: View {
    let options: [QuestionnaireOption]
    let allowsMultiple: Bool
    let style: QuestionnaireChoiceStyle
    @Binding var answer: QuestionnaireAnswer?

    @Environment(\.designTheme) private var theme

    var body: some View {
        let selected = QuestionnaireFlow.selectedIDs(in: answer)
        let resolvedStyle = QuestionnaireFlow.resolvedChoiceStyle(style, allowsMultiple: allowsMultiple)
        let layout: AnyLayout =
            resolvedStyle == .chips
            ? AnyLayout(FlowLayout(spacing: theme.spacing.oneUnit, lineSpacing: theme.spacing.oneUnit))
            : AnyLayout(VStackLayout(alignment: .leading, spacing: theme.spacing.oneUnit))
        layout {
            ForEach(options) { option in
                QuestionnaireOptionButton(
                    title: option.title,
                    style: resolvedStyle,
                    isSelected: selected.contains(option.id)
                ) {
                    answer = QuestionnaireFlow.toggling(
                        option.id, in: answer, options: options, allowsMultiple: allowsMultiple)
                }
            }
        }
    }
}

/// Uses explicit choices so an unanswered boolean is distinct from `false`.
private struct QuestionnaireBooleanInput: View {
    let trueTitle: String
    let falseTitle: String
    let style: QuestionnaireChoiceStyle
    @Binding var answer: QuestionnaireAnswer?

    var body: some View {
        QuestionnaireChoiceInput(
            options: [
                QuestionnaireOption(id: "true", title: trueTitle),
                QuestionnaireOption(id: "false", title: falseTitle),
            ],
            allowsMultiple: false,
            style: style,
            answer: Binding(
                get: {
                    guard case .boolean(let value) = answer else { return nil }
                    return .choices([value ? "true" : "false"])
                },
                set: { selection in
                    guard case .choices(let ids) = selection, let id = ids.first else {
                        answer = nil
                        return
                    }
                    answer = .boolean(id == "true")
                }
            )
        )
    }
}

/// A full-width option with a decorative indicator, or a compact chip.
private struct QuestionnaireOptionButton: View {
    let title: String
    let style: QuestionnaireChoiceStyle
    let isSelected: Bool
    let action: () -> Void

    @Environment(\.designTheme) private var theme

    var body: some View {
        if style == .chips {
            PillChip(title, isSelected: isSelected, action: action)
        } else {
            Button(action: action) {
                ListRow(
                    title,
                    systemImage: QuestionnaireFlow.choiceSymbol(style: style, isSelected: isSelected),
                    iconTint: isSelected ? theme.colors.primary : theme.colors.textSecondary
                )
                .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                .padding(.vertical, theme.spacing.halfUnit)
                .designInputSurface()
                .overlay {
                    if isSelected {
                        RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                            .strokeBorder(theme.colors.primary, lineWidth: theme.stroke.regular)
                    }
                }
            }
            .buttonStyle(.plain)
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(verbatim: title))
            .accessibilityAddTraits(isSelected ? .isSelected : [])
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
        .onChange(of: answer, initial: true) { _, newAnswer in
            synchronizeText(with: newAnswer)
        }
        .onChange(of: locale) { _, _ in
            synchronizeText(with: answer, force: true)
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

    private func synchronizeText(with answer: QuestionnaireAnswer?, force: Bool = false) {
        let value: Double? = if case .number(let value) = answer { value } else { nil }
        guard force || QuestionnaireFlow.parseNumber(text, locale: locale) != value else { return }
        text = value.map { QuestionnaireFlow.formatNumber($0, locale: locale) } ?? ""
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
                    id: "option",
                    prompt: "Which option do you prefer?",
                    detail: "Pick the closest match.",
                    isRequired: true,
                    kind: .singleChoice(options: [
                        QuestionnaireOption("Option A"), QuestionnaireOption("Option B"),
                        QuestionnaireOption("Option C"),
                    ])
                ),
                QuestionnaireQuestion(
                    id: "count",
                    prompt: "How many items?",
                    kind: .number(unitLabel: nil, range: 0...100, step: 1)
                ),
                QuestionnaireQuestion(
                    id: "date",
                    prompt: "Which date do you prefer?",
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
