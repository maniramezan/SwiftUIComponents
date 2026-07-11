import DesignSystem
import SwiftUI

/// An animated three-dot indicator that cycles through emphasizing each dot
/// in turn at a 300 ms cadence.
///
/// Useful inside a chat bubble while an assistant is composing a response, or
/// anywhere a low-key "working on it" affordance is needed. The dots use
/// `theme.colors.textSecondary` at full opacity for the active dot and
/// `theme.motion.disabledOpacity` for the others, animated with
/// `theme.motion.standardAnimation`. When the system **Reduce Motion**
/// preference is enabled, the cycling animation is suppressed and all three
/// dots hold at full opacity.
///
/// ```swift
/// HStack(spacing: theme.spacing.oneUnit) {
///     TypingDotsView()
/// }
/// ```
public struct TypingDotsView: View {

    @State private var animationPhase = 0
    @State private var isVisible = false
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Creates a typing indicator.
    public init() {}

    public var body: some View {
        HStack(spacing: theme.spacing.halfUnit) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.colors.textSecondary)
                    .frame(width: theme.spacing.oneUnit, height: theme.spacing.oneUnit)
                    .opacity(opacity(for: index))
            }
        }
        .onAppear { isVisible = true }
        .onDisappear { isVisible = false }
        .task(id: [isVisible, reduceMotion]) {
            // Under Reduce Motion, hold a static row of dots instead of
            // perpetually cycling emphasis.
            guard isVisible, !reduceMotion else { return }
            while !Task.isCancelled {
                try? await Task.sleep(for: .milliseconds(300))
                guard !Task.isCancelled else { return }
                withAnimation(theme.motion.standardAnimation) {
                    animationPhase = (animationPhase + 1) % 3
                }
            }
        }
        .accessibilityLabel(Text(Strings.Chat.typingIndicator))
    }

    /// Per-dot opacity. While animating, the active dot is emphasized and the
    /// rest are dimmed; under Reduce Motion all dots stay fully opaque so the
    /// indicator is legible without continuous movement.
    private func opacity(for index: Int) -> Double {
        if reduceMotion { return 1.0 }
        return animationPhase == index ? 1.0 : theme.motion.disabledOpacity
    }
}

#Preview("Typing dots") {
    PreviewContent { theme in
        TypingDotsView().padding(theme.spacing.twoUnits)
    }
}
