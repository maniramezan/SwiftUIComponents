/// Controls how a ``SegmentedPicker`` sizes its segments along the horizontal axis.
public enum SegmentSizing: Sendable, Hashable, CaseIterable {
    /// Each segment sizes to fit its content (default).
    case fit
    /// All segments expand to an equal width, together filling the available space.
    case fillEqually
    /// Segments fill the available width while remaining proportional to their intrinsic content sizes.
    ///
    /// Each segment's ideal width is scaled by the same factor, so a long title keeps
    /// proportionally more room than a short one. When the segments don't fit, the picker
    /// falls back to its scrolling layout at their ideal widths.
    case fillProportionally
}
