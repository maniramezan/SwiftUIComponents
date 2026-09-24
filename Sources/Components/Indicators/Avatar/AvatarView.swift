import DesignSystem
import SwiftUI

/// A circular avatar that shows a caller-supplied image, or the initials of a name
/// when no image is available.
///
/// Sizes and colors come from the active theme: the monogram sits on the theme's
/// `interactiveSubtle` wash in `primary`, and the circle carries a hairline border.
/// When `name` has no letters to take initials from, a generic person symbol is shown.
///
/// ```swift
/// AvatarView(name: "Ada Lovelace")                        // "AL" monogram
/// AvatarView(name: member.displayName, image: photo, size: .large)
/// ```
///
/// For a remote photo, compose with ``CachedAsyncImage`` and fall back to the monogram
/// while it loads:
///
/// ```swift
/// CachedAsyncImage(url: member.photoURL) { image in
///     AvatarView(name: member.displayName, image: image)
/// } placeholder: {
///     AvatarView(name: member.displayName)
/// }
/// ```
///
/// VoiceOver reads the avatar as a single image labelled with `name`.
public struct AvatarView: View {

    /// The rendered diameter of an ``AvatarView``, resolved from the theme's spacing scale.
    public enum Size: Sendable, Hashable, CaseIterable {
        /// `theme.spacing.fourUnits` (32 pt by default), for dense lists and inline mentions.
        case small
        /// `theme.spacing.fiveUnits` (40 pt by default), for standard list rows.
        case medium
        /// `theme.spacing.sixUnits` (48 pt by default), for headers and profile summaries.
        case large
    }

    private let name: String
    private let image: Image?
    private let size: Size
    @Environment(\.designTheme) private var theme

    /// Creates an avatar.
    ///
    /// - Parameters:
    ///   - name: The person's or entity's name. Used for the initials fallback and as the
    ///     VoiceOver label; pass an already-localized value.
    ///   - image: An optional image to show instead of initials. It is scaled to fill the
    ///     circle.
    ///   - size: The avatar's diameter. Defaults to ``Size/medium``.
    public init(name: String, image: Image? = nil, size: Size = .medium) {
        self.name = name
        self.image = image
        self.size = size
    }

    /// The circular avatar.
    public var body: some View {
        let side = diameter(for: size)
        AvatarContent(name: name, image: image, size: size)
            .frame(width: side, height: side)
            .background(theme.colors.interactiveSubtle)
            .clipShape(Circle())
            .overlay {
                Circle().strokeBorder(theme.colors.border, lineWidth: theme.stroke.hairline)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text(name))
            .accessibilityAddTraits(.isImage)
    }

    private func diameter(for size: Size) -> CGFloat {
        switch size {
        case .small: theme.spacing.fourUnits
        case .medium: theme.spacing.fiveUnits
        case .large: theme.spacing.sixUnits
        }
    }
}

// MARK: - Initials

extension AvatarView {
    /// Up to two uppercase initials for `name`: the first letter of its first word and,
    /// when there is more than one word, of its last word.
    ///
    /// Words are split on whitespace and punctuation, and words that don't start with a
    /// letter (emoji, digits) are skipped. Returns an empty string when no word qualifies.
    ///
    /// - Parameter name: The display name.
    /// - Returns: Zero, one, or two uppercase characters.
    nonisolated static func initials(from name: String) -> String {
        let words =
            name
            .components(separatedBy: CharacterSet.whitespacesAndNewlines.union(.punctuationCharacters))
            .compactMap(\.first)
            .filter(\.isLetter)
        guard let first = words.first else { return "" }
        guard words.count > 1, let last = words.last else { return String(first).uppercased() }
        return (String(first) + String(last)).uppercased()
    }
}

// MARK: - Content

/// The image, monogram, or placeholder symbol drawn inside an ``AvatarView``.
private struct AvatarContent: View {
    let name: String
    let image: Image?
    let size: AvatarView.Size

    @Environment(\.designTheme) private var theme

    var body: some View {
        let initials = AvatarView.initials(from: name)
        if let image {
            image
                .resizable()
                .scaledToFill()
        } else if initials.isEmpty {
            Image(systemName: "person.fill")
                .font(font)
                .foregroundStyle(theme.colors.primary)
        } else {
            Text(verbatim: initials)
                .font(font)
                .foregroundStyle(theme.colors.primary)
                .lineLimit(1)
                .minimumScaleFactor(0.5)
        }
    }

    private var font: Font {
        switch size {
        case .small: theme.typography.captionSemibold
        case .medium: theme.typography.subheadlineSemibold
        case .large: theme.typography.headline
        }
    }
}

#Preview("Avatar") {
    PreviewContent { theme in
        HStack(spacing: theme.spacing.oneAndHalfUnits) {
            AvatarView(name: "Ada Lovelace", size: .small)
            AvatarView(name: "Grace Hopper")
            AvatarView(name: "Alan Turing", size: .large)
            AvatarView(name: "", size: .large)
            AvatarView(name: "Landscape", image: Image(systemName: "photo"), size: .large)
        }
        .padding(theme.spacing.twoUnits)
    }
}
