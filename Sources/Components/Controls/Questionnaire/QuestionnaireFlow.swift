import Foundation
import OSLog

/// Pure paging, validation, and normalization rules for ``QuestionnaireView``, kept
/// separate so tests can call them directly.
enum QuestionnaireFlow {
    nonisolated private static var logger: Logger {
        Logger(subsystem: "com.swiftuicomponents", category: "Questionnaire")
    }

    // MARK: - Input validation

    /// Removes questions the view cannot render and repairs ones it can.
    ///
    /// Drops a question whose identifier repeats an earlier one, a choice question with
    /// no options, a number or date question with non-finite bounds, and a custom question
    /// without a renderer. Repeated option
    /// identifiers inside a choice question keep only their first occurrence. Every
    /// repair logs a fault, since it signals caller misuse.
    nonisolated static func validQuestions(
        _ questions: [QuestionnaireQuestion],
        supportsCustomInput: Bool = false
    ) -> [QuestionnaireQuestion] {
        var seenIDs = Set<String>()
        var result: [QuestionnaireQuestion] = []
        for question in questions {
            guard seenIDs.insert(question.id).inserted else {
                logger.fault("Questionnaire dropped a question with a duplicate id")
                continue
            }
            switch question.kind {
            case .singleChoice(let options), .multipleChoice(let options):
                let unique = uniqueOptions(options)
                guard !unique.isEmpty else {
                    logger.fault("Questionnaire dropped a choice question with no options")
                    continue
                }
                if unique.count != options.count {
                    logger.fault("Questionnaire removed duplicate option ids from a choice question")
                }
                let kind: QuestionnaireQuestionKind =
                    if case .singleChoice = question.kind {
                        .singleChoice(options: unique)
                    } else {
                        .multipleChoice(options: unique)
                    }
                result.append(
                    QuestionnaireQuestion(
                        id: question.id,
                        prompt: question.prompt,
                        detail: question.detail,
                        isRequired: question.isRequired,
                        kind: kind,
                        choiceStyle: question.choiceStyle
                    )
                )
            case .number(_, let range, _):
                guard range.lowerBound.isFinite, range.upperBound.isFinite else {
                    logger.fault("Questionnaire dropped a number question with a non-finite range")
                    continue
                }
                result.append(question)
            case .date(let range):
                guard range.lowerBound.timeIntervalSinceReferenceDate.isFinite,
                    range.upperBound.timeIntervalSinceReferenceDate.isFinite
                else {
                    logger.fault("Questionnaire dropped a date question with a non-finite range")
                    continue
                }
                result.append(question)
            case .custom:
                guard supportsCustomInput else {
                    logger.fault("Questionnaire dropped a custom question without an input builder")
                    continue
                }
                result.append(question)
            case .boolean, .text:
                result.append(question)
            }
        }
        if result.isEmpty {
            logger.fault("Questionnaire has no questions to show")
        }
        return result
    }

    nonisolated private static func uniqueOptions(_ options: [QuestionnaireOption]) -> [QuestionnaireOption] {
        var seen = Set<String>()
        return options.filter { seen.insert($0.id).inserted }
    }

    // MARK: - Paging

    /// Clamps a stored page index into the valid range for `count` questions.
    nonisolated static func clampedIndex(_ index: Int, count: Int) -> Int {
        guard count > 0 else { return 0 }
        return min(max(index, 0), count - 1)
    }

    /// The page after `index`, or `nil` when `index` is the last page.
    nonisolated static func nextIndex(after index: Int, count: Int) -> Int? {
        let next = index + 1
        return next < count ? next : nil
    }

    /// The page before `index`, or `nil` on the first page.
    nonisolated static func previousIndex(before index: Int) -> Int? {
        index > 0 ? index - 1 : nil
    }

    // MARK: - Answers

    /// The answer a question shows before the person touches it: today clamped into
    /// the range for a date question, otherwise `nil`.
    nonisolated static func defaultAnswer(for question: QuestionnaireQuestion, now: Date) -> QuestionnaireAnswer? {
        guard case .date(let range) = question.kind else { return nil }
        return .date(clamp(now, to: range))
    }

