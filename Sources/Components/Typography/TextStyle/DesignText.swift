import DesignSystem
import SwiftUI

/// A `Text` that takes its font from a ``TypographySlot`` on the active theme.
///
/// `DesignText` is the call-site-safe way to render a string in a themed font without
/// naming a raw `Font`: choose the ``TypographySlot`` that matches the content's role and
/// the concrete `Font` is resolved from `@Environment(\.designTheme)`'s `Typography`.
/// Foreground colour, line limits, and every other text modifier compose on top exactly
/// as they would on a plain `Text`.
///
/// ```swift
/// DesignText("Weekly summary", slot: .title3Semibold)
/// DesignText(verbatim: user.handle, slot: .caption)
///     .foregroundStyle(theme.colors.textSecondary)
/// ```
public struct DesignText: View {
    /// Backing content for the rendered `Text`, mirroring `Text`'s own string handling.
    private enum Content {
        /// A key looked up in the caller's bundle.
        case localized(LocalizedStringKey)
        /// A string shown exactly as provided.
        case verbatim(String)
    }

    private let content: Content
    private let slot: TypographySlot
    @Environment(\.designTheme) private var theme

    /// Creates themed text from a localized string key.
    ///
    /// - Parameters:
    ///   - key: The key resolved against the caller's bundle, like `Text(_:)`.
    ///   - slot: The ``TypographySlot`` whose `Typography` font is applied.
    public init(_ key: LocalizedStringKey, slot: TypographySlot) {
        self.content = .localized(key)
        self.slot = slot
    }

    /// Creates themed text from a string rendered verbatim, without localization.
    ///
    /// - Parameters:
    ///   - content: The string shown exactly as provided.
    ///   - slot: The ``TypographySlot`` whose `Typography` font is applied.
    public init(verbatim content: String, slot: TypographySlot) {
        self.content = .verbatim(content)
        self.slot = slot
    }

    /// The `Text` for `content`, before the themed font is applied.
    private var text: Text {
        switch content {
        case .localized(let key): Text(key)
        case .verbatim(let string): Text(verbatim: string)
        }
    }

    /// Renders the text with the font `slot` names on the active theme's `Typography`.
    public var body: some View {
        text.font(slot.font(theme.typography))
    }
}

#Preview("Design Text") {
    PreviewContent { theme in
        VStack(alignment: .leading, spacing: theme.spacing.oneUnit) {
            DesignText("Large title", slot: .largeTitle)
            DesignText("Headline", slot: .headline)
            DesignText("Body copy sets the baseline", slot: .body)
            DesignText("Semibold caption", slot: .captionSemibold)
                .foregroundStyle(theme.colors.textSecondary)
        }
        .padding(theme.spacing.twoUnits)
    }
}
