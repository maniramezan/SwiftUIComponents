import SwiftUI

#if canImport(UIKit)
    import UIKit

    extension DefaultTypography {
        /// The themed native control font, scaled using the body text style.
        @MainActor public var controlUIFont: UIFont {
            let base =
                fontFamily.flatMap { UIFont(name: $0, size: UIFont.labelFontSize) }
                ?? UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .medium)
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: base)
        }
    }
#elseif canImport(AppKit)
    import AppKit

    extension DefaultTypography {
        /// The themed native control font used by AppKit picker triggers.
        @MainActor public var controlNSFont: NSFont {
            fontFamily.flatMap { NSFont(name: $0, size: NSFont.systemFontSize) }
                ?? NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        }
    }
#endif
