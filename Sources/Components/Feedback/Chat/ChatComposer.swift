import DesignSystem
import SwiftUI

/// A chat message field with a send button and optional voice input.
///
/// The field grows with its text up to `lineLimit`. The trailing button sends a non-blank draft;
/// when `voiceInput` is set and the draft is empty, it becomes a microphone, then a stop button
/// with a level ring while listening. Write the live transcript into `text` so dictated messages
/// can be reviewed and edited before sending.
///
/// ```swift
/// @State private var draft = ""
///
/// ChatComposer(text: $draft, prompt: "Ask anything") {
///     send(draft)
///     draft = ""
/// }
/// ```
///
/// The composer never clears `text` itself; clear it in `onSend`. `prompt` is rendered verbatim,
/// so pass an already-localized string. The field is always named "Message" for assistive
/// technology, independent of `prompt`, which is only the visible placeholder. The button's
/// accessibility labels come from the package's String Catalog.
public struct ChatComposer: View {
    @Binding private var text: String
    private let prompt: String
    private let isEnabled: Bool
    private let lineLimit: ClosedRange<Int>
    private let voiceInput: ChatComposerVoiceInput?
    private let onSend: () -> Void
    @Environment(\.designTheme) private var theme

    /// Creates a composer.
    /// - Parameters:
    ///   - text: The draft. Typed text and any live transcript you write both land here.
    ///   - prompt: Placeholder shown while the draft is empty. Defaults to the package's
    ///     localized "Message" string.
    ///   - isEnabled: Whether sending and starting voice input are allowed, for example `false`
    ///     while a reply is streaming. Stopping an active recording is always allowed.
    ///   - lineLimit: How many lines the field grows to before it scrolls.
    ///   - voiceInput: Voice-input state and actions, or `nil` for a text-only composer.
    ///   - onSend: Called when the user sends a non-blank draft with the button or Return.
    public init(
        text: Binding<String>,
        prompt: String = String(localized: Strings.ChatComposer.placeholder),
        isEnabled: Bool = true,
        lineLimit: ClosedRange<Int> = 1...5,
        voiceInput: ChatComposerVoiceInput? = nil,
        onSend: @escaping () -> Void
    ) {
        self._text = text
        self.prompt = prompt
        self.isEnabled = isEnabled
        self.lineLimit = lineLimit
        self.voiceInput = voiceInput
        self.onSend = onSend
    }

    public var body: some View {
        let action = ChatComposerAction.resolve(
            text: text, voiceState: voiceInput?.state, isEnabled: isEnabled)
        HStack(alignment: .bottom, spacing: theme.spacing.oneUnit) {
            ChatComposerField(
                text: $text,
                prompt: prompt,
                lineLimit: lineLimit,
                isEditable: action.allowsEditing,
                onSubmit: submit
            )
            ChatComposerActionButton(
                action: action,
                onSend: submit,
                onStartVoice: { voiceInput?.onStart() },
                onStopVoice: { voiceInput?.onStop() }
            )
        }
    }

    private func submit() {
        guard isEnabled, !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return
        }
        onSend()
    }
}

/// The growing text field on the leading side of a ``ChatComposer``.
private struct ChatComposerField: View {
    @Binding var text: String
    let prompt: String
    let lineLimit: ClosedRange<Int>
    let isEditable: Bool
    let onSubmit: () -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        TextField(text: $text, prompt: Text(prompt), axis: .vertical) {
            Text(Strings.ChatComposer.fieldLabel)
        }
        .accessibilityLabel(Text(Strings.ChatComposer.fieldLabel))
        .lineLimit(lineLimit)
        .font(theme.typography.field)
        .foregroundStyle(theme.colors.textPrimary)
        .submitLabel(.send)
        .onSubmit(onSubmit)
        .disabled(!isEditable)
        .padding(.horizontal, theme.spacing.oneAndHalfUnits)
        .padding(.vertical, theme.spacing.oneUnit)
        .frame(minHeight: theme.motion.minimumHitTarget)
        .designInputSurface()
    }
}

/// The trailing send / microphone / stop / progress button of a ``ChatComposer``.
private struct ChatComposerActionButton: View {
    let action: ChatComposerAction
    let onSend: () -> Void
    let onStartVoice: () -> Void
    let onStopVoice: () -> Void
    @Environment(\.designTheme) private var theme

    var body: some View {
        Button(action: perform) {
            ChatComposerActionIcon(action: action)
                .frame(
                    minWidth: theme.motion.minimumHitTarget,
                    minHeight: theme.motion.minimumHitTarget
                )
                .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
        .disabled(!action.isTappable)
        .accessibilityLabel(Text(action.accessibilityLabel))
    }

    private func perform() {
        switch action {
        case .send: onSend()
        case .startVoice: onStartVoice()
        case .stopVoice: onStopVoice()
        case .processing: break
        }
    }

}

/// The glyph for a ``ChatComposerActionButton``.
private struct ChatComposerActionIcon: View {
    let action: ChatComposerAction
    @Environment(\.designTheme) private var theme

    var body: some View {
        switch action {
        case .send(let isEnabled):
            ChatComposerGlyph(systemName: "arrow.up.circle.fill", isEnabled: isEnabled)
        case .startVoice(let isEnabled):
            ChatComposerGlyph(systemName: "mic.circle.fill", isEnabled: isEnabled)
        case .stopVoice(let level):
            ZStack {
                ChatComposerLevelRing(level: level)
                ChatComposerGlyph(systemName: "stop.circle.fill", isEnabled: true)
            }
        case .processing:
            ProgressView()
                .tint(theme.colors.primary)
        }
    }
}

/// One SF Symbol glyph tinted for its enabled state.
private struct ChatComposerGlyph: View {
    let systemName: String
    let isEnabled: Bool
    @Environment(\.designTheme) private var theme

    var body: some View {
        Image(systemName: systemName)
            .font(theme.typography.title2)
            .foregroundStyle(isEnabled ? theme.colors.primary : theme.colors.textSecondary)
            .accessibilityHidden(true)
    }
}

/// A ring behind the stop button that grows with the input level while listening.
private struct ChatComposerLevelRing: View {
    let level: Double
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Circle()
            .fill(theme.colors.interactiveSubtle)
            .scaleEffect(reduceMotion ? 1 : ChatComposerAction.ringScale(for: level))
            .animation(theme.motion.animation(reducingMotion: reduceMotion), value: level)
            .accessibilityHidden(true)
    }
}

#Preview("Chat Composer") {
    @Previewable @State var draft = ""
    @Previewable @State var dictated = "This message was dictated"

    PreviewContent { theme in
        VStack(spacing: theme.spacing.twoUnits) {
            ChatComposer(text: $draft) {}
            ChatComposer(
                text: $draft,
                voiceInput: ChatComposerVoiceInput(state: .idle, onStart: {}, onStop: {})
            ) {}
            ChatComposer(
                text: $dictated,
                voiceInput: ChatComposerVoiceInput(
                    state: .listening(level: 0.6), onStart: {}, onStop: {})
            ) {}
            ChatComposer(
                text: $dictated,
                voiceInput: ChatComposerVoiceInput(state: .processing, onStart: {}, onStop: {})
            ) {}
        }
        .padding(theme.spacing.twoUnits)
    }
}
