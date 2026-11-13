import Foundation
import SwiftUI
import TestCommonsUI
import Testing

@testable import ComponentShowcase

@MainActor
@Suite("Numeric input showcase", .serialized)
struct NumericInputDetailViewTests {
    @Test("numeric input is reachable from the controls group and renders its live controls")
    func rendersNumericInput() throws {
        #expect(ShowcaseComponent.numericInput.group == "Controls")
        #expect(!ShowcaseComponent.numericInput.systemImage.isEmpty)
        let host = HostedView(
            ShowcaseDetailView(component: .numericInput), size: CGSize(width: 500, height: 650))
        defer { host.close() }
        #expect(host.waitForStableRender(minimumFrames: 3, requiredStableFrames: 2))
        let png = try #require(host.renderPNG())
        if let directory = ProcessInfo.processInfo.environment["NUMERIC_INPUT_EVIDENCE_DIR"] {
            let url = URL(fileURLWithPath: directory, isDirectory: true)
            try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
            try png.write(to: url.appendingPathComponent("numeric-input.png"))
        }
    }
}
