import SwiftUI

/// Default Dynamic Type-aware typography tokens.
public struct DefaultDesignTypography: DesignTypography {
    private let fontFamily: String?

    /// Creates typography tokens.
    /// - Parameter fontFamily: Optional custom font family name used for text styles.
    public init(fontFamily: String? = nil) {
        self.fontFamily = fontFamily
    }

    /// Large title font at 34pt, mapped to the `.largeTitle` text style.
    @MainActor public var largeTitle: Font { font(.largeTitle, size: 34) }
    /// Title font at 28pt, mapped to the `.title` text style.
    @MainActor public var title: Font { font(.title, size: 28) }
    /// Secondary title font at 22pt, mapped to the `.title2` text style.
    @MainActor public var title2: Font { font(.title2, size: 22) }
    /// Tertiary title font at 20pt, mapped to the `.title3` text style.
    @MainActor public var title3: Font { font(.title3, size: 20) }
    /// Semibold headline font at 17pt, mapped to the `.headline` text style.
    @MainActor public var headline: Font { font(.headline, size: 17).weight(.semibold) }
    /// Body font at 17pt, mapped to the `.body` text style.
    @MainActor public var body: Font { font(.body, size: 17) }
    /// Callout font at 16pt, mapped to the `.callout` text style.
    @MainActor public var callout: Font { font(.callout, size: 16) }
    /// Subheadline font at 15pt, mapped to the `.subheadline` text style.
    @MainActor public var subheadline: Font { font(.subheadline, size: 15) }
    /// Footnote font at 13pt, mapped to the `.footnote` text style.
    @MainActor public var footnote: Font { font(.footnote, size: 13) }
    /// Caption font at 12pt, mapped to the `.caption` text style.
    @MainActor public var caption: Font { font(.caption, size: 12) }
    /// Secondary caption font at 11pt, mapped to the `.caption2` text style.
    @MainActor public var caption2: Font { font(.caption2, size: 11) }
    /// Semibold button label font at 17pt, mapped to the `.body` text style.
    @MainActor public var button: Font { font(.body, size: 17).weight(.semibold) }
    /// Medium-weight control font at 17pt, mapped to the `.body` text style.
    @MainActor public var control: Font { font(.body, size: 17).weight(.medium) }
    /// Semibold badge font at 12pt, mapped to the `.caption` text style.
    @MainActor public var badge: Font { font(.caption, size: 12).weight(.semibold) }
    /// Field input font at 17pt, mapped to the `.body` text style.
    @MainActor public var field: Font { font(.body, size: 17) }

    @MainActor
    private func font(_ textStyle: Font.TextStyle, size: CGFloat) -> Font {
        if let fontFamily {
            .custom(fontFamily, size: size, relativeTo: textStyle)
        } else {
            .system(textStyle)
        }
    }
}
