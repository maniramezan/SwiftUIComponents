import SwiftUI

/// Default Dynamic Type-aware typography tokens.
public struct DefaultDesignTypography: DesignTypography {
    private let fontFamily: String?

    /// Creates typography tokens.
    /// - Parameter fontFamily: Optional custom font family name used for text styles.
    public init(fontFamily: String? = nil) {
        self.fontFamily = fontFamily
    }

    @MainActor public var largeTitle: Font { font(.largeTitle, size: 34) }
    @MainActor public var title: Font { font(.title, size: 28) }
    @MainActor public var title2: Font { font(.title2, size: 22) }
    @MainActor public var title3: Font { font(.title3, size: 20) }
    @MainActor public var headline: Font { font(.headline, size: 17).weight(.semibold) }
    @MainActor public var body: Font { font(.body, size: 17) }
    @MainActor public var callout: Font { font(.callout, size: 16) }
    @MainActor public var subheadline: Font { font(.subheadline, size: 15) }
    @MainActor public var footnote: Font { font(.footnote, size: 13) }
    @MainActor public var caption: Font { font(.caption, size: 12) }
    @MainActor public var caption2: Font { font(.caption2, size: 11) }
    @MainActor public var button: Font { font(.body, size: 17).weight(.semibold) }
    @MainActor public var control: Font { font(.body, size: 17).weight(.medium) }
    @MainActor public var badge: Font { font(.caption, size: 12).weight(.semibold) }
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
