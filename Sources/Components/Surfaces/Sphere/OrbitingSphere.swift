import DesignSystem
import SwiftUI

/// Arranges identifiable SwiftUI views around a customizable center.
///
/// The spatial style projects items onto a tilting orbit, placing its far side behind the center.
/// Satellite content remains upright and retains its buttons, gestures, and accessibility. Choose
/// a stationary ring for controls; reserve continuous spatial motion for decorative experiences.
/// Reduce Motion, VoiceOver, and an inactive scene automatically pause continuous motion.
///
/// ```swift
/// OrbitingSphere(items, style: .ring, isAnimating: false) {
///     SphereView { Image(systemName: "plus") }
/// } satellite: { item in
///     SphereView(diameter: 48) { Text(item.label) }
/// }
/// ```
public struct OrbitingSphere<Item: Identifiable, Center: View, Satellite: View>: View {
    private let items: [Item]
    private let style: SphereOrbitStyle
    private let size: CGFloat?
    private let radius: CGFloat?
    private let isAnimating: Bool
    private let revolutionDuration: TimeInterval?
    private let pitch: SphereOrbitTilt
    private let roll: SphereOrbitTilt
    private let phase: Angle
    private let showsOrbit: Bool
    private let center: Center
    private let satellite: (Item) -> Satellite
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.scenePhase) private var scenePhase
    @State private var elapsed: TimeInterval = 0
    @State private var animationStartedAt: Date?

    /// Creates an orbit with stable item identities.
    ///
    /// - Parameters:
    ///   - items: Unique identifiable items. Empty input displays only the center; duplicate IDs log a fault and are ignored.
    ///   - style: Flat ring or spatial projection. Defaults to `.spatial`.
    ///   - size: Square canvas side. `nil` uses `theme.spacing.sixUnits * 6`.
    ///   - radius: Orbit radius. `nil` uses 38% of the canvas for a ring or 30% for a spatial orbit.
    ///     Invalid size/radius values log a fault and use their defaults. Content is not clipped;
    ///     size your center and satellites to fit the chosen radius.
    ///   - isAnimating: Whether items revolve continuously. Pause this while users interact.
    ///   - revolutionDuration: Seconds per turn. `nil` uses `theme.motion.orbitalRevolutionDuration`.
    ///     Invalid values log a fault and use that token.
    ///   - pitch: Spatial up/down tilt range and timing. Defaults to ``SphereOrbitTilt/defaultPitch``.
    ///     Ignored for `.ring`.
    ///   - roll: Spatial in-plane tilt range and timing. Defaults to ``SphereOrbitTilt/defaultRoll``.
    ///     Ignored for `.ring`. Both tilts share the orbit's pause and accessibility behavior.
    ///   - phase: Starting item angle, defaulting to the top of the ring.
    ///   - showsOrbit: Whether a decorative orbit guide is visible.
    ///   - center: Custom center content, typically a ``SphereView`` or a button containing one.
    ///   - satellite: Custom content for each item. Caller supplies localized text and labels.
    public init(
        _ items: [Item],
        style: SphereOrbitStyle = .spatial,
        size: CGFloat? = nil,
        radius: CGFloat? = nil,
        isAnimating: Bool = true,
        revolutionDuration: TimeInterval? = nil,
        pitch: SphereOrbitTilt = .defaultPitch,
        roll: SphereOrbitTilt = .defaultRoll,
        phase: Angle = .degrees(-90),
        showsOrbit: Bool = true,
        @ViewBuilder center: () -> Center,
        @ViewBuilder satellite: @escaping (Item) -> Satellite
    ) {
        self.items = SphereOrbitGeometry.uniqueItems(items)
        self.style = style
        self.size = size
        self.radius = radius
        self.isAnimating = isAnimating
        self.revolutionDuration = revolutionDuration
        self.pitch = pitch
        self.roll = roll
        self.phase = phase
        self.showsOrbit = showsOrbit
        self.center = center()
        self.satellite = satellite
    }

    /// The center and orbiting child views, with motion resolved from the environment.
    public var body: some View {
        let side = SphereOrbitGeometry.positive(size, fallback: theme.spacing.sixUnits * 6)
        let orbitRadius = SphereOrbitGeometry.positive(
            radius,
            fallback: side
                * (style == .ring ? SphereOrbitGeometry.ringRadiusRatio : SphereOrbitGeometry.spatialRadiusRatio)
        )
        let duration = SphereOrbitGeometry.positive(
            revolutionDuration, fallback: theme.motion.orbitalRevolutionDuration)
        let moving = SphereOrbitGeometry.shouldAnimate(
            requested: isAnimating, reduceMotion: reduceMotion, voiceOver: voiceOverEnabled,
            sceneActive: scenePhase == .active, hasItems: !items.isEmpty
        )
        TimelineView(.animation(paused: !moving)) { context in
            let currentElapsed = elapsed + (animationStartedAt.map { context.date.timeIntervalSince($0) } ?? 0)
            let turns = SphereOrbitGeometry.turns(elapsed: currentElapsed, duration: duration)
            let orientation = SphereOrbitGeometry.orientation(
                elapsed: currentElapsed, revolutionDuration: duration, pitch: pitch, roll: roll
            )
            SphereOrbitFrame(
                items: items, style: style, side: side, radius: orbitRadius, turns: turns,
                orientation: orientation, phase: phase.radians, showsOrbit: showsOrbit,
                center: center, satellite: satellite
            )
        }
        .onChange(of: moving, initial: true) { _, active in
            if active {
                animationStartedAt = .now
            } else if let startedAt = animationStartedAt {
                elapsed += Date.now.timeIntervalSince(startedAt)
                animationStartedAt = nil
            }
        }
    }
}

