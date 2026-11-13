import Components
import Foundation
import SwiftUI
import TestCommonsUI
import Testing

@testable import ComponentShowcase

#if canImport(AppKit)
    import AppKit
#endif

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

    @Test("the custom calendar renders with and without an existing answer")
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

    @Test("the custom calendar records its displayed date without a separate confirmation")
    func calendarRecordsDisplayedDate() throws {
        let start = Date(timeIntervalSinceReferenceDate: 800_000_000)
        let end = start.addingTimeInterval(60 * 60 * 24 * 30)
        let selected = start.addingTimeInterval(60 * 60 * 24)
        let model = QuestionnaireCalendarTestModel(range: start...end)
        let host = HostedView(
            QuestionnaireCalendarTestView(model: model), size: CGSize(width: 360, height: 450))
        defer { host.close() }
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.answer == .date(start))

        model.answer = .date(selected)
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.answer == .date(selected))

        model.range = end...end
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.answer == .date(end))

        model.answer = nil
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        #expect(model.answer == .date(end))
    }

    #if canImport(AppKit)
        @Test("built-in dates use a date field while the custom calendar uses a month grid")
        func dateAndCalendarHaveDistinctPresentations() throws {
            let start = Date(timeIntervalSinceReferenceDate: 800_000_000)
            let question = QuestionnaireQuestion(id: "date", prompt: "Choose a date", kind: .date(range: start...start))
            let dateHost = HostedView(
                QuestionnaireView(questions: [question], answers: .constant([:]), onSubmit: { _ in }),
                size: CGSize(width: 360, height: 450))
            defer { dateHost.close() }
            let calendarHost = HostedView(
                QuestionnaireShowcaseCalendar(label: question.prompt, range: start...start, answer: .constant(nil)),
                size: CGSize(width: 360, height: 450))
            defer { calendarHost.close() }
            #expect(dateHost.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
            #expect(calendarHost.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))

            let datePicker = try #require(findDatePicker(in: dateHost.hosting))
            let calendarPicker = try #require(findDatePicker(in: calendarHost.hosting))
            #expect(datePicker.datePickerStyle != .clockAndCalendar)
            #expect(calendarPicker.datePickerStyle == .clockAndCalendar)
            #expect(datePicker.dateValue == start)
            #expect(calendarPicker.dateValue == start)
        }

        private func findDatePicker(in view: NSView) -> NSDatePicker? {
            if let picker = view as? NSDatePicker { return picker }
            return view.subviews.lazy.compactMap { findDatePicker(in: $0) }.first
        }
    #endif
}

@MainActor
@Observable
private final class QuestionnaireCalendarTestModel {
    var range: ClosedRange<Date>
    var answer: QuestionnaireAnswer?

    init(range: ClosedRange<Date>) {
        self.range = range
    }
}

private struct QuestionnaireCalendarTestView: View {
    @Bindable var model: QuestionnaireCalendarTestModel

    var body: some View {
        QuestionnaireShowcaseCalendar(label: "Choose a date", range: model.range, answer: $model.answer)
    }
}
