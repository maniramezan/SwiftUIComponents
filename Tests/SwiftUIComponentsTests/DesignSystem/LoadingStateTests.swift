import DesignSystem
import Testing

private struct StubFailure: Error, Equatable, Sendable {
    let message: String
}

private typealias TestState = LoadingState<String, StubFailure>

@Suite("LoadingState")
struct LoadingStateTests {

    @Test("idle reports neither loading nor loaded")
    func idle() {
        let state: TestState = .idle
        #expect(state.isLoading == false)
        #expect(state.isLoaded == false)
        #expect(state.value == nil)
        #expect(state.failure == nil)
    }

    @Test("loading reports isLoading but not isLoaded")
    func loading() {
        let state: TestState = .loading
        #expect(state.isLoading == true)
        #expect(state.isLoaded == false)
        #expect(state.value == nil)
        #expect(state.failure == nil)
    }

    @Test("loaded carries the value and reports isLoaded")
    func loaded() {
        let state: TestState = .loaded("hello")
        #expect(state.isLoading == false)
        #expect(state.isLoaded == true)
        #expect(state.value == "hello")
        #expect(state.failure == nil)
    }

    @Test("failed carries the failure")
    func failed() {
        let failure = StubFailure(message: "boom")
        let state: TestState = .failed(failure)
        #expect(state.isLoading == false)
        #expect(state.isLoaded == false)
        #expect(state.value == nil)
        #expect(state.failure == failure)
    }

    @Test("equality matches identical cases")
    func equality() {
        #expect((TestState.idle) == TestState.idle)
        #expect(TestState.loading == TestState.loading)
        #expect(TestState.loaded("a") == TestState.loaded("a"))
        #expect(TestState.loaded("a") != TestState.loaded("b"))
        let failure = StubFailure(message: "x")
        #expect(TestState.failed(failure) == TestState.failed(failure))
        #expect(TestState.failed(failure) != TestState.failed(StubFailure(message: "y")))
        #expect(TestState.loading != TestState.idle)
    }
}
