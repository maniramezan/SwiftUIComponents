import SwiftUI

/// Toolbar confirmation button pinned at the trailing edge when the system supports it.
///
/// Accepts a configurable system image and accessibility label. Use this as the standard
/// save, add, or accept button in sheets and modal presentations. Attach an automation
/// identifier or VoiceOver hint with ``accessibilityIdentifier(_:)`` and ``accessibilityHint(_:)``.
public struct ConfirmToolbarButton: ToolbarContent {
    private let systemImage: String
    private let accessibilityLabel: String
    private let isDisabled: Bool
    private let action: () -> Void
    private(set) var accessibility: ControlAccessibility

    /// Creates a confirm toolbar button.
    /// - Parameters:
    ///   - systemImage: SF Symbol name for the button icon. Defaults to `"checkmark"`.
    ///   - accessibilityLabel: VoiceOver label describing the action.
    ///   - accessibilityIdentifier: Optional identifier for UI automation. `nil` keeps the
    ///     system default.
    ///   - isDisabled: Whether the button is disabled.
    ///   - action: Closure invoked on tap.
    public init(
        systemImage: String = "checkmark",
        accessibilityLabel: String,
        accessibilityIdentifier: String? = nil,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.systemImage = systemImage
        self.accessibilityLabel = accessibilityLabel
        self.isDisabled = isDisabled
        self.action = action
        self.accessibility = ControlAccessibility(identifier: accessibilityIdentifier)
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

    public var body: some ToolbarContent {
        #if canImport(UIKit)
            ToolbarItem(placement: Self.placement) {
                ToolbarConfirmationContent(
                    title: accessibilityLabel,
                    systemImage: systemImage,
                    isDisabled: isDisabled,
                    accessibility: accessibility,
                    action: action
                )
            }
        #else
            ToolbarItem(placement: .confirmationAction) {
                ToolbarConfirmationContent(
                    title: accessibilityLabel,
                    systemImage: systemImage,
                    isDisabled: isDisabled,
                    accessibility: accessibility,
                    action: action
                )
            }
        #endif
    }

    #if canImport(UIKit)
        private static var placement: ToolbarItemPlacement {
            if #available(iOS 27, *) {
                return .topBarPinnedTrailing
            }
            return .topBarTrailing
        }
    #endif
}

struct ToolbarConfirmationContent: View {
    let title: String
    let systemImage: String
    let isDisabled: Bool
    var accessibility = ControlAccessibility()
    let action: () -> Void

    var body: some View {
        Button(title, systemImage: systemImage, action: action)
            .labelStyle(.iconOnly)
            .disabled(isDisabled)
            .modifier(ControlAccessibilityModifier(accessibility: accessibility))
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
