import SwiftUI

/// Toolbar confirmation button pinned at the trailing edge when the system supports it.
///
/// Accepts a configurable system image and accessibility label. Use this as the standard
/// save, add, or accept button in sheets and modal presentations.
public struct ConfirmToolbarButton: ToolbarContent {
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
            ToolbarItem(placement: Self.placement) {
                ToolbarConfirmationContent(
                    title: accessibilityLabel, systemImage: systemImage, isDisabled: isDisabled, action: action
                )
            }
        #else
            ToolbarItem(placement: .confirmationAction) {
                ToolbarConfirmationContent(
                    title: accessibilityLabel, systemImage: systemImage, isDisabled: isDisabled, action: action
                )
            }
        #endif
    }

    #if canImport(UIKit)
        private static var placement: ToolbarItemPlacement {
            #if canImport(SwiftUI, _version: 8.0)
                if #available(iOS 27, *) {
                    return .topBarPinnedTrailing
                }
            #endif
            return .topBarTrailing
        }
    #endif
}

private struct ToolbarConfirmationContent: View {
    let title: String
    let systemImage: String
    let isDisabled: Bool
    let action: () -> Void

    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .disabled(isDisabled)
    }
}

#Preview("Confirm toolbar button") {
    NavigationStack {
        Text("Content")
            .navigationTitle("Edit")
            .toolbar {
                DismissToolbarButton {}
                ConfirmToolbarButton(accessibilityLabel: "Save") {}
            }
    }
}

#Preview("Disabled confirm button") {
    NavigationStack {
        Text("No changes made")
            .navigationTitle("Edit")
            .toolbar {
                ConfirmToolbarButton(accessibilityLabel: "Save", isDisabled: true) {}
            }
    }
}
