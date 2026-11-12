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
    /// no options, and a number question with non-finite bounds. Repeated option
    /// identifiers inside a choice question keep only their first occurrence. Every
    /// repair logs a fault, since it signals caller misuse.
    nonisolated static func validQuestions(_ questions: [QuestionnaireQuestion]) -> [QuestionnaireQuestion] {
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
                        kind: kind
                    )
                )
            case .number(_, let range, _):
                guard range.lowerBound.isFinite, range.upperBound.isFinite else {
                    logger.fault("Questionnaire dropped a number question with a non-finite range")
                    continue
                }
                result.append(question)
            case .date, .text:
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

    /// The stored answer, or the question's default when nothing is stored.
    nonisolated static func effectiveAnswer(
        _ answer: QuestionnaireAnswer?,
        for question: QuestionnaireQuestion,
        now: Date
    ) -> QuestionnaireAnswer? {
        answer ?? defaultAnswer(for: question, now: now)
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
        case (.number(_, let range, let step), .number(let value)):
            guard value.isFinite else { return nil }
            return .number(snapped(value, range: range, step: step))
        case (.date(let range), .date(let date)):
            return .date(clamp(date, to: range))
        case (.text, .text(let text)):
            let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? nil : .text(trimmed)
        default:
            return nil
        }
    }

    /// The answers to hand back on submit: every stored answer normalized for its
    /// question, with invalid answers and answers to unknown questions removed.
    nonisolated static func submission(
        answers: [String: QuestionnaireAnswer],
        questions: [QuestionnaireQuestion]
    ) -> [String: QuestionnaireAnswer] {
        var result: [String: QuestionnaireAnswer] = [:]
        for question in questions {
            guard let answer = answers[question.id], let clean = normalized(answer, for: question) else { continue }
            result[question.id] = clean
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

    // MARK: - Number input

    /// The value after one stepper press, clamped into `range`. An empty field starts
    /// from the lower bound. A non-positive `step` steps by `1`.
    nonisolated static func stepped(
        _ value: Double?,
        increment: Bool,
        range: ClosedRange<Double>,
        step: Double
    ) -> Double {
        guard let value, value.isFinite else { return range.lowerBound }
        let delta = step > 0 ? step : 1
        return clamp(value + (increment ? delta : -delta), to: range)
    }

    /// Clamps `value` into `range` and snaps it to the nearest `step` from the lower
    /// bound. A non-positive `step` only clamps.
    nonisolated static func snapped(_ value: Double, range: ClosedRange<Double>, step: Double) -> Double {
        let clamped = clamp(value, to: range)
        guard step > 0 else { return clamped }
        let steps = ((clamped - range.lowerBound) / step).rounded()
        return clamp(range.lowerBound + steps * step, to: range)
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
        value.formatted(.number.locale(locale).grouping(.never).precision(.fractionLength(0...3)))
    }

    // MARK: - Helpers

    nonisolated private static func clamp<Value: Comparable>(_ value: Value, to range: ClosedRange<Value>) -> Value {
        min(max(value, range.lowerBound), range.upperBound)
    }
}
