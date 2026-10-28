import Foundation

/// Parses complete Markdown messages into H2 sections without discarding content.
///
/// Returns `nil` when a nonempty preamble, an unclosed fence, or too few sections
/// requires rendering the original message. Headings inside fenced or indented code
/// remain body text. Bare labels are promoted only at the beginning of a logical line.
public enum StructuredMessageParser {
    /// A titled section whose identity follows its heading and duplicate occurrence.
    public struct Section: Identifiable, Sendable, Hashable {
        /// Deterministic identity, distinct even when headings repeat.
        public let id: String
        /// Heading text with emphasis and code markers removed.
        public let title: String
        /// Markdown between this heading and the next, with outer whitespace trimmed.
        public let body: String

        /// Creates a section with caller-owned identity and content.
        public init(id: String, title: String, body: String) {
            self.id = id
            self.title = title
            self.body = body
        }
    }

    /// Parses H2 sections, returning `nil` when the original message must be preserved.
    ///
    /// - Parameters:
    ///   - text: Complete Markdown source, including any fenced code.
    ///   - autoPromotingHeadings: Case-insensitive labels recognized at line starts.
    ///     A label must be followed by whitespace and body text beginning with an
    ///     uppercase or non-ASCII letter. Mid-sentence matches are never promoted.
    ///   - minimumSectionCount: Minimum number of sections, clamped to at least one.
    /// - Returns: Every section, including empty bodies, or `nil` for a plain fallback.
    public nonisolated static func sections(
        from text: String,
        autoPromotingHeadings: [String] = [],
        minimumSectionCount: Int = 2
    ) -> [Section]? {
        let lines = text.replacingOccurrences(of: "\r\n", with: "\n")
            .split(separator: "\n", omittingEmptySubsequences: false)
        var result: [Section] = []
        var occurrences: [String: Int] = [:]
        var title: String?
        var body: [String] = []
        var fence: (character: Character, count: Int)?

        func appendSection() {
            guard let title else { return }
            let occurrence = occurrences[title, default: 0]
            occurrences[title] = occurrence + 1
            result.append(
                Section(
                    id: "\(title)#\(occurrence)", title: title,
                    body: body.joined(separator: "\n").trimmingCharacters(in: .whitespacesAndNewlines)
                )
            )
        }

        for line in lines {
            let source = String(line)
            let trimmed = source.trimmingCharacters(in: .whitespaces)
            let indentation = source.prefix(while: { $0 == " " }).count
            if indentation < 4, let first = trimmed.first, first == "`" || first == "~" {
                let count = trimmed.prefix(while: { $0 == first }).count
                if count >= 3 {
                    if let current = fence {
                        if first == current.character, count >= current.count,
                            trimmed.dropFirst(count).trimmingCharacters(in: .whitespaces).isEmpty
                        {
                            fence = nil
                        }
                    } else {
                        fence = (first, count)
                    }
                    guard title != nil else { return nil }
                    body.append(source)
                    continue
                }
            }
            if fence == nil, indentation < 4, !source.hasPrefix("\t") {
                let heading: (title: String, body: String?)?
                if trimmed.hasPrefix("## ") {
                    heading = (String(trimmed.dropFirst(3)), nil)
                } else {
                    heading = promotedHeading(trimmed, labels: autoPromotingHeadings)
                }
                if let heading {
                    appendSection()
                    let cleaned = heading.title.replacingOccurrences(of: "**", with: "")
                        .replacingOccurrences(of: "__", with: "")
                        .replacingOccurrences(of: "`", with: "")
                        .trimmingCharacters(in: .whitespaces)
                    guard !cleaned.isEmpty else { return nil }
                    title = cleaned
                    body = heading.body.map { [$0] } ?? []
                    continue
                }
            }
            if title == nil {
                if !trimmed.isEmpty { return nil }
            } else {
                body.append(source)
            }
        }
        guard fence == nil else { return nil }
        appendSection()
        return result.count >= max(1, minimumSectionCount) ? result : nil
    }

    private nonisolated static func promotedHeading(_ line: String, labels: [String]) -> (String, String?)? {
        for label in labels where !label.isEmpty {
            guard let range = line.range(of: label, options: [.anchored, .caseInsensitive]) else { continue }
            let suffix = line[range.upperBound...]
            guard suffix.first?.isWhitespace == true else { continue }
            let body = suffix.trimmingCharacters(in: .whitespaces)
            guard let first = body.first,
                first.isUppercase || (first.isLetter && !first.isASCII)
            else { continue }
            return (String(line[range]), body)
        }
        return nil
    }
}
