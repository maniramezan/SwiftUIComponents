import SwiftUI
import TestCommonsUI

/// Renders a view in a real hierarchy, with explicit cleanup after the layout pass.
@MainActor
func renderForCoverage<V: View>(_ view: V, size: CGSize = CGSize(width: 320, height: 200)) {
    let hosted = HostedView(view, size: size)
    defer { hosted.close() }
    _ = hosted.renderPNG()
    RunLoop.current.run(until: Date())
}
