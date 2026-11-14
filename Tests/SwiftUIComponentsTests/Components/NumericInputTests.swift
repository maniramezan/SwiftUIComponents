import Foundation
import SwiftUI
import TestCommonsUI
import Testing

@testable import Components

#if canImport(AppKit)
    import AppKit
#endif

@MainActor
@Suite("NumericInput", .serialized)
struct NumericInputTests {
    @Test(
        "digits-only filtering removes letters, whitespace, symbols, and non-decimal numerals",
        arguments: [
            ("abc12def34", "1234"),
            (" \n-1,234.50!+", "123450"),
            ("²½Ⅳ1️⃣9", "9"),
            ("١٢۳۴５６", "١٢۳۴５６"),
            ("abc💡", ""),
            ("", ""),
        ])
    func digitsOnly(input: String, expected: String) {
        #expect(
            NumericInputFilter.sanitize(
                input, locale: Locale(identifier: "en_US"), allowsDecimal: false, allowsNegative: false) == expected)
    }

    @Test(
        "decimal filtering keeps only the first locale separator and one leading minus",
        arguments: [
            ("en_US", "-1,234.5a6.7!", "-1234.567"),
            ("de_DE", "-1.234,5a6,7!", "-1234,567"),
            ("ar_EG", "؜-١٬٢٣٤٫٥x٦٫٧!", "-١٢٣٤٫٥٦٧"),
            ("fa_IR", "‎−۱۲٫۵", "-۱۲٫۵"),
            ("en_US", "--12-3", "-123"),
            ("en_US", "12-3", "123"),
            ("en_US", "-.5", "-.5"),
            ("en_US", "-", "-"),
            ("en_US", "0.", "0."),
            ("en_US", ".", "."),
        ])
    func decimals(localeIdentifier: String, input: String, expected: String) {
        let locale = Locale(identifier: localeIdentifier)
        let filtered = NumericInputFilter.sanitize(input, locale: locale, allowsDecimal: true, allowsNegative: true)
        #expect(filtered == expected)
        #expect(
            NumericInputFilter.sanitize(filtered, locale: locale, allowsDecimal: true, allowsNegative: true) == filtered
        )
    }

    @Test("decimal and negative options work independently")
    func independentOptions() {
        let locale = Locale(identifier: "en_US")
        #expect(
            NumericInputFilter.sanitize("-12.5", locale: locale, allowsDecimal: true, allowsNegative: false) == "12.5")
        #expect(
            NumericInputFilter.sanitize("-12.5", locale: locale, allowsDecimal: false, allowsNegative: true) == "-125")
    }

    @Test("the modifier filters initial and externally replaced text and reacts to option changes")
    func filtersBindingAndConfigurationChanges() {
        let model = NumericInputTestModel()
        model.text = "a-12.5b"
        let host = HostedView(NumericInputTestView(model: model), size: CGSize(width: 320, height: 180))
        defer { host.close() }
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.text == "-12.5")

        model.text = "x-7.2.5z"
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.text == "-7.25")

        model.allowsNegative = false
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.text == "7.25")

        model.allowsDecimal = false
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.text == "725")

        model.allowsDecimal = true
        model.locale = Locale(identifier: "de_DE")
        model.text = "a8,5b"
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.text == "8,5")

        model.locale = Locale(identifier: "en_US")
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.text == "85")
    }

    #if canImport(AppKit)
        @Test("editing and pasting mixed text updates both the displayed field and its binding")
        func filtersVisibleText() throws {
            let model = NumericInputTestModel()
            let host = HostedView(NumericInputTestView(model: model), size: CGSize(width: 320, height: 180))
            defer { host.close() }
            #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            let field = try #require(editableTextField(in: host.hosting))

            for (input, expected) in [("12", "12"), ("12a", "12"), ("-3b4.5!", "-34.5"), ("abc", ""), ("", "")] {
                try replaceText(input, in: field, window: host.window)
                #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
                #expect(model.text == expected)
                #expect(field.stringValue == expected)
                #expect(field.currentEditor()?.string == expected)
            }
        }
    #endif
}

@MainActor
@Observable
private final class NumericInputTestModel {
    var text = ""
    var allowsDecimal = true
    var allowsNegative = true
    var locale = Locale(identifier: "en_US")
}

private struct NumericInputTestView: View {
    @Bindable var model: NumericInputTestModel

    var body: some View {
        TextInputField("Value", text: $model.text)
            .numericInput(text: $model.text, allowsDecimal: model.allowsDecimal, allowsNegative: model.allowsNegative)
            .environment(\.locale, model.locale)
    }
}
