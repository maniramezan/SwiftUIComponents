import DesignSystem
import SwiftUI

/// Container that renders one of three caller-built bodies depending on a
/// `LoadingState`: the loading content while in flight, the success content
/// once a value lands, or the error content when the fetch fails.
///
/// Transitions between cases cross-fade using `theme.motion.standardAnimation`,
/// so toggling state reads as a smooth swap rather than a layout pop.
///
/// ```swift
/// AsyncContentView(state: viewModel.profileState) { profile in
///     ProfileDetail(profile)
/// } loadingContent: {
///     LoadingView("Loading profile")
/// } errorContent: { error in
///     ContentUnavailableView("Couldn't load", systemImage: "exclamationmark.triangle")
/// }
/// ```
///
/// The `idle` case renders an empty `Color.clear` placeholder. Use `.task`,
/// `.onAppear`, or an explicit user action on the parent to transition out
/// of `idle`.
public struct AsyncContentView<
    Content: View,
    LoadingContent: View,
    ErrorContent: View,
    Value: Sendable & Equatable,
    Failure: Error & Sendable & Equatable
>: View {

    private let state: LoadingState<Value, Failure>
    private let content: (Value) -> Content
    private let loadingContent: () -> LoadingContent
    private let errorContent: (Failure) -> ErrorContent
    @Environment(\.designTheme) private var theme

    /// Creates an async content view.
    ///
    /// - Parameters:
    ///   - state: Current loading state.
    ///   - content: Builder rendered once the state is `.loaded(value)`.
    ///   - loadingContent: Builder rendered while the state is `.loading`.
    ///   - errorContent: Builder rendered when the state is `.failed(failure)`.
    public init(
        state: LoadingState<Value, Failure>,
        @ViewBuilder content: @escaping (Value) -> Content,
        @ViewBuilder loadingContent: @escaping () -> LoadingContent,
        @ViewBuilder errorContent: @escaping (Failure) -> ErrorContent
    ) {
        self.state = state
        self.content = content
        self.loadingContent = loadingContent
        self.errorContent = errorContent
    }

    public var body: some View {
        ZStack {
            switch state {
            case .idle:
                Color.clear.transition(.opacity)
            case .loading:
                loadingContent().transition(.opacity)
            case .loaded(let value):
                content(value).transition(.opacity)
            case .failed(let failure):
                errorContent(failure).transition(.opacity)
            }
        }
        .animation(theme.motion.standardAnimation, value: state)
    }
}
