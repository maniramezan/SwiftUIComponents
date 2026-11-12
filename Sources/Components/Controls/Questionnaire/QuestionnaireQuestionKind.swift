import Foundation

/// The input a ``QuestionnaireQuestion`` collects.
///
/// Each kind maps to one answer case: choice kinds produce
/// ``QuestionnaireAnswer/choices(_:)``, `number` produces ``QuestionnaireAnswer/number(_:)``,
/// `date` produces ``QuestionnaireAnswer/date(_:)``, and `text` produces
/// ``QuestionnaireAnswer/text(_:)``.
public enum QuestionnaireQuestionKind: Hashable, Sendable {
    /// Pick exactly one of `options`, shown as wrapping chips.
    case singleChoice(options: [QuestionnaireOption])

    /// Pick any number of `options`, shown as wrapping chips.
    case multipleChoice(options: [QuestionnaireOption])

    /// A numeric value inside `range`, entered by typing or stepping by `step`.
    ///
    /// `unitLabel` is shown after the field (for example "km" or "min") and is rendered
    /// verbatim. Values are clamped into `range` and snapped to `step` when the
    /// questionnaire submits. A non-positive `step` is treated as no snapping.
    case number(unitLabel: String?, range: ClosedRange<Double>, step: Double)

    /// A calendar day inside `range`. Until the person changes it, the picker shows today
    /// clamped into `range`; moving past the page records that day as the answer.
    case date(range: ClosedRange<Date>)

    /// Free-form text. `placeholder` is shown while the field is empty and is rendered
    /// verbatim. Answers are trimmed of surrounding whitespace on submit.
    case text(placeholder: String?)
}
