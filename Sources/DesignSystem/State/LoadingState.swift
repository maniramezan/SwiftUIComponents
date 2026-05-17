import Foundation

/// Generic four-state machine for async-data screens — `idle` before any
/// fetch, `loading` while in flight, `loaded(Value)` after success,
/// `failed(Failure)` after an error.
///
/// Both `Value` and `Failure` are passed through so callers keep their
/// domain types — there is no boxing into `AnyError` or string-only error
/// messages. `Equatable` lets SwiftUI animate between states.
///
/// ```swift
/// @State private var state: LoadingState<Profile, ProfileError> = .idle
///
/// var body: some View {
///     AsyncContentView(state: state) { profile in
///         ProfileDetailView(profile)
///     } loadingContent: {
///         LoadingView("Loading profile")
///     } errorContent: { error in
///         ProfileErrorView(error: error)
///     }
/// }
/// ```
public enum LoadingState<Value: Sendable & Equatable, Failure: Error & Sendable & Equatable>:
    Sendable, Equatable
{

    /// No fetch has been requested yet.
    case idle

    /// A fetch is currently in flight.
    case loading

    /// A fetch completed successfully and produced `Value`.
    case loaded(Value)

    /// A fetch finished with the given `Failure`.
    case failed(Failure)

    /// `true` when the state is `.loading`.
    public var isLoading: Bool {
        if case .loading = self { true } else { false }
    }

    /// `true` when the state is `.loaded`.
    public var isLoaded: Bool {
        if case .loaded = self { true } else { false }
    }

    /// The underlying value when the state is `.loaded`, otherwise `nil`.
    public var value: Value? {
        if case .loaded(let value) = self { value } else { nil }
    }

    /// The underlying failure when the state is `.failed`, otherwise `nil`.
    public var failure: Failure? {
        if case .failed(let failure) = self { failure } else { nil }
    }
}
