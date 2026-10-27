/// The projection used by an ``OrbitingSphere``.
public enum SphereOrbitStyle: Sendable, Hashable, CaseIterable {
    /// A flat circle with upright items of equal size, suitable for interactive controls.
    case ring
    /// A slowly tilting orbit with perspective scaling and front/back occlusion.
    case spatial
}
