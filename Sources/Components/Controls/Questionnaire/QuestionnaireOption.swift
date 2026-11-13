import Foundation

/// One selectable answer for a choice question in a ``QuestionnaireView``.
///
/// ```swift
/// QuestionnaireOption(id: "a", title: "Option A")
/// QuestionnaireOption("Option B")
/// ```
public struct QuestionnaireOption: Identifiable, Hashable, Sendable {
    /// Stable identity of the option. Choice answers store these identifiers, so keep
    /// them unique within a question.
    public let id: String

    /// The text shown on the option. Rendered verbatim, so localize it on your side.
    public let title: String

    /// Creates an option with an explicit identifier.
    ///
    /// - Parameters:
    ///   - id: Stable identifier recorded in a ``QuestionnaireAnswer/choices(_:)`` answer.
    ///   - title: The text shown on the option.
    public init(id: String, title: String) {
        self.id = id
        self.title = title
    }

    /// Creates an option whose identifier is its title.
    ///
    /// Use this when titles are already unique, such as options produced at runtime.
    ///
    /// - Parameter title: The text shown on the option and recorded as its identifier.
    public init(_ title: String) {
        self.init(id: title, title: title)
    }
}
