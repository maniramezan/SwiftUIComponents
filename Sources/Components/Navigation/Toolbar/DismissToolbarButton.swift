import SwiftUI

/// Toolbar dismiss button (xmark) placed in the system's cancellation position.
///
/// Use this as the standard close button in sheets and modal presentations.
public struct DismissToolbarButton: ToolbarContent {
    private let action: () -> Void

    /// Creates a dismiss toolbar button.
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some ToolbarContent {
        ToolbarItem(placement: .cancellationAction) {
            Button(String(localized: Strings.Toolbar.close), systemImage: "xmark", action: action)
                .labelStyle(.iconOnly)
        }
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
