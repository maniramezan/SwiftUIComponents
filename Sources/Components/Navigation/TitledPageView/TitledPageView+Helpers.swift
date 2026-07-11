import DesignSystem
import SwiftUI

// MARK: - Pure helpers

extension TitledPageView {

    /// See ``TitledPageViewMath/progress(contentOffsetX:viewportWidth:)``.
    nonisolated static func progress(contentOffsetX: CGFloat, viewportWidth: CGFloat) -> CGFloat {
        TitledPageViewMath.progress(contentOffsetX: contentOffsetX, viewportWidth: viewportWidth)
    }

    /// See ``TitledPageViewMath/stepIndex(by:from:count:)``.
    nonisolated static func stepIndex(by step: Int, from: Int, count: Int) -> Int {
        TitledPageViewMath.stepIndex(by: step, from: from, count: count)
    }

    /// See ``TitledPageViewMath/accessibilityStep(for:layoutDirection:)``.
    nonisolated static func accessibilityStep(for edge: Edge, layoutDirection: LayoutDirection) -> Int {
        TitledPageViewMath.accessibilityStep(for: edge, layoutDirection: layoutDirection)
    }

    /// See ``TitledPageViewMath/shouldShowIndicator(count:style:)``.
    nonisolated static func shouldShowIndicator(
        count: Int,
        style: PaginationIndicatorStyle
    ) -> Bool {
        TitledPageViewMath.shouldShowIndicator(count: count, style: style)
    }

    /// See ``TitledPageViewMath/resolveStyle(override:theme:titleAlignment:)``.
    @MainActor
    static func resolveStyle(
        override: PaginationStyle,
        theme: any Theme,
        titleAlignment: TitledPageTitleAlignment = .automatic
    ) -> ResolvedPaginationStyle {
        TitledPageViewMath.resolveStyle(override: override, theme: theme, titleAlignment: titleAlignment)
    }
}
