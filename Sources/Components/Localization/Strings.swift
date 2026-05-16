import Foundation

/// Typed access to localized strings stored in the package string catalog.
enum Strings {
    enum Toolbar {
        static let close = LocalizedStringResource(
            "Close",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility label for the dismiss/close button in sheets and modal presentations."
        )
    }

    enum ErrorView {
        static let defaultTitle = LocalizedStringResource(
            "Error",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Default section header title for error sections."
        )
    }

    enum MenuPicker {
        static func selectedOption(_ title: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "Selected option: \(title)",
                bundle: .atURL(Bundle.module.bundleURL),
                comment:
                    "Accessibility label showing the currently selected value in the menu picker. The interpolated value is replaced with the selected option text."
            )
        }

        static let changeSelectionHint = LocalizedStringResource(
            "Opens a picker to change the selected value",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility hint describing that activating the menu picker opens a selection interface."
        )
    }

    enum Pagination {
        static let indicatorLabel = LocalizedStringResource(
            "Page indicator",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility label for the page-position indicator of a paged view."
        )

        static func pageOfTotal(_ index: Int, _ total: Int, _ title: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "Page \(index) of \(total), \(title)",
                bundle: .atURL(Bundle.module.bundleURL),
                comment:
                    "Accessibility value announced for the page indicator. Interpolations are the 1-based page number, the total page count, and the title of the current page."
            )
        }

        static let nextPageAction = LocalizedStringResource(
            "Next page",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility action label for advancing the paged view to the next page."
        )

        static let previousPageAction = LocalizedStringResource(
            "Previous page",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility action label for moving the paged view to the previous page."
        )
    }
}
