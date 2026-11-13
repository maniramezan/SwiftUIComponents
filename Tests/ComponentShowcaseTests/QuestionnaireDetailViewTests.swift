import Components
import Foundation
import SwiftUI
import TestCommonsUI
import Testing

@testable import ComponentShowcase

@MainActor
@Suite("Questionnaire showcase", .serialized)
struct QuestionnaireDetailViewTests {
    @Test(
        "each input example is reachable without answering preceding questions",
        arguments: QuestionnaireExample.allCases)
    func rendersExample(example: QuestionnaireExample) throws {
        let host = HostedView(
            ScrollView { QuestionnaireDetailView(example: example) },
            size: CGSize(width: 600, height: 900))
        defer { host.close() }
        #expect(host.waitForStableRender(timeout: .seconds(2), minimumFrames: 3, requiredStableFrames: 2))
        let png = try #require(host.renderPNG())
        if let directory = ProcessInfo.processInfo.environment["QUESTIONNAIRE_EVIDENCE_DIR"] {
            let url = URL(fileURLWithPath: directory, isDirectory: true)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            try png.write(to: url.appendingPathComponent("\(example.rawValue).png"))
        }
    }

    @Test("the custom calendar renders both an unanswered and recorded date")
    func rendersCustomCalendar() throws {
        let start = Date(timeIntervalSinceReferenceDate: 800_000_000)
        for answer in [QuestionnaireAnswer?.none, .date(start)] {
            let host = HostedView(
                QuestionnaireShowcaseCalendar(label: "Choose a date", range: start...start, answer: .constant(answer)),
                size: CGSize(width: 360, height: 450))
            defer { host.close() }
            #expect(host.renderPNG() != nil)
        }
    }
}
