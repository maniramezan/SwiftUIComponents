import DesignSystem
import SwiftUI

/// A persistent disclaimer footer pinned under an assistant feature's
/// quick-action bar, e.g. "AI can make mistakes. Verify important
/// information."
///
/// The caller resolves its own localized copy; this component owns no
/// copy of its own.
///
/// ```swift
/// AssistantDisclaimerFooter(
///     text: "AI responses can be inaccurate. Always double-check important information."
/// )
/// ```
public struct AssistantDisclaimerFooter: View {
    private let text: String

    /// Creates a disclaimer footer.
    ///
    /// - Parameter text: The localized disclaimer copy to display.
    public init(text: String) {
        self.text = text
    }

    @Environment(\.designTheme) private var theme

    public var body: some View {
        VStack(spacing: 0) {
            Divider()
            Text(text)
                .font(theme.typography.caption)
                .foregroundStyle(theme.colors.textSecondary)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(theme.spacing.oneAndHalfUnits)
        }
        .background(theme.colors.background)
    }
}

#Preview("Assistant disclaimer footer") {
    PreviewContent { _ in
        AssistantDisclaimerFooter(
            text: "AI responses can be inaccurate. Always double-check important information."
        )
    }
}
