import Components
import DesignSystem
import SwiftUI

/// Live controls for ``ChatComposer``: prompt, enabled state, line limit, and every voice state,
/// plus a simulated dictation that streams a transcript into the draft.
struct ChatComposerDetailView: View {
    @State private var draft = ""
    @State private var prompt = "Message"
    @State private var isEnabled = true
    @State private var maximumLines = 5
    @State private var showsVoiceInput = true
    @State private var voiceMode: VoiceMode = .idle
    @State private var level = 0.5
    @State private var sentMessages: [String] = []
    @State private var dictation: Task<Void, Never>?
    @Environment(\.designTheme) private var theme

    var body: some View {
        VStack(alignment: .leading, spacing: theme.spacing.twoUnits) {
            ShowcaseSection("Composer") {
                ChatComposer(
                    text: $draft,
                    prompt: prompt,
                    isEnabled: isEnabled,
                    lineLimit: 1...maximumLines,
                    voiceInput: showsVoiceInput
                        ? ChatComposerVoiceInput(
                            state: voiceMode.state(level: level),
                            onStart: startDictation,
                            onStop: stopDictation
                        ) : nil,
                    onSend: send
                )
            }

            ShowcaseSection("Sent") {
                ChatComposerSentLog(messages: sentMessages)
            }

            ShowcaseSection("Controls") {
                VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
                    TextField("Prompt", text: $prompt)
                        .textFieldStyle(.roundedBorder)
                    Toggle("Enabled", isOn: $isEnabled)
                        .toggleStyle(ThemeToggleStyle())
                    Stepper("Max lines: \(maximumLines)", value: $maximumLines, in: 1...8)
                    Toggle("Voice input", isOn: $showsVoiceInput)
                        .toggleStyle(ThemeToggleStyle())
                    if showsVoiceInput {
                        Picker("Voice state", selection: $voiceMode) {
                            ForEach(VoiceMode.allCases) { mode in
                                Text(mode.rawValue).tag(mode)
                            }
                        }
                        .pickerStyle(.segmented)
                        if voiceMode == .listening {
                            Slider(value: $level, in: 0...1) {
                                Text("Level")
                            }
                        }
                    }
                }
            }
        }
        .onDisappear { dictation?.cancel() }
    }

    private func send() {
        sentMessages.append(draft)
        draft = ""
    }

    /// Streams a canned transcript word by word with a random level, the way a recognizer would.
    private func startDictation() {
        draft = ""
        voiceMode = .listening
        dictation = Task {
            for word in ["This", "message", "was", "dictated", "into", "the", "composer"] {
                try? await Task.sleep(for: .milliseconds(350))
                guard !Task.isCancelled else { return }
                level = Double.random(in: 0.3...1)
                draft = draft.isEmpty ? word : draft + " " + word
            }
            stopDictation()
        }
    }

    private func stopDictation() {
        dictation?.cancel()
        voiceMode = .processing
        Task {
            try? await Task.sleep(for: .milliseconds(600))
            voiceMode = .idle
        }
    }
}

/// The voice states selectable in the showcase controls.
private enum VoiceMode: String, CaseIterable, Identifiable {
    case idle = "Idle"
    case listening = "Listening"
    case processing = "Processing"
    case unavailable = "Unavailable"

    var id: String { rawValue }

    func state(level: Double) -> ChatComposerVoiceState {
        switch self {
        case .idle: .idle
        case .listening: .listening(level: level)
        case .processing: .processing
        case .unavailable: .unavailable
        }
    }
}

/// Messages sent from the showcase composer, newest last.
private struct ChatComposerSentLog: View {
    let messages: [String]
    @Environment(\.designTheme) private var theme

    var body: some View {
        if messages.isEmpty {
            Text("Nothing sent yet")
                .font(theme.typography.footnote)
                .foregroundStyle(theme.colors.textSecondary)
        } else {
            VStack(alignment: .trailing, spacing: theme.spacing.oneUnit) {
                ForEach(Array(messages.enumerated()), id: \.offset) { _, message in
                    ChatBubbleView(role: .user, content: message)
                }
            }
        }
    }
}

#Preview {
    ScrollView {
        ChatComposerDetailView()
            .padding()
    }
}
