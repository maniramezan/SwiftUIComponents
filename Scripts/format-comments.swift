import Foundation
import SwiftParser
import SwiftSyntax

// Use Swift's parser so comment markers in strings, raw strings, and regexes stay untouched.
func separateComments(_ source: String) -> String {
    let originalTokens = Parser.parse(source: source).tokens(viewMode: .sourceAccurate).map(\.text)
    var bytes = Array(source.utf8)
    while true {
        let tree = Parser.parse(source: String(decoding: bytes, as: UTF8.self))
        var changed = false
        tokenLoop: for token in tree.tokens(viewMode: .sourceAccurate) {
            let trivia = [
                (token.position.utf8Offset, token.leadingTrivia),
                (token.endPositionBeforeTrailingTrivia.utf8Offset, token.trailingTrivia),
            ]
            for (start, pieces) in trivia {
                var offset = start
                for piece in pieces {
                    let length = piece.sourceLength.utf8Length
                    defer { offset += length }
                    switch piece {
                    case .lineComment, .docLineComment, .blockComment, .docBlockComment:
                        break
                    default:
                        continue
                    }
                    let end = offset + length
                    let lineStart = (bytes[..<offset].lastIndex(of: 10).map { $0 + 1 }) ?? 0
                    let lineEnd = bytes[end...].firstIndex(of: 10) ?? bytes.count
                    let indentationEnd = bytes[lineStart..<offset].firstIndex { $0 != 32 && $0 != 9 } ?? offset
                    let indent = Array(bytes[lineStart..<indentationEnd])
                    if indentationEnd < offset {
                        var removalStart = offset
                        while removalStart > lineStart && [9, 32].contains(bytes[removalStart - 1]) {
                            removalStart -= 1
                        }
                        let hasSuffix = bytes[end..<lineEnd].contains { ![9, 13, 32].contains($0) }
                        let comment = Array(bytes[offset..<end])
                        bytes.replaceSubrange(removalStart..<end, with: hasSuffix ? [32] : [])
                        bytes.insert(contentsOf: indent + comment + [10], at: lineStart)
                    } else if bytes[end..<lineEnd].contains(where: { ![9, 13, 32].contains($0) }) {
                        var suffixStart = end
                        while suffixStart < lineEnd && [9, 32].contains(bytes[suffixStart]) {
                            suffixStart += 1
                        }
                        bytes.replaceSubrange(end..<suffixStart, with: [10] + indent)
                    } else {
                        continue
                    }
                    changed = true
                    break tokenLoop
                }
            }
        }
        if !changed {
            let formatted = String(decoding: bytes, as: UTF8.self)
            let formattedTokens = Parser.parse(source: formatted).tokens(viewMode: .sourceAccurate).map(\.text)
            guard originalTokens == formattedTokens else {
                fputs(
                    "Cannot safely move a comment across string content; place it on a separate line manually.\n",
                    stderr)
                exit(1)
            }
            return formatted
        }
    }
}

// Swift examples can be fenced or indented, including inside a Markdown template.
func formatMarkdown(_ source: String) -> String {
    let lines = source.components(separatedBy: "\n")
    var output: [String] = []
    var index = 0
    while index < lines.count {
        let trimmed = lines[index].trimmingCharacters(in: .whitespaces)
        if trimmed == "```swift" || trimmed == "```markdown" {
            let opening = lines[index]
            let markdown = trimmed == "```markdown"
            index += 1
            let start = index
            while index < lines.count && lines[index].trimmingCharacters(in: .whitespaces) != "```" {
                index += 1
            }
            let content = lines[start..<index].joined(separator: "\n")
            output.append(opening)
            output.append(markdown ? formatMarkdown(content) : separateComments(content))
            if index < lines.count { output.append(lines[index]) }
        } else if lines[index].hasPrefix("    ") || lines[index].hasPrefix("\t") {
            let start = index
            while index < lines.count && (lines[index].hasPrefix("    ") || lines[index].hasPrefix("\t")) {
                index += 1
            }
            output.append(separateComments(lines[start..<index].joined(separator: "\n")))
            continue
        } else {
            output.append(lines[index])
        }
        index += 1
    }
    return output.joined(separator: "\n")
}

