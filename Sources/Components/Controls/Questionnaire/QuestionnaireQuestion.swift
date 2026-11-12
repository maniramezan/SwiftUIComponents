import Foundation

/// One question shown on its own page of a ``QuestionnaireView``.
///
/// ```swift
/// QuestionnaireQuestion(
///     id: "frequency",
///     prompt: "How often do you want to do this?",
///     detail: "You can change it later.",
///     kind: .singleChoice(options: [QuestionnaireOption("Daily"), QuestionnaireOption("Weekly")])
/// )
/// ```
///
/// Text is rendered verbatim, so localize `prompt` and `detail` on your side.
public struct QuestionnaireQuestion: Identifiable, Hashable, Sendable {
    /// Stable identity of the question; answers are keyed by it. Keep it unique within
    /// a questionnaire.
    public let id: String

    /// The question itself, shown as the page heading.
    public let prompt: String

    /// Optional supporting text shown below the prompt.
    public let detail: String?

    /// When `true`, the person cannot move past this question without a valid answer.
    /// Optional questions show an "Optional" caption and can be left blank.
    public let isRequired: Bool

    /// The kind of input the question collects.
    public let kind: QuestionnaireQuestionKind

    /// Creates a question.
    ///
    /// - Parameters:
    ///   - id: Stable identifier used as the answer key.
    ///   - prompt: The question shown as the page heading.
    ///   - detail: Optional supporting text below the prompt. Defaults to `nil`.
    ///   - isRequired: Whether a valid answer is needed to continue. Defaults to `false`.
    ///   - kind: The input the question collects.
    public init(
        id: String,
        prompt: String,
        detail: String? = nil,
        isRequired: Bool = false,
        kind: QuestionnaireQuestionKind
    ) {
        self.id = id
        self.prompt = prompt
        self.detail = detail
        self.isRequired = isRequired
        self.kind = kind
    }
}
