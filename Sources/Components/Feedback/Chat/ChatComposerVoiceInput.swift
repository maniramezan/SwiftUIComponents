import Foundation

/// Voice-input configuration for a ``ChatComposer``.
///
/// Pass one to show a microphone button while the draft is empty. The caller owns recognition:
/// start it in `onStart`, write the live transcript into the composer's text binding so the user
/// can review and edit it, publish `state` as it changes, and stop in `onStop`.
///
/// ```swift
/// ChatComposer(
///     text: $draft,
///     voiceInput: ChatComposerVoiceInput(
///         state: recognizer.voiceState,
///         onStart: { recognizer.start() },
///         onStop: { recognizer.stop() }
///     ),
///     onSend: send
/// )
/// ```
public struct ChatComposerVoiceInput {
    /// The current voice-input state the composer renders.
    public var state: ChatComposerVoiceState
    /// Called when the user taps the microphone button.
    public var onStart: () -> Void
    /// Called when the user taps the stop button while listening.
    public var onStop: () -> Void

    /// Creates a voice-input configuration.
    /// - Parameters:
    ///   - state: The current voice-input state.
    ///   - onStart: Called when the user taps the microphone button.
    ///   - onStop: Called when the user taps the stop button while listening.
    public init(
        state: ChatComposerVoiceState,
        onStart: @escaping () -> Void,
        onStop: @escaping () -> Void
    ) {
        self.state = state
        self.onStart = onStart
        self.onStop = onStop
    }
}
