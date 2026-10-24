import Foundation

/// What a ``ChatComposer``'s trailing button does, derived from the draft and voice state.
enum ChatComposerAction: Equatable, Sendable {
    /// Sends the draft.
    case send(isEnabled: Bool)
    /// Starts voice input.
    case startVoice(isEnabled: Bool)
    /// Stops voice input; `level` drives the listening ring.
    case stopVoice(level: Double)
    /// Waits for the final transcript; not tappable.
    case processing

    /// Chooses the trailing action.
    ///
    /// Listening and processing take priority so the user can always stop recording. Otherwise a
    /// non-blank draft shows send, and an empty draft shows the microphone when voice input is
    /// configured (send, disabled, when it isn't).
    nonisolated static func resolve(
        text: String, voiceState: ChatComposerVoiceState?, isEnabled: Bool
    ) -> ChatComposerAction {
        switch voiceState {
        case .listening(let level):
            return .stopVoice(level: min(max(level, 0), 1))
        case .processing:
            return .processing
        default:
            break
        }
        let hasDraft = !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        if hasDraft {
            return .send(isEnabled: isEnabled)
        }
        switch voiceState {
        case .idle:
            return .startVoice(isEnabled: isEnabled)
        case .unavailable:
            return .startVoice(isEnabled: false)
        default:
            return .send(isEnabled: false)
        }
    }

    /// Whether the button responds to taps. Stopping a recording is always allowed.
    nonisolated var isTappable: Bool {
        switch self {
        case .send(let isEnabled), .startVoice(let isEnabled): isEnabled
        case .stopVoice: true
        case .processing: false
        }
    }

    /// The button's VoiceOver label.
    var accessibilityLabel: LocalizedStringResource {
        switch self {
        case .send: Strings.ChatComposer.sendButton
        case .startVoice: Strings.ChatComposer.startVoiceButton
        case .stopVoice: Strings.ChatComposer.stopVoiceButton
        case .processing: Strings.ChatComposer.processingVoice
        }
    }

    /// How much the listening ring grows beyond its resting size at full level.
    static let ringMaximumGrowth = 0.45

    /// The listening ring's scale for a `0...1` input level.
    nonisolated static func ringScale(for level: Double) -> Double {
        0.8 + min(max(level, 0), 1) * ringMaximumGrowth
    }

    /// Whether the draft field accepts edits. Typing is paused while the transcript is live.
    nonisolated var allowsEditing: Bool {
        switch self {
        case .stopVoice, .processing: false
        case .send, .startVoice: true
        }
    }
}