    /// The normalized stored answer, or the question's default when nothing valid is stored.
    nonisolated static func effectiveAnswer(
        _ answer: QuestionnaireAnswer?,
        for question: QuestionnaireQuestion,
        now: Date
    ) -> QuestionnaireAnswer? {
        answer.flatMap { normalized($0, for: question) } ?? defaultAnswer(for: question, now: now)
    }

    /// Whether `answer` is a valid, non-empty answer to `question`.
    nonisolated static func isAnswered(_ answer: QuestionnaireAnswer?, for question: QuestionnaireQuestion) -> Bool {
        guard let answer else { return false }
        return normalized(answer, for: question) != nil
    }

    /// Whether the person may leave the page: always for an optional question, and only
    /// with a valid answer (or the date default) for a required one.
    nonisolated static func canAdvance(
        from question: QuestionnaireQuestion,
        answer: QuestionnaireAnswer?,
        now: Date
    ) -> Bool {
        !question.isRequired || isAnswered(effectiveAnswer(answer, for: question, now: now), for: question)
    }

    /// The first required question that needs attention before the questionnaire can submit.
    nonisolated static func firstUnansweredRequiredIndex(
        answers: [String: QuestionnaireAnswer],
        questions: [QuestionnaireQuestion],
        now: Date
    ) -> Int? {
        questions.firstIndex { !canAdvance(from: $0, answer: answers[$0.id], now: now) }
    }

    /// Cleans an answer for `question`, or returns `nil` when nothing valid remains.
    ///
    /// - Choices keep only known option identifiers, in option order; a single-choice
    ///   question keeps the first selected one.
    /// - Numbers must be finite; they are clamped into the range and snapped to the step
    ///   measured from the lower bound.
    /// - Dates are clamped into the range.
    /// - Text is trimmed; empty text is no answer.
    /// - An answer of the wrong case for the question's kind is no answer.
    nonisolated static func normalized(
        _ answer: QuestionnaireAnswer,
        for question: QuestionnaireQuestion
    ) -> QuestionnaireAnswer? {
        switch (question.kind, answer) {
        case (.singleChoice(let options), .choices(let ids)):
            let known = Set(options.map(\.id))
            return ids.first(where: known.contains).map { .choices([$0]) }
        case (.multipleChoice(let options), .choices(let ids)):
            let selected = Set(ids)
            let kept = options.map(\.id).filter(selected.contains)
            return kept.isEmpty ? nil : .choices(kept)
        case (.boolean, .boolean):
            return answer
        case (.number(_, let range, let step), .number(let value)):
            guard value.isFinite else { return nil }
            return .number(snapped(value, range: range, step: step))
        case (.date(let range), .date(let date)):
            guard date.timeIntervalSinceReferenceDate.isFinite else { return nil }
            return .date(clamp(date, to: range))
        case (.text, .text(let text)):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : .text(trimmed)
        case (.custom, _):
            return normalizedCustomAnswer(answer)
        default:
            return nil
        }
    }

    nonisolated private static func normalizedCustomAnswer(_ answer: QuestionnaireAnswer) -> QuestionnaireAnswer? {
        switch answer {
        case .text(let text):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : .text(trimmed)
        case .number(let number):
            return number.isFinite ? answer : nil
        case .date(let date):
            return date.timeIntervalSinceReferenceDate.isFinite ? answer : nil
        case .choices(let ids):
            var seen = Set<String>()
            let unique = ids.filter { seen.insert($0).inserted }
            return unique.isEmpty ? nil : .choices(unique)
        case .boolean:
            return answer
        }
    }

