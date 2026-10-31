import SwiftUI
import Testing

@testable import Components

@MainActor
@Suite("ChatComposer")
struct ChatComposerTests {

    @Test(
        "trailing action follows draft and voice state",
        arguments: [
            ("", nil, true, ChatComposerAction.send(isEnabled: false)),
            ("Hi", nil, true, .send(isEnabled: true)),
            ("Hi", nil, false, .send(isEnabled: false)),
            ("  \n", ChatComposerVoiceState.idle, true, .startVoice(isEnabled: true)),
            ("", .idle, false, .startVoice(isEnabled: false)),
            ("", .unavailable, true, .startVoice(isEnabled: false)),
            ("Hi", .idle, true, .send(isEnabled: true)),
            ("Hi", .listening(level: 0.4), false, .stopVoice(level: 0.4)),
            ("", .listening(level: 3), true, .stopVoice(level: 1)),
            ("Hi", .processing, true, .processing),
        ] as [(String, ChatComposerVoiceState?, Bool, ChatComposerAction)]
    )
    func resolvesAction(
        text: String, voiceState: ChatComposerVoiceState?, isEnabled: Bool,
        expected: ChatComposerAction
    ) {
        #expect(
            ChatComposerAction.resolve(text: text, voiceState: voiceState, isEnabled: isEnabled)
                == expected)
    }

    @Test("editing pauses only while the transcript is live")
    func editing() {
        #expect(ChatComposerAction.send(isEnabled: true).allowsEditing)
        #expect(ChatComposerAction.startVoice(isEnabled: false).allowsEditing)
        #expect(!ChatComposerAction.stopVoice(level: 0).allowsEditing)
        #expect(!ChatComposerAction.processing.allowsEditing)
    }

    @Test("stopping is always tappable; processing never is")
    func tappable() {
        #expect(ChatComposerAction.send(isEnabled: true).isTappable)
        #expect(!ChatComposerAction.send(isEnabled: false).isTappable)
        #expect(!ChatComposerAction.startVoice(isEnabled: false).isTappable)
        #expect(ChatComposerAction.stopVoice(level: 0).isTappable)
        #expect(!ChatComposerAction.processing.isTappable)
    }

    @Test("each action has its own VoiceOver label")
    func labels() {
        #expect(String(localized: ChatComposerAction.send(isEnabled: true).accessibilityLabel) == "Send")
        #expect(
            String(localized: ChatComposerAction.startVoice(isEnabled: true).accessibilityLabel)
                == "Start voice input")
        #expect(
            String(localized: ChatComposerAction.stopVoice(level: 0).accessibilityLabel)
                == "Stop voice input")
        #expect(String(localized: ChatComposerAction.processing.accessibilityLabel) == "Processing speech")
    }

    @Test("listening ring grows with level and clamps")
    func ringScale() {
        #expect(ChatComposerAction.ringScale(for: 0) == 0.8)
        #expect(ChatComposerAction.ringScale(for: -1) == 0.8)
        #expect(ChatComposerAction.ringScale(for: 1) == 0.8 + ChatComposerAction.ringMaximumGrowth)
        #expect(ChatComposerAction.ringScale(for: 5) == ChatComposerAction.ringScale(for: 1))
        #expect(ChatComposerAction.ringScale(for: 0.5) < ChatComposerAction.ringScale(for: 0.9))
    }

    @Test("renders with a custom placeholder that differs from the field name")
    func rendersCustomPrompt() {
        renderForCoverage(
            ChatComposer(text: .constant(""), prompt: "Ask anything") {},
            size: CGSize(width: 320, height: 120))
    }

    @Test(
        "renders every state",
        arguments: [
            nil, ChatComposerVoiceState.idle, .listening(level: 0.6), .processing, .unavailable,
        ] as [ChatComposerVoiceState?])
    func renders(voiceState: ChatComposerVoiceState?) {
        renderForCoverage(
            ChatComposer(
                text: .constant(voiceState == .idle ? "" : "Draft"),
                prompt: "Write something",
                voiceInput: voiceState.map {
                    ChatComposerVoiceInput(state: $0, onStart: {}, onStop: {})
                },
                onSend: {}
            ))
    }

    @Test("renders with the default prompt and disabled")
    func rendersDefaults() {
        renderForCoverage(ChatComposer(text: .constant(""), isEnabled: false, onSend: {}))
    }

    @Test("voice input keeps its state and actions")
    func voiceInput() {
        var started = false
        var stopped = false
        let input = ChatComposerVoiceInput(
            state: .listening(level: 0.2), onStart: { started = true }, onStop: { stopped = true })
        input.onStart()
        input.onStop()
        #expect(input.state == .listening(level: 0.2))
        #expect(started && stopped)
    }
}
