import Components
import DesignSystem
import SwiftUI

/// Showcases ``AsyncContentView`` across every ``LoadingState`` and
/// ``LoadMoreFooter`` with live pagination controls.
struct AsyncContentDetailView: View {

    fileprivate enum Phase: String, CaseIterable, Identifiable {
        case idle = "Idle"
        case loading = "Loading"
        case loaded = "Loaded"
        case failed = "Failed"

        var id: String { rawValue }
    }

    fileprivate struct DemoError: Error, Equatable {
        let message: String
    }

    @State private var phase: Phase = .loaded
    @State private var pageCount = 1
    @State private var pageLimit = 4
    @State private var isLoadingMore = false
    @Environment(\.designTheme) private var theme

    private var state: LoadingState<[String], DemoError> {
        switch phase {
        case .idle: .idle
        case .loading: .loading
        case .loaded: .loaded(["First item", "Second item", "Third item"])
        case .failed: .failed(DemoError(message: "The items couldn't be loaded."))
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Async content") {
                Picker("State", selection: $phase) {
                    ForEach(Phase.allCases) { phase in
                        Text(phase.rawValue).tag(phase)
                    }
                }
                .pickerStyle(.segmented)

                AsyncContentView(state: state) { items in
                    VStack(spacing: 0) {
                        ForEach(items, id: \.self) { item in
                            ListRow(item, systemImage: "doc")
                        }
                    }
                } loadingContent: {
                    LoadingView("Loading items")
                } errorContent: { error in
                    ErrorBanner(error.message)
                }
                .frame(minHeight: theme.spacing.sixUnits * 3)
            }

            ShowcaseSection("Load more footer") {
                Text("Pages loaded: \(pageCount) of \(pageLimit)")
                    .designTextStyle(.caption)
                // The sentinel is always on screen here, so each appearance simulates one page
                // load; `triggerID` becomes `nil` once the limit is reached, ending pagination.
                LoadMoreFooter(triggerID: pageCount < pageLimit ? pageCount : nil, isLoadingMore: isLoadingMore) {
                    loadNextPage()
                }
                .border(theme.colors.border)
                Stepper("Page limit: \(pageLimit)", value: $pageLimit, in: 1...10)
                ThemeButton("Reset", role: .secondary) {
                    pageCount = 1
                }
            }
        }
    }
}

extension AsyncContentDetailView {
    /// Simulates fetching one more page, ignoring triggers while a fetch is in flight.
    fileprivate func loadNextPage() {
        guard !isLoadingMore else { return }
        isLoadingMore = true
        Task {
            try? await Task.sleep(for: .seconds(1))
            pageCount += 1
            isLoadingMore = false
        }
    }
}

#Preview {
    ScrollView {
        AsyncContentDetailView()
            .padding()
    }
}
