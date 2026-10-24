import Foundation

/// Where a ``ChatComposer``'s voice input is in its lifecycle.
///
/// The composer only renders this state; the caller runs speech recognition and moves between
/// states as recognition starts, reports levels, and finishes.
public enum ChatComposerVoiceState: Equatable, Sendable {
    /// Voice input is ready. The composer shows a microphone button while the draft is empty.
    case idle
    /// The microphone is live. `level` is the current input loudness from `0` (silence) to `1`
    /// (loud), drawn as a pulsing ring around the stop button.
    case listening(level: Double)
    /// Recording stopped and the final transcript is being produced. The button shows progress
    /// and can't be tapped.
    case processing
    /// Voice input can't be used right now, for example because permission was denied. The
    /// microphone button is shown disabled.
    case unavailable
}
