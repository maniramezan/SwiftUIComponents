import Components
import DesignSystem
import SwiftUI

/// Independent examples make every input reachable without completing earlier questions.
enum QuestionnaireExample: String, CaseIterable, Identifiable {
    case singleChoice = "Single choice"
    case multipleChoice = "Multiple choice"
    case freeText = "Free-form text"
    case boolean = "Boolean choices"
    case number = "Number"
    case date = "Date"
    case customComponent = "Custom component example"
    case ratingScale = "Rating scale"
    case all = "Complete questionnaire"

    var id: String { rawValue }
}

/// Showcases each question kind, option presentation, and caller-supplied content.
struct QuestionnaireDetailView: View {
    @State private var example: QuestionnaireExample
    @State private var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer] = [:]
    @State private var choiceStyle = QuestionnaireChoiceStyle.automatic
    @State private var requiresAnswers = true
    @State private var showsDetail = true
    @State private var allowsSkip = true
    @State private var prompt = ""
    @State private var optionTitles = "Option A\nOption B\nOption C"
    @State private var placeholder = "Write your answer"
    @State private var trueTitle = "Yes"
    @State private var falseTitle = "No"
    @State private var lowerBound = 0.0
    @State private var upperBound = 100.0
    @State private var step = 5.0
    @State private var unitLabel = ""
    @State private var dateRangeMonths = 6
    @State private var submitTitle = ""
    @State private var lastEvent = "None yet"
    @State private var generation = 0
    @Environment(\.designTheme) private var theme

    init(example: QuestionnaireExample = .singleChoice) {
        self._example = State(initialValue: example)
    }

    private var dateRange: ClosedRange<Date> {
        let today = Calendar.current.startOfDay(for: Date())
        let limit = Calendar.current.date(byAdding: .month, value: dateRangeMonths, to: today) ?? today
        return today...limit
    }

    private var questions: [QuestionnaireQuestion] {
        let options = optionTitles.split(separator: "\n").map { QuestionnaireOption(String($0)) }
        let examples: [QuestionnaireExample] =
            example == .all ? QuestionnaireExample.allCases.filter { $0 != .all } : [example]
        return examples.map { item in
            let kind: QuestionnaireQuestionKind
            let defaultPrompt: String
            let detail: String
            switch item {
            case .singleChoice, .all:
                kind = .singleChoice(options: options)
                defaultPrompt = "Which option do you prefer?"
                detail = "Choose one option. Tap it again to clear your answer."
            case .multipleChoice:
                kind = .multipleChoice(options: options)
                defaultPrompt = "Which options apply?"
                detail = "Select every option that applies."
            case .freeText:
                kind = .text(placeholder: placeholder.isEmpty ? nil : placeholder)
                defaultPrompt = "What would you like to add?"
                detail = "Answer in your own words. Multiple lines are supported."
            case .boolean:
                kind = .boolean(trueTitle: trueTitle, falseTitle: falseTitle)
                defaultPrompt = "Would you like to include this option?"
                detail = "Choose Yes or No. Either choice answers the question."
            case .number:
                kind = .number(
                    unitLabel: unitLabel.isEmpty ? nil : unitLabel, range: lowerBound...upperBound, step: step)
                defaultPrompt = "How many items?"
                detail = "Enter a number or use the stepper."
            case .date:
                kind = .date(range: dateRange)
                defaultPrompt = "Which date do you prefer?"
                detail = "The built-in date question starts with today's date."
            case .customComponent:
                kind = .custom
                defaultPrompt = "Which calendar date should be recorded?"
                detail = "This caller-supplied calendar records an answer only after you select or confirm a date."
            case .ratingScale:
                kind = .singleChoice(options: [
                    QuestionnaireOption(id: "1", title: "1 — Very low"),
                    QuestionnaireOption(id: "2", title: "2 — Low"),
                    QuestionnaireOption(id: "3", title: "3 — Moderate"),
                    QuestionnaireOption(id: "4", title: "4 — High"),
                    QuestionnaireOption(id: "5", title: "5 — Very high"),
                ])
                defaultPrompt = "How would you rate this item?"
                detail = "A labeled scale composed from a single-choice question."
            }
            return QuestionnaireQuestion(
                id: item.id,
                prompt: prompt.isEmpty ? defaultPrompt : prompt,
                detail: showsDetail ? detail : nil,
                isRequired: requiresAnswers,
                kind: kind,
                choiceStyle: choiceStyle
            )
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Questionnaire example") {
                ShowcasePicker("Example", selection: $example) {
                    ForEach(QuestionnaireExample.allCases) { item in
                        Text(item.rawValue).tag(item)
                    }
                }

                QuestionnaireView(
                    questions: questions,
                    answers: $answers,
                    submitTitle: submitTitle.isEmpty ? nil : submitTitle,
                    customInput: { question, answer in
                        QuestionnaireShowcaseCalendar(label: question.prompt, range: dateRange, answer: answer)
                    },
                    onSubmit: { submitted in
                        lastEvent = "Submitted \(submitted.count) answer(s)"
                    },
                    onSkip: allowsSkip ? { lastEvent = "Skipped" } : nil
                )
                .id(generation)
                .frame(height: theme.spacing.sixUnits * 12)
                .designCardSurface(showStroke: false)

                Text("Last event: \(lastEvent)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            ShowcaseSection("Question and presentation") {
                ShowcaseTextField("Prompt (empty uses example prompt)", text: $prompt)
                Toggle("Required answers", isOn: $requiresAnswers)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Detail text", isOn: $showsDetail)
                    .toggleStyle(ThemeToggleStyle())
                ShowcasePicker("Choice presentation", selection: $choiceStyle) {
                    Text("Automatic rows").tag(QuestionnaireChoiceStyle.automatic)
                    Text("Bullet rows").tag(QuestionnaireChoiceStyle.bullets)
                    Text("Checkmark rows").tag(QuestionnaireChoiceStyle.checkmarks)
                    Text("Wrapping chips").tag(QuestionnaireChoiceStyle.chips)
                }
                Text("Presentation changes the indicators. The question kind controls single or multiple selection.")
                    .designTextStyle(.caption)
                TextField("Options (one per line)", text: $optionTitles, axis: .vertical)
                    .lineLimit(3...6)
                    .textFieldStyle(.roundedBorder)
                ShowcaseTextField("Free-text placeholder", text: $placeholder)
                ShowcaseTextField("True choice title", text: $trueTitle)
                ShowcaseTextField("False choice title", text: $falseTitle)
            }

            ShowcaseSection("Number and date") {
                Stepper("Lower bound: \(lowerBound.formatted())", value: $lowerBound, in: -100...upperBound)
                Stepper("Upper bound: \(upperBound.formatted())", value: $upperBound, in: lowerBound...1000)
                Stepper("Number step: \(step.formatted())", value: $step, in: 0...100)
                ShowcaseTextField("Number unit", text: $unitLabel)
                Stepper("Date range: \(dateRangeMonths) month(s)", value: $dateRangeMonths, in: 1...24)
            }

            ShowcaseSection("Navigation and answers") {
                Toggle("Skip button", isOn: $allowsSkip)
                    .toggleStyle(ThemeToggleStyle())
                ShowcaseTextField("Submit title (empty uses Done)", text: $submitTitle)
                Button("Restart") { restart() }
                Text(answerSummary)
                    .font(theme.typography.footnote)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
        .onChange(of: example) { _, _ in restart() }
    }

    private func restart() {
        answers = [:]
        lastEvent = "None yet"
        generation += 1
    }

    private var answerSummary: String {
        guard !answers.isEmpty else { return "No answers" }
        return answers.keys.sorted().map { key in "\(key): \(String(describing: answers[key]))" }
            .joined(separator: "\n")
    }
}

/// A caller-owned input that uses the questionnaire's answer binding and navigation.
struct QuestionnaireShowcaseCalendar: View {
    let label: String
    let range: ClosedRange<Date>
    @Binding var answer: QuestionnaireAnswer?
    @Environment(\.designTheme) private var theme

    private var selectedDate: Date {
        guard case .date(let date) = answer else { return range.lowerBound }
        return min(max(date, range.lowerBound), range.upperBound)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            DatePicker(
                label,
                selection: Binding(get: { selectedDate }, set: { answer = .date($0) }),
                in: range,
                displayedComponents: .date
            )
            .datePickerStyle(.graphical)
            .labelsHidden()
            .tint(theme.colors.primary)
            ThemeButton("Use selected date", role: .secondary) {
                answer = .date(selectedDate)
            }
        }
    }
}

#Preview {
    ScrollView {
        QuestionnaireDetailView()
            .padding()
    }
}
