import Components
import SwiftUI

@main
struct ChatAccessibilityApp: App {
    var body: some Scene {
        WindowGroup {
            ChatBubble(role: .assistant) {
                Text("The requested item is ready.")
            }
        }
    }
}
