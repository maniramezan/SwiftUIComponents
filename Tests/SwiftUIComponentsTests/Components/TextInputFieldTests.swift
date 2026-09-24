import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("TextInputField")
struct TextInputFieldTests {

    @Test("an error message wins over helper text")
    func errorWins() {
        let message = TextInputFieldMessage.resolve(helperText: "Helper", errorMessage: "Invalid")
        #expect(message == .error("Invalid"))
        #expect(message?.isError == true)
    }

    @Test("helper text shows when there is no error")
    func helperWithoutError() {
        #expect(TextInputFieldMessage.resolve(helperText: "Helper", errorMessage: nil) == .helper("Helper"))
        #expect(TextInputFieldMessage.resolve(helperText: "Helper", errorMessage: "") == .helper("Helper"))
    }

    @Test("empty or missing messages resolve to nothing")
    func noMessage() {
        #expect(TextInputFieldMessage.resolve(helperText: nil, errorMessage: nil) == nil)
        #expect(TextInputFieldMessage.resolve(helperText: "", errorMessage: "") == nil)
    }

    @Test("renders plain, secure, helper, and error states")
    func rendersVariants() {
        renderForCoverage(
            VStack {
                TextInputField("Name", text: .constant(""))
                TextInputField("Email", text: .constant("a@"), prompt: "name@example.com", errorMessage: "Invalid")
                TextInputField("Password", text: .constant("secret"), helperText: "8+ characters", isSecure: true)
            },
            size: CGSize(width: 320, height: 400)
        )
    }
}
