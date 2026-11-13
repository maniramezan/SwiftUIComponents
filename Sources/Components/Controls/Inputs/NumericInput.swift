import Foundation
import SwiftUI

/// Filters a text input to decimal digits, with optional decimal and negative values.
///
/// Use `numericInput(text:allowsDecimal:allowsNegative:)` on a `TextField`
/// or ``TextInputField`` with the same text binding. Filtering applies to the initial
/// text, edits, pasted content, and changes to the options or environment locale.
/// This modifier filters characters; it does not validate a range or round values.
///
/// ```swift
/// TextInputField("Count", text: $count)
///     .numericInput(text: $count)
/// ```
public struct NumericInput: ViewModifier {
    @Binding private var text: String
    private let allowsDecimal: Bool
    private let allowsNegative: Bool
    @Environment(\.locale) private var locale

    /// Creates a numeric input filter.
    ///
    /// - Parameters:
    ///   - text: The same binding used by the text input being filtered.
    ///   - allowsDecimal: Allows one decimal separator from the environment locale.
    ///     Defaults to `false`.
    ///   - allowsNegative: Allows one leading minus sign. Defaults to `false`.
    public init(text: Binding<String>, allowsDecimal: Bool = false, allowsNegative: Bool = false) {
        self._text = text
        self.allowsDecimal = allowsDecimal
        self.allowsNegative = allowsNegative
    }

    /// Applies character filtering and a numeric keyboard on iOS and Mac Catalyst.
    public func body(content: Content) -> some View {
        content
            .modifier(NumericInputKeyboard(allowsDecimal: allowsDecimal, allowsNegative: allowsNegative))
            .onChange(of: text, initial: true) { _, _ in
                sanitizeText()
            }
            .onChange(of: locale) { _, _ in
                sanitizeText()
            }
            .onChange(of: allowsDecimal) { _, _ in
                sanitizeText()
            }
            .onChange(of: allowsNegative) { _, _ in
                sanitizeText()
            }
    }

    private func sanitizeText() {
        let filtered = NumericInputFilter.sanitize(
            text, locale: locale, allowsDecimal: allowsDecimal, allowsNegative: allowsNegative)
        if text != filtered {
            text = filtered
        }
    }
}

extension View {
    /// Keeps only decimal digits in a text input, optionally allowing decimals and negatives.
    ///
    /// Pass the input's own text binding. When enabled, decimals use the environment
    /// locale's separator and negatives use one leading minus sign. All other characters,
    /// including grouping separators, are removed. Empty text and incomplete numbers such
    /// as `-` or `0.` remain editable. Superscripts and fractions are not decimal digits.
    /// Initial text and later binding, locale, or option changes are filtered as well.
    /// On iOS and Mac Catalyst, this selects a number pad, decimal pad, or punctuation
    /// keyboard according to the allowed characters. Field styling is supplied by the caller.
    ///
    /// - Parameters:
    ///   - text: The same binding used by the text input being filtered.
    ///   - allowsDecimal: Allows one locale-specific decimal separator. Defaults to `false`.
    ///   - allowsNegative: Allows one leading minus sign. Defaults to `false`.
    public func numericInput(
        text: Binding<String>, allowsDecimal: Bool = false, allowsNegative: Bool = false
    ) -> some View {
        modifier(NumericInput(text: text, allowsDecimal: allowsDecimal, allowsNegative: allowsNegative))
    }
}

enum NumericInputFilter {
    nonisolated static func sanitize(
        _ text: String, locale: Locale, allowsDecimal: Bool, allowsNegative: Bool
    ) -> String {
        let decimalSeparator = locale.decimalSeparator ?? "."
        var result = ""
        var hasDecimalSeparator = false

        for character in text {
            if character.unicodeScalars.count == 1,
                character.unicodeScalars.allSatisfy(CharacterSet.decimalDigits.contains)
            {
                result.append(character)
            } else if allowsDecimal, !hasDecimalSeparator, String(character) == decimalSeparator {
                result.append(character)
                hasDecimalSeparator = true
            } else if allowsNegative, result.isEmpty, character == "-" || character == "−" {
                result.append("-")
            }
        }
        return result
    }
}

private struct NumericInputKeyboard: ViewModifier {
    let allowsDecimal: Bool
    let allowsNegative: Bool

    func body(content: Content) -> some View {
        #if os(iOS)
            content.keyboardType(allowsNegative ? .numbersAndPunctuation : allowsDecimal ? .decimalPad : .numberPad)
        #else
            content
        #endif
    }
}

#Preview("Numeric Input") {
    @Previewable @State var text = ""
    PreviewContent { theme in
        TextInputField("Count", text: $text)
            .numericInput(text: $text)
            .padding(theme.spacing.twoUnits)
    }
}
