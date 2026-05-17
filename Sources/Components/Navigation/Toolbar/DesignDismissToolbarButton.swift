import SwiftUI

/// Toolbar dismiss button (xmark) placed at the leading edge.
///
/// Use this as the standard close button in sheets and modal presentations.
public struct DesignDismissToolbarButton: ToolbarContent {
    private let action: () -> Void

    /// Creates a dismiss toolbar button.
    public init(action: @escaping () -> Void) {
        self.action = action
    }

    public var body: some ToolbarContent {
        #if canImport(UIKit)
            ToolbarItem(placement: .topBarLeading) {
                Button(action: action) {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel(String(localized: Strings.Toolbar.close))
            }
        #else
            ToolbarItem(placement: .cancellationAction) {
                Button(action: action) {
                    Image(systemName: "xmark")
                }
                .accessibilityLabel(String(localized: Strings.Toolbar.close))
            }
        #endif
    }
}

#Preview("Dismiss toolbar button") {
    NavigationStack {
        Text("Content")
            .navigationTitle("Sheet Title")
            .toolbar {
                DesignDismissToolbarButton {}
            }
    }
}
