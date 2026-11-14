import Foundation

/// The input a ``QuestionnaireQuestion`` collects.
///
/// Each kind maps to one answer case: choice kinds produce
/// ``QuestionnaireAnswer/choices(_:)``, `number` produces ``QuestionnaireAnswer/number(_:)``,
/// `date` produces ``QuestionnaireAnswer/date(_:)``, `text` produces
/// ``QuestionnaireAnswer/text(_:)``, and `boolean` produces ``QuestionnaireAnswer/boolean(_:)``.
/// Custom inputs can record any answer case.
public enum QuestionnaireQuestionKind: Hashable, Sendable {
    /// Pick exactly one of `options`, shown using ``QuestionnaireQuestion/choiceStyle``.
    case singleChoice(options: [QuestionnaireOption])

    /// Pick any number of `options`, shown using ``QuestionnaireQuestion/choiceStyle``.
    case multipleChoice(options: [QuestionnaireOption])

    /// An explicit true or false answer, initially unanswered.
    ///
    /// Both titles are rendered verbatim; supply localized values such as "Yes" and "No".
    /// Selecting the false option is a valid answer to a required question.
    case boolean(trueTitle: String, falseTitle: String)

    /// A numeric value inside `range`, entered by typing or stepping by `step`.
    ///
    /// `unitLabel` is shown after the field (for example "km" or "min") and is rendered
    /// verbatim. Values are clamped into `range` and snapped to `step` when the
    /// questionnaire submits. A non-positive or non-finite `step` is treated as no snapping.
    /// Typed and pasted text keeps only decimal digits and one locale-specific decimal
    /// separator, with a leading minus sign allowed when `range` includes negative values.
    /// An existing negative answer retains its sign until submission clamps it into `range`.
    case number(unitLabel: String?, range: ClosedRange<Double>, step: Double)

    /// A calendar day inside `range`, selected using a compact date field.
    /// Until the person changes it, the field shows today clamped into `range`;
    /// moving past the page records that day as the answer.
    case date(range: ClosedRange<Date>)

    /// Free-form text. `placeholder` is shown while the field is empty and is rendered
    /// verbatim. Answers are trimmed of surrounding whitespace on submit.
    case text(placeholder: String?)

    /// Caller-supplied content built by the questionnaire's `customInput` closure.
    ///
    /// Write an answer through the supplied binding when the input is valid, or `nil`
    /// while incomplete. Text is trimmed, numbers and dates must be finite, and choice
    /// identifiers are deduplicated in their supplied order. No default answer is assumed.
    /// Without a custom input builder, these questions are dropped with a logged fault.
    case custom
}
