import DesignSystem
import SwiftUI

/// A context card shown at the top of an assistant conversation, describing
/// what the user is getting help with — for example the word or grammar
/// rule a word/grammar-help assistant is explaining.
///
/// Callers resolve their own localized strings; this component owns no
/// copy of its own.
///
/// ```swift
/// AssistantContextCard(
///     title: "hello",
///     highlight: "Hola",
///     bodyText: "Hello, how are you today?",
///     bodyStyle: .quoted,
///     footnote: "From: Everyday English"
/// )
/// ```
public struct AssistantContextCard: View {

    /// How the context card's body text should be styled.
    public enum BodyStyle: Sendable {
        /// Renders italic and wrapped in curly quotes — for quoting a
        /// sentence the word/phrase appeared in.
        case quoted
        /// Renders as a normal secondary line — for a plain description
        /// such as a grammar form pattern.
        case plain
    }

    private let title: String
    private let highlight: String?
    private let bodyText: String?
    private let bodyStyle: BodyStyle
    private let footnote: String?

    /// Creates an assistant context card.
    ///
    /// - Parameters:
    ///   - title: The primary subject, e.g. the word or grammar rule name.
    ///   - highlight: An optional emphasized subtitle, e.g. a translation
    ///     or difficulty level. Hidden when `nil` or empty.
    ///   - bodyText: An optional supporting line, e.g. an example sentence
    ///     or form pattern. Hidden when `nil` or empty.
    ///   - bodyStyle: How `bodyText` is styled. Defaults to `.plain`.
    ///   - footnote: An optional trailing caption, e.g. a source
    ///     attribution. Hidden when `nil` or empty.
    public init(
        title: String,
        highlight: String? = nil,
        bodyText: String? = nil,
        bodyStyle: BodyStyle = .plain,
        footnote: String? = nil
    ) {
        self.title = title
        self.highlight = highlight
        self.bodyText = bodyText
        self.bodyStyle = bodyStyle
        self.footnote = footnote
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            Text(title)
                .font(theme.typography.title3.weight(.semibold))
                .foregroundStyle(theme.colors.textPrimary)

            if let highlight, !highlight.isEmpty {
                Text(highlight)
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.primary)
            }

            if let bodyText, !bodyText.isEmpty {
                AssistantContextCardBodyLine(text: bodyText, style: bodyStyle)
                    .font(theme.typography.subheadline)
                    .foregroundStyle(theme.colors.textSecondary)
                    .fixedSize(horizontal: false, vertical: true)
            }

            if let footnote, !footnote.isEmpty {
                Text(footnote)
                    .font(theme.typography.caption)
                    .foregroundStyle(theme.colors.textTertiary)
            }
        }
        .designNoticeCard(
            background: theme.colors.containerSecondary,
            padding: theme.spacing.threeUnits
        )
    }

}

private struct AssistantContextCardBodyLine: View {
    let text: String
    let style: AssistantContextCard.BodyStyle

    var body: some View {
        switch style {
        case .quoted:
            Text("“\(text)”").italic()
        case .plain:
            Text(text)
        }
    }
}

#Preview("Word context") {
    PreviewContent { theme in
        AssistantContextCard(
            title: "hello",
            highlight: "Hola",
            bodyText: "Hello, how are you today?",
            bodyStyle: .quoted,
            footnote: "From: Everyday English"
        )
        .padding(theme.spacing.twoUnits)
    }
}

#Preview("Grammar context") {
    PreviewContent { theme in
        AssistantContextCard(
            title: "Present Perfect",
            highlight: "B1",
            bodyText: "have/has + past participle",
            bodyStyle: .plain
        )
        .padding(theme.spacing.twoUnits)
    }
}
