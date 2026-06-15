import SwiftUI

/// The axis a ``FlipCard`` rotates around when flipping between its faces.
public enum FlipAxis: Sendable, Hashable {
    /// Flips around the vertical axis — the faces sweep left and right, like turning a page.
    case horizontal
    /// Flips around the horizontal axis — the faces sweep top and bottom, like a desk calendar.
    case vertical
}
