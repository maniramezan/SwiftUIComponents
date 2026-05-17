import DesignSystem
import SwiftUI

/// An animated three-dot indicator that cycles through emphasizing each dot
/// in turn at a 300 ms cadence.
///
/// Useful inside a chat bubble while an assistant is composing a response, or
/// anywhere a low-key "working on it" affordance is needed. The dots use
/// `theme.colors.textSecondary` at full opacity for the active dot and
/// `theme.motion.disabledOpacity` for the others, animated with
/// `theme.motion.standardAnimation`.
///
/// ```swift
/// HStack(spacing: theme.spacing.oneUnit) {
///     TypingDotsView()
/// }
/// ```
public struct TypingDotsView: View {

    @State private var animationPhase = 0
    @Environment(\.designTheme) private var theme

    private let timer = Timer.publish(every: 0.3, on: .main, in: .common).autoconnect()
    private static let dotSize: CGFloat = 8

    /// Creates a typing indicator.
    public init() {}

    public var body: some View {
        HStack(spacing: theme.spacing.halfUnit) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(theme.colors.textSecondary)
                    .frame(width: Self.dotSize, height: Self.dotSize)
                    .opacity(animationPhase == index ? 1.0 : theme.motion.disabledOpacity)
            }
        }
        .onReceive(timer) { _ in
            withAnimation(theme.motion.standardAnimation) {
                animationPhase = (animationPhase + 1) % 3
            }
        }
        .accessibilityLabel("Typing")
    }
}

#Preview("Typing dots") {
    PreviewContent { theme in
        TypingDotsView().padding(theme.spacing.twoUnits)
    }
}
