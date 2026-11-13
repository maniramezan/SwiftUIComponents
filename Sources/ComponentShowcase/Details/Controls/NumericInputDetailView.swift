import Components
import DesignSystem
import SwiftUI

struct NumericInputDetailView: View {
    @State private var text = ""
    @State private var allowsDecimal = false
    @State private var allowsNegative = false
    @State private var localeIdentifier = "en_US"
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Numeric input") {
                TextInputField("Value", text: $text, helperText: "Type or paste text to filter it.")
                    .numericInput(text: $text, allowsDecimal: allowsDecimal, allowsNegative: allowsNegative)
                    .environment(\.locale, Locale(identifier: localeIdentifier))
                Text("Filtered text: \(text)")
                    .font(theme.typography.body)
                    .foregroundStyle(theme.colors.textSecondary)
            }

            ShowcaseSection("Controls") {
                Toggle("Allow decimals", isOn: $allowsDecimal)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Allow negatives", isOn: $allowsNegative)
                    .toggleStyle(ThemeToggleStyle())
                Picker("Locale", selection: $localeIdentifier) {
                    Text("English (US)").tag("en_US")
                    Text("German").tag("de_DE")
                    Text("Arabic").tag("ar_EG")
                }
                Button("Insert mixed text") {
                    let separator = Locale(identifier: localeIdentifier).decimalSeparator ?? "."
                    text = "-12a\(separator)3b4!"
                }
                Button("Clear") {
                    text = ""
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        NumericInputDetailView()
            .padding()
    }
}
