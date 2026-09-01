import Foundation

extension AttributedString {
    /// Initializes an `AttributedString` by parsing `string` as Markdown with
    /// full syntax interpretation, falling back to plain text when the source
    /// is not parseable as Markdown.
    ///
    /// Use for user- or model-provided strings that *may* contain Markdown but
    /// must never crash on malformed input.
    ///
    /// - Parameter string: The source text to render.
    init(markdownOrPlainText string: String) {
        if let parsed = try? AttributedString(
            markdown: string,
            options: AttributedString.MarkdownParsingOptions(interpretedSyntax: .full)
        ) {
            self = parsed
        } else {
            self.init(string)
        }
    }
}
