/// Controls the vertical density (height) of a ``SegmentedPicker``.
public enum SegmentDensity: Sendable, Hashable, CaseIterable {
    /// Standard height with a 44pt minimum tap target (default).
    case regular
    /// Reduced height (~32pt), matching the platform's native segmented control.
    /// The tap target shrinks with the control, so prefer ``regular`` where a
    /// generous tap area matters.
    case compact
}
