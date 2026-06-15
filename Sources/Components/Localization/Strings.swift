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

        static func accessibilityLabel(_ message: String) -> LocalizedStringResource {
            LocalizedStringResource(
                "Error: \(message)",
                bundle: .atURL(Bundle.module.bundleURL),
                comment:
                    "Accessibility label for an inline error banner. The interpolated value is the error message; the \"Error\" prefix conveys the error nature to VoiceOver users, who cannot perceive the red tint."
            )
        }
    }

    enum Search {
        static let clearButton = LocalizedStringResource(
            "Clear search",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility label for the button that clears the current text in a search field."
        )
    }

    enum Toast {
        /// Accessibility label for a toast, prefixed with its role so VoiceOver
        /// users perceive the semantic nature that the color tint conveys visually.
        static func accessibilityLabel(role: ToastRole, message: String) -> LocalizedStringResource {
            switch role {
            case .info:
                return LocalizedStringResource(
                    "Information: \(message)",
                    bundle: .atURL(Bundle.module.bundleURL),
                    comment:
                        "Accessibility label for an informational toast. The interpolated value is the message; the \"Information\" prefix conveys the role to VoiceOver users, who cannot perceive the tint."
                )
            case .success:
                return LocalizedStringResource(
                    "Success: \(message)",
                    bundle: .atURL(Bundle.module.bundleURL),
                    comment:
                        "Accessibility label for a success toast. The interpolated value is the message; the \"Success\" prefix conveys the role to VoiceOver users, who cannot perceive the tint."
                )
            case .warning:
                return LocalizedStringResource(
                    "Warning: \(message)",
                    bundle: .atURL(Bundle.module.bundleURL),
                    comment:
                        "Accessibility label for a warning toast. The interpolated value is the message; the \"Warning\" prefix conveys the role to VoiceOver users, who cannot perceive the tint."
                )
            case .error:
                return LocalizedStringResource(
                    "Error: \(message)",
                    bundle: .atURL(Bundle.module.bundleURL),
                    comment:
                        "Accessibility label for an error toast. The interpolated value is the message; the \"Error\" prefix conveys the role to VoiceOver users, who cannot perceive the tint."
                )
            }
        }
    }

    enum Chat {
        static let typingIndicator = LocalizedStringResource(
            "Typing",
            bundle: .atURL(Bundle.module.bundleURL),
            comment:
                "Accessibility label for the animated three-dot indicator shown while a response is being composed."
        )
    }

    enum Button {
        static let loading = LocalizedStringResource(
            "Loading",
            bundle: .atURL(Bundle.module.bundleURL),
            comment:
                "Accessibility value announced on a button while it is in its loading state and temporarily disabled."
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

    enum FlipCard {
        static let flipAction = LocalizedStringResource(
            "Flip",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility custom action label for flipping a two-sided card to its other face."
        )

        static let flipHint = LocalizedStringResource(
            "Double tap to flip the card",
            bundle: .atURL(Bundle.module.bundleURL),
            comment: "Accessibility hint describing that activating the card flips it to reveal the other face."
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