    /// The answers to hand back on submit: normalized stored answers and the displayed
    /// defaults for date questions, with invalid and unknown answers removed.
    nonisolated static func submission(
        answers: [String: QuestionnaireAnswer],
        questions: [QuestionnaireQuestion],
        now: Date
    ) -> [String: QuestionnaireAnswer] {
        var result: [String: QuestionnaireAnswer] = [:]
        for question in questions {
            guard let answer = effectiveAnswer(answers[question.id], for: question, now: now) else { continue }
            result[question.id] = answer
        }
        return result
    }

    // MARK: - Choice input

    /// The identifiers currently selected by `answer`.
    nonisolated static func selectedIDs(in answer: QuestionnaireAnswer?) -> Set<String> {
        guard case .choices(let ids) = answer else { return [] }
        return Set(ids)
    }

    /// The answer after tapping `optionID`.
    ///
    /// A single-choice tap selects that option, or clears the answer when it was already
    /// selected. A multiple-choice tap toggles the option and keeps option order. An
    /// empty selection is no answer.
    nonisolated static func toggling(
        _ optionID: String,
        in answer: QuestionnaireAnswer?,
        options: [QuestionnaireOption],
        allowsMultiple: Bool
    ) -> QuestionnaireAnswer? {
        guard options.contains(where: { $0.id == optionID }) else { return answer }
        var selected = selectedIDs(in: answer)
        if allowsMultiple {
            if selected.contains(optionID) {
                selected.remove(optionID)
            } else {
                selected.insert(optionID)
            }
            let ordered = options.map(\.id).filter(selected.contains)
            return ordered.isEmpty ? nil : .choices(ordered)
        }
        return selected == [optionID] ? nil : .choices([optionID])
    }

    /// Resolves the default indicators without changing selection semantics.
    nonisolated static func resolvedChoiceStyle(
        _ style: QuestionnaireChoiceStyle,
        allowsMultiple: Bool
    ) -> QuestionnaireChoiceStyle {
        style == .automatic ? (allowsMultiple ? .checkmarks : .bullets) : style
    }

    /// The decorative symbol used by an option row.
    nonisolated static func choiceSymbol(style: QuestionnaireChoiceStyle, isSelected: Bool) -> String {
        switch style {
        case .checkmarks: isSelected ? "checkmark.square.fill" : "square"
        case .automatic, .bullets, .chips: isSelected ? "largecircle.fill.circle" : "circle"
        }
    }

    // MARK: - Number input

    /// The value after one stepper press, clamped into `range`. An empty field starts
    /// from the lower bound. A non-positive or non-finite `step` steps by `1`.
    nonisolated static func stepped(
        _ value: Double?,
        increment: Bool,
        range: ClosedRange<Double>,
        step: Double
    ) -> Double {
        guard let value, value.isFinite else { return range.lowerBound }
        let delta = step.isFinite && step > 0 ? step : 1
        return clamp(value + (increment ? delta : -delta), to: range)
    }

    /// Clamps `value` into `range` and snaps it to the nearest `step` from the lower
    /// bound. A non-positive or non-finite `step` only clamps.
    nonisolated static func snapped(_ value: Double, range: ClosedRange<Double>, step: Double) -> Double {
        let clamped = clamp(value, to: range)
        guard step.isFinite, step > 0 else { return clamped }
        let steps = ((clamped - range.lowerBound) / step).rounded()
        let snapped = range.lowerBound + steps * step
        return snapped.isFinite ? clamp(snapped, to: range) : clamped
    }

    /// Parses typed text as a number using `locale`'s separators. Empty or unparseable
    /// text is `nil`.
    nonisolated static func parseNumber(_ text: String, locale: Locale) -> Double? {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }
        let value = try? Double(trimmed, format: .number.locale(locale))
        return value.flatMap { $0.isFinite ? $0 : nil }
    }

    /// Formats a number for the field without grouping separators, so it parses back.
    nonisolated static func formatNumber(_ value: Double, locale: Locale) -> String {
        value.formatted(.number.locale(locale).grouping(.never).precision(.significantDigits(1...17)))
    }

    // MARK: - Helpers

    nonisolated private static func clamp<Value: Comparable>(_ value: Value, to range: ClosedRange<Value>) -> Value {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
