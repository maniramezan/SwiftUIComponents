import Foundation

/// The presentation of options in a ``QuestionnaireQuestion``.
///
/// Presentation never changes how many options can be selected. That is determined
/// by ``QuestionnaireQuestion/kind``.
public enum QuestionnaireChoiceStyle: String, CaseIterable, Hashable, Sendable {
    /// Separate rows with bullets for single and boolean choices, or checkmarks for multiple choices.
    case automatic

    /// Separate rows with a circular indicator that fills when selected.
    case bullets

    /// Separate rows with a square indicator that shows a checkmark when selected.
    case checkmarks

    /// Compact options that wrap onto additional lines as selectable chips.
    case chips
}