func formatSwift(_ source: String) -> String {
    let separated = separateComments(source)
    let tree = Parser.parse(source: separated)
    let converter = SourceLocationConverter(fileName: "", tree: tree)
    var docLines: Set<Int> = []
    for token in tree.tokens(viewMode: .sourceAccurate) {
        let trivia = [
            (token.position.utf8Offset, token.leadingTrivia),
            (token.endPositionBeforeTrailingTrivia.utf8Offset, token.trailingTrivia),
        ]
        for (start, pieces) in trivia {
            var offset = start
            for piece in pieces {
                if case .docLineComment = piece {
                    docLines.insert(converter.location(for: AbsolutePosition(utf8Offset: offset)).line)
                }
                offset += piece.sourceLength.utf8Length
            }
        }
    }
    let lines = separated.components(separatedBy: "\n")
    var output: [String] = []
    var index = 0
    while index < lines.count {
        let line = lines[index]
        guard docLines.contains(index + 1), let marker = line.range(of: "///"),
            line[..<marker.lowerBound].allSatisfy({ $0.isWhitespace })
        else {
            output.append(line)
            index += 1
            continue
        }
        let prefix = String(line[..<marker.lowerBound]) + "///"
        var documentation: [String] = []
        while index < lines.count && docLines.contains(index + 1) && lines[index].hasPrefix(prefix) {
            let content = String(lines[index].dropFirst(prefix.count))
            documentation.append(content.hasPrefix(" ") ? String(content.dropFirst()) : content)
            index += 1
        }
        for content in formatMarkdown(documentation.joined(separator: "\n")).components(separatedBy: "\n") {
            output.append(prefix + (content.isEmpty ? "" : " " + content))
        }
    }
    return output.joined(separator: "\n")
}

func runTests() {
    let cases: [(String, String)] = [
        ("let x = 1 // note\n", "// note\nlet x = 1\n"),
        ("    let x = 1 // note\n", "    // note\n    let x = 1\n"),
        ("let/* note */x = 1\n", "/* note */\nlet x = 1\n"),
        ("/* note */ let x = 1\n", "/* note */\nlet x = 1\n"),
        ("let x = 1 /* outer /* nested */ comment */\n", "/* outer /* nested */ comment */\nlet x = 1\n"),
        ("let x = \"https://example.com\"\n", "let x = \"https://example.com\"\n"),
        ("let x = #\"// literal\"#\n", "let x = #\"// literal\"#\n"),
        ("let x = /https:\\/\\/example/\n", "let x = /https:\\/\\/example/\n"),
        ("let x = \"\"\"\n// literal\n\"\"\"\n", "let x = \"\"\"\n// literal\n\"\"\"\n"),
        ("let café = 1 // Unicode\n", "// Unicode\nlet café = 1\n"),
    ]
    for (source, expected) in cases {
        let actual = separateComments(source)
        precondition(actual == expected, "Unexpected formatting: \(actual)")
        precondition(separateComments(actual) == actual, "Formatting must be idempotent")
    }
    let example = "```swift\nlet x = 1 // note\n```"
    precondition(formatMarkdown(example) == "```swift\n// note\nlet x = 1\n```")
    let doc = "/// ```swift\n/// let x = 1 // note\n/// ```\n"
    precondition(formatSwift(doc) == "/// ```swift\n/// // note\n/// let x = 1\n/// ```\n")
    let literal = "let text = \"\"\"\n/// ```swift\n/// let x = 1 // literal\n/// ```\n\"\"\"\n"
    precondition(formatSwift(literal) == literal)
    precondition(formatSwift("///No space\n") == "/// No space\n")
    print("Comment formatting tests passed (14 cases).")
}

let arguments = Array(CommandLine.arguments.dropFirst())
if arguments == ["--test"] {
    runTests()
} else {
    guard arguments == ["--lint"] || arguments == ["--fix"] else {
        fputs("usage: format-comments.sh --lint | --fix | --test\n", stderr)
        exit(2)
    }
    let fixing = arguments == ["--fix"]
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    process.arguments = ["ls-files", "--cached", "--others", "--exclude-standard", "-z", "--", "*.swift", "*.md"]
    let pipe = Pipe()
    process.standardOutput = pipe
    try process.run()
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    process.waitUntilExit()
    guard process.terminationStatus == 0 else { exit(process.terminationStatus) }
    let paths = String(decoding: data, as: UTF8.self).split(separator: "\0").map(String.init)
    var failures = 0
    for path in paths {
        guard FileManager.default.fileExists(atPath: path) else { continue }
        let source = try String(contentsOfFile: path, encoding: .utf8)
        let formatted = path.hasSuffix(".swift") ? formatSwift(source) : formatMarkdown(source)
        guard source != formatted else { continue }
        failures += 1
        if fixing {
            try formatted.write(toFile: path, atomically: true, encoding: .utf8)
            print("Moved inline comments: \(path)")
        } else {
            fputs("\(path): comments must be on separate lines; run ./Scripts/format.sh\n", stderr)
        }
    }
    if !fixing && failures > 0 { exit(1) }
}
