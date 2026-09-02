import Foundation

/// A type that can describe itself as a ``LoadingState``.
///
/// Views that render async work — ``LoadingState``'s own four cases — accept any
/// `AsyncLoadable`, not just ``LoadingState`` itself. That matters because an app usually
/// already owns a state enum of its own, carrying its own error type and domain
/// conveniences. Without this, adopting a shared async-content view means either
/// converting at every call site or giving up and reimplementing the view; both are worse
/// than conforming once.
///
/// ``LoadingState`` conforms trivially, so existing call sites are unaffected.
///
/// ```swift
/// extension MyAppState: AsyncLoadable {
///     var loadingState: LoadingState<Value, MyError> {
///         switch self {
///         case .idle: .idle
///         case .loading: .loading
///         case .loaded(let value): .loaded(value)
///         case .failed(let error): .failed(error)
///         }
///     }
/// }
/// ```
public protocol AsyncLoadable<Value, Failure>: Equatable {
    /// The value produced by a successful load.
    associatedtype Value: Sendable & Equatable
    /// The failure produced by an unsuccessful one.
    associatedtype Failure: Error & Sendable & Equatable

    /// This value expressed as the four-case state a rendering view understands.
    var loadingState: LoadingState<Value, Failure> { get }
}

extension LoadingState: AsyncLoadable {
    /// A `LoadingState` is already in the required shape.
    public var loadingState: LoadingState<Value, Failure> { self }
}
