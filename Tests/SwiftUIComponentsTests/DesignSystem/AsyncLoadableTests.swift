import DesignSystem
import Testing

@Suite("AsyncLoadable")
struct AsyncLoadableTests {

    /// The whole point of the protocol: a consumer's own state enum, with its own error
    /// type, drives the shared view without being converted at the call site.
    @Test func consumerStateProjectsToLoadingState() {
        #expect(ConsumerState.idle.loadingState == .idle)
        #expect(ConsumerState.busy.loadingState == .loading)
        #expect(ConsumerState.ready("value").loadingState == .loaded("value"))
        #expect(ConsumerState.broken(.offline).loadingState == .failed(.offline))
    }

    /// `LoadingState` must keep satisfying the protocol itself, so existing call sites
    /// that pass one directly still resolve.
    @Test func loadingStateProjectsToItself() {
        let state = LoadingState<String, ConsumerError>.loaded("value")

        #expect(state.loadingState == state)
    }
}

// MARK: - Fixtures

/// Stands in for an app's own state type: different case names, its own error.
private enum ConsumerState: Equatable, AsyncLoadable {
    case idle
    case busy
    case ready(String)
    case broken(ConsumerError)

    var loadingState: LoadingState<String, ConsumerError> {
        switch self {
        case .idle: .idle
        case .busy: .loading
        case .ready(let value): .loaded(value)
        case .broken(let error): .failed(error)
        }
    }
}

private enum ConsumerError: Error, Equatable, Sendable {
    case offline
}
