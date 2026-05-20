import Foundation

/// Controls how the default ``TitledPageView`` title strip positions the
/// active page title.
public enum TitledPageTitleAlignment: Sendable, Hashable, CaseIterable {

    /// Preserves the title layout implied by ``PaginationStyle/peekDirection``.
    ///
    /// Use this mode when migrating existing code because it keeps the prior
    /// bidirectional, unidirectional, or non-peeking title behavior.
    case automatic

    /// Aligns the active title to the leading edge and reveals part of the
    /// next page title on the trailing side.
    case leading

    /// Aligns the active title to the trailing side and reveals part of the
    /// previous page title on the leading side.
    case trailing

    /// Centers the title region on the active page and hides adjacent titles.
    case center

    /// Removes the default title strip entirely.
    case hidden
}
