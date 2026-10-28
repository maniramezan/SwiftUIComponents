import Observation
import SwiftUI

struct StructuredChatRequest: Equatable {
    let role: ChatMessageRole
    let content: String
    let isTyping: Bool
    let autoPromotingHeadings: [String]
    let minimumSectionCount: Int
}

@MainActor
@Observable
final class StructuredChatPresentation {
    private(set) var request: StructuredChatRequest?
    private(set) var sections: [StructuredChatSection]?
    private(set) var text: AttributedString?
    private let parse: (String, [String], Int) -> [StructuredMessageParser.Section]?

    init(
        parse: @escaping (String, [String], Int) -> [StructuredMessageParser.Section]? = {
            StructuredMessageParser.sections(from: $0, autoPromotingHeadings: $1, minimumSectionCount: $2)
        }
    ) {
        self.parse = parse
    }

    func update(_ request: StructuredChatRequest) {
        guard self.request != request else { return }
        let sections =
            request.role == .assistant && !request.isTyping
            ? parse(request.content, request.autoPromotingHeadings, request.minimumSectionCount)?
                .map(StructuredChatSection.init) : nil
        self.sections = sections
        text =
            sections == nil && request.role == .assistant
            ? AttributedString(markdownOrPlainText: request.content) : nil
        self.request = request
    }
}

struct StructuredChatSection: Identifiable {
    let id: String
    let title: String
    let body: AttributedString

    init(_ section: StructuredMessageParser.Section) {
        id = section.id
        title = section.title
        body = AttributedString(markdownOrPlainText: section.body)
    }
}
