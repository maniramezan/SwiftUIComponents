import Foundation

/// A recorded answer to one ``QuestionnaireQuestion``.
///
/// ``QuestionnaireView`` keeps answers in a dictionary keyed by
/// ``QuestionnaireQuestion/id``. An unanswered question has no entry.
public enum QuestionnaireAnswer: Hashable, Sendable {
    /// The identifiers of selected ``QuestionnaireOption`` values, in option order for
    /// built-in choice questions. A single-choice question holds at most one identifier.
    /// Custom inputs preserve the supplied identifier order, including a ranking.
    case choices([String])

    /// An explicit true or false answer. Both values count as answered.
    case boolean(Bool)

    /// A numeric answer.
    case number(Double)

    /// A calendar-day answer.
    case date(Date)

    /// A free-form text answer.
    case text(String)
}
