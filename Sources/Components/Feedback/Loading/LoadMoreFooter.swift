import DesignSystem
import SwiftUI

/// A footer for infinite-scrolling lists: a near-invisible sentinel that
/// triggers pagination when it scrolls into view, plus a themed spinner while
/// the next page loads.
///
/// SwiftUI does not re-fire `.onAppear` for a view whose identity hasn't
/// changed, so a naive "trigger on the last row's onAppear" stalls after the
/// first page if that row happens to remain the last one (it usually
/// doesn't, but footer-based pagination sidesteps the question entirely).
/// Pass a `triggerID` that changes whenever the pagination cursor advances
/// (e.g. the next offset, or a value derived from it) so the sentinel is
/// guaranteed to re-append and re-fire.
///
/// ```swift
/// ScrollView {
///     ForEach(items) { item in ItemRow(item) }
///     LoadMoreFooter(triggerID: nextOffset, isLoadingMore: isLoadingMore) {
///         viewModel.loadMore()
///     }
/// }
/// ```
///
/// Place this after the last item in a `LazyVStack`, `LazyVGrid`, or plain
/// `VStack`/`ScrollView` content — anywhere `.onAppear` fires when scrolled
/// into the viewport.
public struct LoadMoreFooter: View {

    let triggerID: AnyHashable?
    let isLoadingMore: Bool
    let onTrigger: () -> Void

    @Environment(\.designTheme) private var theme

    /// Creates a load-more footer.
    ///
    /// - Parameters:
    ///   - triggerID: A value that changes whenever there is a new page to
    ///     load. Pass `nil` when there is no more content — the sentinel is
    ///     omitted and no further loads are triggered. Common choices: the
    ///     next page's offset/cursor, or `nil` when `hasMore` is `false`.
    ///   - isLoadingMore: Whether a page request is in flight. Shows a
    ///     trailing spinner below the sentinel while `true`.
    ///   - onTrigger: Invoked when the sentinel scrolls into view. Callers
    ///     are responsible for guarding against duplicate in-flight requests
    ///     (this view fires once per appearance, not once per session).
    public init(
        triggerID: AnyHashable?,
        isLoadingMore: Bool,
        onTrigger: @escaping () -> Void
    ) {
        self.triggerID = triggerID
        self.isLoadingMore = isLoadingMore
        self.onTrigger = onTrigger
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let triggerID {
                Color.clear
                    .frame(height: 1)
                    .id(triggerID)
                    .onAppear(perform: onTrigger)
                    .accessibilityHidden(true)
            }

            if isLoadingMore {
                ProgressView()
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, theme.spacing.twoUnits)
                    .padding(.bottom, theme.spacing.twoUnits)
            }
        }
    }
}

#Preview("Design Load More Footer") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            Text("Has more, idle").designTextStyle(.headline)
            LoadMoreFooter(triggerID: 20, isLoadingMore: false) {}
                .border(theme.colors.border)

            Text("Has more, loading").designTextStyle(.headline)
            LoadMoreFooter(triggerID: 20, isLoadingMore: true) {}
                .border(theme.colors.border)

            Text("No more content").designTextStyle(.headline)
            LoadMoreFooter(triggerID: nil, isLoadingMore: false) {}
                .border(theme.colors.border)
        }
        .padding(theme.spacing.twoUnits)
    }
}
