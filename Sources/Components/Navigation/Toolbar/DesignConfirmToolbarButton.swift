import SwiftUI

/// Toolbar confirmation button placed at the trailing edge.
///
/// Accepts a configurable system image and accessibility label. Use this as the standard
/// save, add, or accept button in sheets and modal presentations.
public struct DesignConfirmToolbarButton: ToolbarContent {
    private let systemImage: String
    private let accessibilityLabel: String
    private let isDisabled: Bool
    private let action: () -> Void

    /// Creates a confirm toolbar button.
    /// - Parameters:
    ///   - systemImage: SF Symbol name for the button icon. Defaults to `"checkmark"`.
    ///   - accessibilityLabel: VoiceOver label describing the action.
    ///   - isDisabled: Whether the button is disabled.
    ///   - action: Closure invoked on tap.
    public init(
        systemImage: String = "checkmark",
        accessibilityLabel: String,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.isDisabled = isDisabled
        self.action = action
    }

    public var body: some ToolbarContent {
        #if canImport(UIKit)
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: action) {
                    Image(systemName: systemImage)
                }
                .disabled(isDisabled)
                .accessibilityLabel(accessibilityLabel)
            }
        #else
            ToolbarItem(placement: .confirmationAction) {
                Button(action: action) {
                    Image(systemName: systemImage)
                }
                .disabled(isDisabled)
                .accessibilityLabel(accessibilityLabel)
            }
        #endif
    }
}
