import Foundation

/// Typed access to localized strings stored in the package string catalog.
enum Strings {
    enum MenuPicker {
        static func selectedOption(_ title: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "Selected option: \(title)",
                bundle: .atURL(Bundle.module.bundleURL),
                comment: "Accessibility label showing the currently selected value in the menu picker. The interpolated value is replaced with the selected option text."
            )
        }

        static let changeSelectionHint = LocalizedStringResource(
            "Opens a picker to change the selected value",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility hint describing that activating the menu picker opens a selection interface."
        )
    }
}
