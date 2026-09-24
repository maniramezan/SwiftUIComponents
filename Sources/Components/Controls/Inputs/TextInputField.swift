import DesignSystem
import SwiftUI

/// A labeled, themed text field with optional helper or error text beneath it.
///
/// The field sits on the theme's input surface (``InputSurface``) with a title above
/// it. Pass `errorMessage` to show a validation failure: the border and message switch
/// to the theme's `error` color, and VoiceOver hears the message as the field's hint,
/// prefixed with "Error". Otherwise `helperText`, if any, is shown in secondary text.
///
/// ```swift
/// TextInputField("Email", text: $email, prompt: "name@example.com",
///                helperText: "Used for sign-in only.",
///                errorMessage: isValid ? nil : "Enter a valid email address.")
///     .textContentType(.emailAddress)
///
/// TextInputField("Password", text: $password, isSecure: true)
/// ```
///
/// Apply keyboard, content-type, and submit modifiers to the `TextInputField` as you
/// would to a `TextField`; they flow through to the underlying field.
public struct TextInputField: View {
    @Binding private var text: String
    private let title: String
    private let prompt: String?
    private let helperText: String?
    private let errorMessage: String?
    private let isSecure: Bool
    @Environment(\.designTheme) private var theme

    /// Creates a labeled text field.
    ///
    /// - Parameters:
    ///   - title: The label shown above the field and read by VoiceOver. Rendered
    ///     verbatim, so localize it on your side.
    ///   - text: Two-way binding to the field's text.
    ///   - prompt: Optional placeholder shown while the field is empty.
    ///   - helperText: Optional guidance shown below the field when there is no error.
    ///   - errorMessage: Optional validation message. When non-`nil` and non-empty it
    ///     replaces `helperText` and switches the field to its error appearance.
    ///   - isSecure: When `true`, the field masks its input like a `SecureField`.
    ///     Defaults to `false`.
    public init(
        _ title: String,
        text: Binding<String>,
        prompt: String? = nil,
        helperText: String? = nil,
        errorMessage: String? = nil,
        isSecure: Bool = false
    ) {
        self._text = text
        self.title = title
        self.prompt = prompt
        self.helperText = helperText
        self.errorMessage = errorMessage
        self.isSecure = isSecure
    }

    /// The labeled field and its supporting message.
    public var body: some View {
        let message = TextInputFieldMessage.resolve(helperText: helperText, errorMessage: errorMessage)
        let isError = message?.isError ?? false
        VStack(alignment: .leading, spacing: theme.spacing.halfUnit) {
            Text(title)
                .font(theme.typography.subheadlineMedium)
                .foregroundStyle(theme.colors.textSecondary)
                // The field itself carries `title` as its label.
                .accessibilityHidden(true)

            TextInputFieldControl(title: title, text: $text, prompt: prompt, isSecure: isSecure)
                .padding(.horizontal, theme.spacing.oneAndHalfUnits)
                .frame(minHeight: theme.motion.minimumHitTarget)
                .designInputSurface()
                .overlay {
                    RoundedRectangle(cornerRadius: theme.radius.oneAndHalfUnits, style: .continuous)
                        .strokeBorder(isError ? theme.colors.error : Color.clear, lineWidth: theme.stroke.thin)
                }
                .accessibilityHint(hintText(for: message))

            if let message {
                TextInputFieldMessageLabel(message: message)
            }
        }
    }

    private func hintText(for message: TextInputFieldMessage?) -> Text {
        switch message {
        case .error(let text): Text(Strings.ErrorView.accessibilityLabel(text))
        case .helper(let text): Text(text)
        case nil: Text(verbatim: "")
        }
    }
}

// MARK: - Message

/// The supporting line shown beneath a ``TextInputField``.
enum TextInputFieldMessage: Equatable {
    /// Neutral guidance, shown in secondary text.
    case helper(String)
    /// A validation failure, shown in the error color.
    case error(String)

    /// Whether this message reports a validation failure.
    var isError: Bool {
        if case .error = self { true } else { false }
    }

    /// Picks the message to show: a non-empty error wins over a non-empty helper, and
    /// empty strings count as absent.
    nonisolated static func resolve(helperText: String?, errorMessage: String?) -> TextInputFieldMessage? {
        if let errorMessage, !errorMessage.isEmpty { return .error(errorMessage) }
        if let helperText, !helperText.isEmpty { return .helper(helperText) }
        return nil
    }
}

// MARK: - Subviews

/// The plain or secure text control inside a ``TextInputField``.
private struct TextInputFieldControl: View {
    let title: String
    @Binding var text: String
    let prompt: String?
    let isSecure: Bool

    @Environment(\.designTheme) private var theme

    var body: some View {
        Group {
            if isSecure {
                SecureField(title, text: $text, prompt: prompt.map { Text($0) })
            } else {
                TextField(title, text: $text, prompt: prompt.map { Text($0) })
            }
        }
        .font(theme.typography.field)
        .foregroundStyle(theme.colors.textPrimary)
    }
}

/// The helper or error line beneath a ``TextInputField``. Hidden from VoiceOver,
/// which hears the same text as the field's hint instead.
private struct TextInputFieldMessageLabel: View {
    let message: TextInputFieldMessage

    @Environment(\.designTheme) private var theme

    var body: some View {
        HStack(alignment: .firstTextBaseline, spacing: theme.spacing.halfUnit) {
            switch message {
            case .error(let text):
                Image(systemName: "exclamationmark.circle.fill")
                Text(text)
            case .helper(let text):
                Text(text)
            }
        }
        .font(theme.typography.footnote)
        .foregroundStyle(message.isError ? theme.colors.error : theme.colors.textSecondary)
        .accessibilityHidden(true)
    }
}

#Preview("Text Input Field") {
    @Previewable @State var email = "name@"
    @Previewable @State var password = ""

    PreviewContent { theme in
        VStack(spacing: theme.spacing.twoUnits) {
            TextInputField(
                "Email",
                text: $email,
                prompt: "name@example.com",
                errorMessage: "Enter a valid email address."
            )
            TextInputField("Password", text: $password, helperText: "At least 8 characters.", isSecure: true)
        }
        .padding(theme.spacing.twoUnits)
    }
}
