/// Controls how a ``CarouselRow`` settles after the user lifts their finger.
public enum CarouselSnapping: Equatable, Sendable {
    /// Snaps the nearest item's leading edge into place, preserving the peek of
    /// the following item. This is the App-Store-style browse feel and the
    /// default.
    case viewAligned
    /// Applies no snapping — the row glides to a free momentum stop.
    case free
}
