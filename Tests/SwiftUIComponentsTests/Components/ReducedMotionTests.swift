import Components
import DesignSystem
import SwiftUI
import Testing

@MainActor
@Suite("Reduced Motion components")
struct ReducedMotionTests {
    private struct SampleError: Error, Equatable, Sendable {}

    @Test("controls and feedback render with theme motion")
    func rendersWithThemeMotion() {
        let state: LoadingState<String, SampleError> = .loading
        let view = VStack {
            Button("Action") {}
                .buttonStyle(ThemeButtonStyle())
            Toggle("Enabled", isOn: .constant(true))
                .toggleStyle(ThemeToggleStyle())
            CompactActionButton(title: "Action", icon: "bolt") {}
            AsyncContentView(state: state) { value in
                Text(value)
            } loadingContent: {
                Text("Loading")
            } errorContent: { _ in
                Text("Error")
            }
        }
        .toast("Saved", isPresented: .constant(true), duration: nil)

        renderForCoverage(view)
    }
}
