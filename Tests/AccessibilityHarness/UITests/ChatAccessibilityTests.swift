import XCTest

final class ChatAccessibilityTests: XCTestCase {
    func testSpeakerGroupingPreservesMessageText() {
        let app = XCUIApplication()
        app.launch()
        defer { app.terminate() }
        XCTAssertTrue(app.staticTexts["The requested item is ready."].waitForExistence(timeout: 5))
    }
}
