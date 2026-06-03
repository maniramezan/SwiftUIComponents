import SwiftUI

/// Applies `.searchable` only when enabled, keeping non-searchable sheets free of a search field.
struct OptionalSearchable: ViewModifier {
    let isEnabled: Bool
    @Binding var text: String
    let prompt: String

    func body(content: Content) -> some View {
        if isEnabled {
            content.searchable(text: $text, prompt: Text(prompt))
        } else {
            content
        }
    }
}
