import SwiftUI

/// Toolbar dismiss button (xmark) placed in the system's cancellation position.
///
/// Use this as the standard close button in sheets and modal presentations. Attach an
/// automation identifier or VoiceOver hint with ``accessibilityIdentifier(_:)`` and
/// ``accessibilityHint(_:)``.
public struct DismissToolbarButton: ToolbarContent {
    private let action: () -> Void
    private(set) var accessibility: ControlAccessibility

    /// Creates a dismiss toolbar button.
    /// - Parameters:
    ///   - accessibilityIdentifier: Optional identifier for UI automation. `nil` keeps the
    ///     system default.
    ///   - action: Closure invoked on tap.
    public init(accessibilityIdentifier: String? = nil, action: @escaping () -> Void) {
        self.action = action
        self.accessibility = ControlAccessibility(identifier: accessibilityIdentifier)
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: Strings.Toolbar.close), systemImage: "xmark", action: action)
                .labelStyle(.iconOnly)
                .modifier(ControlAccessibilityModifier(accessibility: accessibility))
        }
    }

    /// Returns a copy whose button carries `identifier` for UI automation; `nil` removes it.
    public func accessibilityIdentifier(_ identifier: String?) -> Self {
        var copy = self
        copy.accessibility.identifier = identifier
        return copy
    }

    /// Returns a copy whose button speaks `hint` after its label; `nil` removes it.
    public func accessibilityHint(_ hint: String?) -> Self {
        var copy = self
        copy.accessibility.hint = hint
        return copy
    }
}

#Preview("Dismiss toolbar button") {
    NavigationStack {
        Text("Content")
            .navigationTitle("Sheet Title")
            .toolbar {
                DismissToolbarButton {}
            }
    }
}