private struct SphereOrbitFrame<Item: Identifiable, Center: View, Satellite: View>: View {
    let items: [Item]
    let style: SphereOrbitStyle
    let side: CGFloat
    let radius: CGFloat
    let turns: Double
    let orientation: SphereOrbitGeometry.Orientation
    let phase: Double
    let showsOrbit: Bool
    let center: Center
    let satellite: (Item) -> Satellite
    @Environment(\.designTheme) private var theme

    var body: some View {
        ZStack {
            if showsOrbit {
                SphereOrbitPath(style: style, radius: radius, orientation: orientation)
                    .stroke(theme.colors.border, lineWidth: theme.stroke.hairline)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
            center.zIndex(0)
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                let angle = SphereOrbitGeometry.angle(index: index, count: items.count, turns: turns, phase: phase)
                let placement = SphereOrbitGeometry.placement(
                    angle: angle, radius: radius, style: style, orientation: orientation
                )
                satellite(item)
                    .scaleEffect(placement.scale)
                    .offset(x: placement.offset.x, y: placement.offset.y)
                    .zIndex(style == .ring ? 1 : placement.depth)
            }
        }
        .frame(width: side, height: side)
    }
}

private struct SphereOrbitPath: Shape {
    let style: SphereOrbitStyle
    let radius: CGFloat
    let orientation: SphereOrbitGeometry.Orientation

    func path(in rect: CGRect) -> Path {
        var path = Path()
        for sample in 0...SphereOrbitGeometry.pathSamples {
            let angle = Double(sample) / Double(SphereOrbitGeometry.pathSamples) * 2 * .pi
            let placement = SphereOrbitGeometry.placement(
                angle: angle, radius: radius, style: style, orientation: orientation
            )
            let point = CGPoint(x: rect.midX + placement.offset.x, y: rect.midY + placement.offset.y)
            if sample == 0 { path.move(to: point) } else { path.addLine(to: point) }
        }
        path.closeSubpath()
        return path
    }
}

#Preview("Orbiting Sphere") {
    PreviewContent { theme in
        OrbitingSphere([OrbitPreviewItem(id: "A"), OrbitPreviewItem(id: "B"), OrbitPreviewItem(id: "C")]) {
            SphereView { Image(systemName: "sparkle").foregroundStyle(theme.colors.onPrimary) }
        } satellite: { item in
            SphereView(diameter: theme.spacing.sixUnits) { Text(item.id).foregroundStyle(theme.colors.onPrimary) }
        }
    }
}

private struct OrbitPreviewItem: Identifiable {
    let id: String
}
