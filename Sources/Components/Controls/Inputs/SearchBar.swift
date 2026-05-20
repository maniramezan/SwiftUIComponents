import DesignSystem
import SwiftUI

/// Reusable themed search field with optional focus binding.
///
/// ```swift
/// @State private var query = ""
///
/// SearchBar(text: $query, placeholder: "Search components") {
///     performSearch()
/// }
/// ```
///
/// ![A search bar with placeholder text](designSearchBar)
public struct SearchBar: View {
    @Binding private var text: String
    @Binding private var externalFocus: Bool
    private let usesExternalFocus: Bool
    private let placeholder: String
    private let onSubmit: (() -> Void)?
    @FocusState private var internalFocus: Bool
    @Environment(\.designTheme) private var theme

    /// Creates a themed search bar.
    /// - Parameters:
    ///   - text: Two-way binding to the current search string.
    ///   - placeholder: Hint text shown when the field is empty. Defaults to `"Search"`.
    ///   - isFocused: Optional external binding that mirrors the field's focus state.
    ///     Pass a binding to programmatically focus or blur the field.
    ///   - onSubmit: Closure called when the user submits the search (e.g. taps Return).
    public init(
        text: Binding<String>,
        placeholder: String = "Search",
        isFocused: Binding<Bool>? = nil,
        onSubmit: (() -> Void)? = nil
    ) {
        self._text = text
        self._externalFocus = isFocused ?? .constant(false)
        self.usesExternalFocus = isFocused != nil
        self.placeholder = placeholder
        self.onSubmit = onSubmit
    }

    public var body: some View {
        HStack(spacing: theme.spacing.oneUnit) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(theme.colors.textSecondary)
            TextField(placeholder, text: $text)
                .font(theme.typography.field)
                .foregroundStyle(theme.colors.textPrimary)
                .autocorrectionDisabled()
                .focused($internalFocus)
                .onSubmit { onSubmit?() }
            if !text.isEmpty {
                Button {
                    text = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(theme.colors.textTertiary)
                }
                .buttonStyle(.plain)
                .accessibilityLabel(Text("Clear search"))
            }
        }
        .padding(.horizontal, theme.spacing.oneAndHalfUnits)
        .frame(minHeight: theme.motion.minimumHitTarget)
        .designInputSurface()
        .onAppear(perform: syncFocus)
        .onChange(of: externalFocus) { _, _ in syncFocus() }
        .onChange(of: internalFocus) { _, isFocused in
            guard usesExternalFocus, externalFocus != isFocused else { return }
            externalFocus = isFocused
        }
    }

    private func syncFocus() {
        guard usesExternalFocus, internalFocus != externalFocus else { return }
        internalFocus = externalFocus
    }
}

#Preview("Design Search Bar") {
    @Previewable @State var query = ""

    PreviewContent { theme in
        SearchBar(text: $query, placeholder: "Search components")
            .padding(theme.spacing.twoUnits)
    }
}
