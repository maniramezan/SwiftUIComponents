/// An optional trailing action shown inside a ``ToastView`` — for example an
/// "Undo" or "Retry" affordance in a snackbar-style toast.
///
/// ```swift
/// ToastView("Item deleted", role: .info, action: .init("Undo") { restore() })
/// ```
///
/// When presented via the `.toast(_:role:systemImage:isPresented:edge:duration:action:)`
/// modifier, tapping the action runs ``handler`` and then dismisses the toast.
public struct ToastAction {
    /// The button title rendered to the user. Pass an already-localized value.
    public let title: String
    /// The closure invoked when the user taps the action.
    public let handler: () -> Void

    /// Creates a toast action.
    ///
    /// - Parameters:
    ///   - title: The button title. Rendered verbatim, so localize it on your side.
    ///   - handler: The closure to run when the user taps the action.
    public init(_ title: String, handler: @escaping () -> Void) {
        self.title = title
        self.handler = handler
    }
}
