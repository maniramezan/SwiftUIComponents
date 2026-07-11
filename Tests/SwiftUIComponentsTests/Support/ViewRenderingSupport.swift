import SwiftUI

#if canImport(UIKit)
    import UIKit
#elseif canImport(AppKit)
    import AppKit
#endif

/// Hosts `view` in a real platform view hierarchy and forces layout, so
/// container closures (e.g. `ScrollViewReader`, `GeometryReader`) actually run
/// instead of merely being stored for later. Attaches to an offscreen window
/// so lazy containers (`LazyHStack`/`LazyHGrid`) and draw-time modifiers
/// (`.overlay`, `.background`) fully realize their content, not just layout.
///
/// Shared across test files so each doesn't need to redefine its own copy.
@MainActor
func renderForCoverage<V: View>(_ view: V, size: CGSize = CGSize(width: 320, height: 200)) {
    #if canImport(UIKit)
        let hostingController = UIHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        let window = UIWindow(frame: hostingController.view.frame)
        window.rootViewController = hostingController
        window.isHidden = false
        window.makeKeyAndVisible()
        hostingController.view.setNeedsLayout()
        hostingController.view.layoutIfNeeded()
        RunLoop.current.run(until: Date())
    #elseif canImport(AppKit)
        let hostingController = NSHostingController(rootView: view)
        hostingController.view.frame = CGRect(origin: .zero, size: size)
        let window = NSWindow(
            contentRect: hostingController.view.frame,
            styleMask: [.borderless],
            backing: .buffered,
            defer: false
        )
        window.contentViewController = hostingController
        window.orderFront(nil)
        hostingController.view.needsLayout = true
        hostingController.view.layoutSubtreeIfNeeded()
        hostingController.view.displayIfNeeded()
        RunLoop.current.run(until: Date())
    #else
        _ = view
    #endif
}
