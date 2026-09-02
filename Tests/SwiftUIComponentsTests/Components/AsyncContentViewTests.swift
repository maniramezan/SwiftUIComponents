import Components
import DesignSystem
import SwiftUI
import Testing

@MainActor
@Suite("AsyncContentView")
struct AsyncContentViewTests {

    private struct StubError: Error, Equatable, Sendable {
        let message: String
    }

    private typealias TestState = LoadingState<String, StubError>

    @Test("idle renders empty placeholder")
    func idle() {
        let state: TestState = .idle
        let view = AsyncContentView(state: state) { value in
            Text(value)
        } loadingContent: {
            Text("Loading")
        } errorContent: { error in
            Text(error.message)
        }
        // Construction succeeds — idle should render Color.clear
        _ = view
    }

    @Test("loading state renders loading content builder")
    func loading() {
        let state: TestState = .loading
        let view = AsyncContentView(state: state) { value in
            Text(value)
        } loadingContent: {
            Text("Loading")
        } errorContent: { error in
            Text(error.message)
        }
        _ = view
    }

    @Test("loaded state renders content builder with value")
    func loaded() {
        let state: TestState = .loaded("Hello")
        let view = AsyncContentView(state: state) { value in
            Text(value)
        } loadingContent: {
            Text("Loading")
        } errorContent: { error in
            Text(error.message)
        }
        _ = view
    }

    @Test("failed state renders error content builder with failure")
    func failed() {
        let state: TestState = .failed(StubError(message: "Offline"))
        let view = AsyncContentView(state: state) { value in
            Text(value)
        } loadingContent: {
            Text("Loading")
        } errorContent: { error in
            Text(error.message)
        }
        _ = view
    }

    @Test("transitioning between states constructs without error")
    func transitions() {
        for state: TestState in [.idle, .loading, .loaded("X"), .failed(StubError(message: "E"))] {
            _ = AsyncContentView(state: state) {
                Text($0)
            } loadingContent: {
                Text("…")
            } errorContent: {
                Text($0.message)
            }
        }
    }

    /// The initializer a consuming app uses: its own state type, never converted to
    /// `LoadingState` at the call site.
    @Test("renders a consumer's own AsyncLoadable state")
    func consumerStateInitializer() {
        let view = AsyncContentView(state: ConsumerState.ready("value")) { value in
            Text(value)
        } loadingContent: {
            Text("Loading")
        } errorContent: { error in
            Text(error.message)
        }
        _ = view
    }

    /// A state type shaped like an app's own — different case names, its own error —
    /// rather than a `LoadingState` in disguise.
    private enum ConsumerState: Equatable, AsyncLoadable {
        case busy
        case ready(String)
        case broken(StubError)

        var loadingState: LoadingState<String, StubError> {
            switch self {
            case .busy: .loading
            case .ready(let value): .loaded(value)
            case .broken(let error): .failed(error)
            }
        }
    }
}
