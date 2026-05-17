import Foundation

/// Splits markdown text into typed sections at `## ` headings, with optional
/// auto-promotion of caller-supplied phrases into headings when the source
/// model emits them as bare leading labels.
///
/// Useful when wrapping LLM output where the model usually emits valid H2s
/// but sometimes drops the `## ` prefix — pass the known label set via
/// `autoPromotingHeadings:` and the parser will inject the missing prefix
/// before splitting.
///
/// ```swift
/// let sections = StructuredMessageParser.sections(
///     from: assistantResponse,
///     autoPromotingHeadings: ["Main Idea", "Examples", "Common Mistakes"]
/// )
/// ```
///
/// Returns `nil` when fewer than `minimumSectionCount` sections are found, so
/// callers can fall back to plain markdown rendering for unstructured text.
public enum StructuredMessageParser {

    /// A single titled block of body text parsed from the input.
    public struct Section: Identifiable, Sendable, Hashable {

        /// Stable identifier suitable for `ForEach` and SwiftData/Identifiable
        /// use. Generated fresh on each parse.
        public let id: UUID

        /// The section title (the text immediately after `## `, with markdown
        /// emphasis markers stripped).
        public let title: String

        /// The section body — every line between this heading and the next
        /// `## ` (or the end of input), trimmed of leading/trailing whitespace.
        public let body: String

        /// Creates a section. Most callers use `sections(from:)` instead.
        public init(id: UUID = UUID(), title: String, body: String) {
            self.id = id
            self.title = title
            self.body = body
        }
    }

    /// Parses `text` into H2 sections.
    ///
    /// - Parameters:
    ///   - text: Markdown text to split.
    ///   - autoPromotingHeadings: A list of literal phrases to promote into
    ///     H2 headings when found as bare leading labels. Matched
    ///     case-insensitively at the start of a logical line, where the
    ///     phrase is immediately followed by a capital letter or a
    ///     non-ASCII letter (signalling that the next sentence has begun
    ///     without a line break). Defaults to empty (no promotion).
    ///   - minimumSectionCount: The smallest number of sections that
    ///     justifies structured rendering; below this, returns `nil` so the
    ///     caller can fall back to plain markdown. Defaults to `2`.
    /// - Returns: An array of parsed sections, or `nil` when fewer than
    ///   `minimumSectionCount` sections were detected.
    public static func sections(
        from text: String,
        autoPromotingHeadings: [String] = [],
        minimumSectionCount: Int = 2
    ) -> [Section]? {
        let normalizedText = normalize(text, autoPromoting: autoPromotingHeadings)
        let lines = normalizedText.split(separator: "\n", omittingEmptySubsequences: false)
        var sections = [Section]()
        var currentTitle: String?
        var currentBody = [String]()

        func flushSection() {
            guard let title = currentTitle else { return }
            let body = currentBody.joined(separator: "\n").trimmingCharacters(
                in: .whitespacesAndNewlines
            )
            if !body.isEmpty {
                sections.append(Section(title: title, body: body))
            }
            currentTitle = nil
            currentBody = []
        }

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("## ") {
                flushSection()
                currentTitle = cleanedSectionTitle(
                    String(trimmed.dropFirst(3)).trimmingCharacters(in: .whitespaces)
                )
                continue
            }
            if currentTitle != nil {
                if currentBody.isEmpty, trimmed.isEmpty { continue }
                currentBody.append(String(line))
            }
        }
        flushSection()

        guard sections.count >= minimumSectionCount else { return nil }
        return sections
    }

    private static func cleanedSectionTitle(_ title: String) -> String {
        title
            .replacingOccurrences(of: "**", with: "")
            .replacingOccurrences(of: "__", with: "")
            .replacingOccurrences(of: "`", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    private static func normalize(_ text: String, autoPromoting labels: [String]) -> String {
        var normalized = text.replacingOccurrences(of: "\r\n", with: "\n")

        for label in labels {
            let escaped = NSRegularExpression.escapedPattern(for: label)
                .replacingOccurrences(of: " ", with: #"\s+"#)
            let pattern = #"(?i)(?<!#\#\s)(\#(escaped))\s*(?=[A-Z\p{L}])"#
            normalized = normalized.replacingOccurrences(
                of: pattern,
                with: "\n## $1\n\n",
                options: .regularExpression
            )
        }

        return normalized.replacingOccurrences(
            of: #"\n{3,}"#,
            with: "\n\n",
            options: .regularExpression
        )
        .trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
