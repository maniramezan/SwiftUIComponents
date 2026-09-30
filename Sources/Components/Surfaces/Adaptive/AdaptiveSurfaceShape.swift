import SwiftUI

/// The outline used by both glass and material versions of an adaptive surface.
public enum AdaptiveSurfaceShape: String, CaseIterable, Hashable, Sendable {
    /// A rounded rectangle using the surface's corner radius or the active theme default.
    case roundedRectangle
    /// A circular outline inscribed in the content bounds.
    case circle
    /// A capsule outline following the content bounds.
    case capsule

    nonisolated func resolved(cornerRadius: CGFloat) -> AnyShape {
        switch self {
        case .roundedRectangle:
            AnyShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
        case .circle:
            AnyShape(Circle())
        case .capsule:
            AnyShape(Capsule())
        }
    }
}
