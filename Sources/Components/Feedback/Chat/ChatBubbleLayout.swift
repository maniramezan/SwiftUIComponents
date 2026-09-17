import SwiftUI

/// Pure layout decisions shared by ``ChatBubble`` and its text conveniences.
///
/// Kept separate from the view so the direction rules can be unit-tested
/// directly, in the same spirit as `ScrollLayoutMath`.
enum ChatBubbleLayout {

    /// Whether a role's bubble hugs the trailing edge of its row.
    ///
    /// "Trailing" resolves against the ambient layout direction, so a
    /// right-to-left *interface* mirrors the whole conversation the way the
    /// system messaging apps do.
    ///
    /// - Parameter role: The message's conversational role.
    /// - Returns: `true` for `.user`, `false` for `.assistant` and `.system`.
    nonisolated static func hugsTrailingEdge(for role: ChatMessageRole) -> Bool {
        role == .user
    }

    /// The layout direction a bubble's body is laid out with.
    ///
    /// A caller rendering a right-to-left reply inside an otherwise
    /// left-to-right interface overrides this per bubble rather than
    /// mirroring the surrounding row — mirroring the row would flip which
    /// side of the screen each role lands on.
    ///
    /// - Parameters:
    ///   - override: The caller's per-bubble content direction, if any.
    ///   - ambient: The layout direction inherited from the environment.
    /// - Returns: `override` when the caller supplied one, otherwise `ambient`.
    nonisolated static func contentDirection(
        override: LayoutDirection?,
        ambient: LayoutDirection
    ) -> LayoutDirection {
        override ?? ambient
    }
}
