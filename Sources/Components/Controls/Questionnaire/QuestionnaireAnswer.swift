import Foundation

/// A recorded answer to one ``QuestionnaireQuestion``.
///
/// ``QuestionnaireView`` keeps answers in a dictionary keyed by
/// ``QuestionnaireQuestion/id``. An unanswered question has no entry.
public enum QuestionnaireAnswer: Hashable, Sendable {
    /// The identifiers of the selected ``QuestionnaireOption`` values, in option order.
    /// A single-choice question holds at most one identifier.
    case choices([String])

    /// A numeric answer.
    case number(Double)

    /// A calendar-day answer.
    case date(Date)

    /// A free-form text answer.
    case text(String)
}
