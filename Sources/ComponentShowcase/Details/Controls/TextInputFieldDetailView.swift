import Components
import DesignSystem
import SwiftUI

/// Showcases ``TextInputField`` with live controls for its prompt, helper, error, and
/// secure-entry states.
struct TextInputFieldDetailView: View {
    @State private var text = ""
    @State private var title = "Email"
    @State private var showsPrompt = true
    @State private var showsHelper = true
    @State private var validatesEmail = true
    @State private var isSecure = false
    @Environment(\.designTheme) private var theme

    /// A deliberately simple rule so the error state can be toggled by typing.
    private var errorMessage: String? {
        guard validatesEmail, !text.isEmpty, !text.contains("@") else { return nil }
        return "Enter a valid email address."
    }

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Configurable field") {
                TextInputField(
                    title,
                    text: $text,
                    prompt: showsPrompt ? "name@example.com" : nil,
                    helperText: showsHelper ? "Used for sign-in only." : nil,
                    errorMessage: errorMessage,
                    isSecure: isSecure
                )
            }

            ShowcaseSection("Controls") {
                TextField("Title", text: $title)
                    .textFieldStyle(.roundedBorder)
                Toggle("Prompt", isOn: $showsPrompt)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Helper text", isOn: $showsHelper)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Validate (error when no \"@\")", isOn: $validatesEmail)
                    .toggleStyle(ThemeToggleStyle())
                Toggle("Secure entry", isOn: $isSecure)
                    .toggleStyle(ThemeToggleStyle())
            }

            ShowcaseSection("Static states") {
                TextInputField("Name", text: .constant("Taylor"))
                TextInputField("Code", text: .constant("12"), errorMessage: "Codes are 6 digits.")
            }
        }
    }
}

#Preview {
    ScrollView {
        TextInputFieldDetailView()
            .padding()
    }
}
