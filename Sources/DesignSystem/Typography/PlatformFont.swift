import SwiftUI

#if canImport(UIKit)
    import UIKit

    public extension Typography {
        /// Dynamic Type-aware platform font for bridged UIKit controls using the design control role.
        @MainActor var controlUIFont: UIFont {
            let base = UIFont.systemFont(ofSize: UIFont.labelFontSize, weight: .medium)
            return UIFontMetrics(forTextStyle: .body).scaledFont(for: base)
        }
    }
#endif

#if canImport(AppKit)
    import AppKit

    public extension Typography {
        /// Platform font for bridged AppKit controls using the design control role.
        @MainActor var controlNSFont: NSFont {
            NSFont.systemFont(ofSize: NSFont.systemFontSize, weight: .medium)
        }
    }
#endif
