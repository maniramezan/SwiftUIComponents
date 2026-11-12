import Components
import DesignSystem
import SwiftUI

/// Showcases ``QuestionnaireView`` with live controls for which question kinds appear,
/// whether they are required, the skip button, and a custom submit title.
struct QuestionnaireDetailView: View {
    @State private var answers: [QuestionnaireQuestion.ID: QuestionnaireAnswer] = [:]
    @State private var includesSingleChoice = true
    @State private var includesMultipleChoice = true
    @State private var includesNumber = true
    @State private var includesDate = true
    @State private var includesText = true
    @State private var requiresAnswers = true
    @State private var showsDetail = true
    @State private var allowsSkip = true
    @State private var submitTitle = ""
    @State private var lastEvent = "None yet"
    @State private var generation = 0
    @Environment(\.designTheme) private var theme

    private var questions: [QuestionnaireQuestion] {
        var result: [QuestionnaireQuestion] = []
        if includesSingleChoice {
            result.append(
                QuestionnaireQuestion(
                    id: "level",
                    prompt: "How experienced are you?",
                    detail: showsDetail ? "Pick the closest match." : nil,
                    isRequired: requiresAnswers,
                    kind: .singleChoice(options: [
                        QuestionnaireOption("New"), QuestionnaireOption("Some"), QuestionnaireOption("Lots"),
                    ])
                )
            )
        }
        if includesMultipleChoice {
            result.append(
                QuestionnaireQuestion(
                    id: "days",
                    prompt: "Which days work for you?",
                    detail: showsDetail ? "Choose as many as you like." : nil,
                    isRequired: requiresAnswers,
                    kind: .multipleChoice(
                        options: ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"].map(QuestionnaireOption.init)
                    )
                )
            )
        }
        if includesNumber {
            result.append(
                QuestionnaireQuestion(
                    id: "minutes",
                    prompt: "How many minutes a session?",
                    detail: showsDetail ? "Between 5 and 120." : nil,
                    isRequired: requiresAnswers,
                    kind: .number(unitLabel: "min", range: 5...120, step: 5)
                )
            )
        }
        if includesDate {
            let today = Calendar.current.startOfDay(for: Date())
            let limit = Calendar.current.date(byAdding: .month, value: 6, to: today) ?? today
            result.append(
                QuestionnaireQuestion(
                    id: "start",
                    prompt: "When do you want to start?",
                    isRequired: requiresAnswers,
                    kind: .date(range: today...limit)
                )
            )
        }
        if includesText {
            result.append(
                QuestionnaireQuestion(
                    id: "notes",
                    prompt: "Anything else we should know?",
                    isRequired: requiresAnswers,
                    kind: .text(placeholder: "Notes")
                )
            )
        }
        return result
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Configurable questionnaire") {
                QuestionnaireView(
                    questions: questions,
                    answers: $answers,
                    submitTitle: submitTitle.isEmpty ? nil : submitTitle,
                    onSubmit: { submitted in
                        lastEvent = "Submitted \(submitted.count) answer(s)"
                    },
                    onSkip: allowsSkip ? { lastEvent = "Skipped" } : nil
                )
                .id(generation)
                .frame(height: 560)
                .designCardSurface(showStroke: false)

                Text("Last event: \(lastEvent)")
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            ShowcaseSection("Questions") {
                Toggle("Single choice", isOn: $includesSingleChoice)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Multiple choice", isOn: $includesMultipleChoice)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Number", isOn: $includesNumber)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Date", isOn: $includesDate)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Text", isOn: $includesText)
                    .toggleStyle(ThemeToggleStyle())
            }

            ShowcaseSection("Behavior") {
                Toggle("Required answers", isOn: $requiresAnswers)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Detail text", isOn: $showsDetail)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Skip button", isOn: $allowsSkip)
                    .toggleStyle(ThemeToggleStyle())
                TextField("Submit title (empty = Done)", text: $submitTitle)
                    .textFieldStyle(.roundedBorder)
                Button("Restart") {
                    answers = [:]
                    lastEvent = "None yet"
                    generation += 1
                }
            }

            ShowcaseSection("Answers") {
                Text(answerSummary)
                    .font(theme.typography.footnote)
                    .foregroundStyle(theme.colors.textSecondary)
            }
        }
    }

    private var answerSummary: String {
        guard !answers.isEmpty else { return "No answers" }
        return answers.keys.sorted().map { key in "\(key): \(String(describing: answers[key]))" }
            .joined(separator: "\n")
    }
}

#Preview {
    ScrollView {
        QuestionnaireDetailView()
            .padding()
    }
}
