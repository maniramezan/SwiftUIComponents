import DesignSystem
import SwiftUI

/// Arranges identifiable SwiftUI views around a customizable center.
///
/// The spatial style projects items onto a tilting orbit, placing its far side behind the center.
/// Satellite content remains upright and retains its buttons, gestures, and accessibility. Choose
/// a stationary ring for controls; reserve continuous spatial motion for decorative experiences.
/// Reduce Motion, VoiceOver, and an inactive scene automatically pause continuous motion.
/// Adding or removing items scales and fades satellites while survivors follow the orbit to
/// their new spacing. Reduce Motion uses fades without animated redistribution.
/// Configure placement and motion with `sphereOrbitConfiguration(_:)` and `sphereOrbitMotion(_:)`.
/// The canvas accepts its parent's size proposal; `frame` controls its size. Without a finite
/// proposal, its ideal square side is `theme.spacing.sixUnits * 6`.
///
/// ```swift
/// OrbitingSphere(items) {
///     SphereView { Image(systemName: "plus") }
/// } satellite: { item in
///     SphereView(diameter: 48) { Text(item.label) }
/// }
/// .sphereOrbitStyle(.ring)
/// .sphereOrbitPaused()
/// ```
public struct OrbitingSphere<Item: Identifiable, Center: View, Satellite: View>: View {
    private let items: [SphereOrbitSatelliteItem<Item>]
    private let itemIDs: [Item.ID]
    private let center: Center
    private let satellite: (Item) -> Satellite
    @Environment(\.designTheme) private var theme
    @Environment(\.sphereOrbitConfiguration) private var configuration
    @Environment(\.sphereOrbitMotion) private var motion
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
    @Environment(\.accessibilityVoiceOverEnabled) private var voiceOverEnabled
    @Environment(\.scenePhase) private var scenePhase
    @State private var elapsed: TimeInterval = 0
    @State private var animationStartedAt: Date?

    /// Creates an orbit from caller-owned models and content.
    ///
    /// Apply configuration with the `sphereOrbit` modifiers and size the canvas with `frame`.
    /// Content is not clipped; size the center and satellites to fit the chosen radius.
    ///
    /// - Parameters:
    ///   - items: Unique identifiable items. Empty input displays only the center; duplicate IDs log a fault and are ignored.
    ///   - center: Custom center content, typically a ``SphereView`` or a button containing one.
    ///   - satellite: Custom content for each item. Caller supplies localized text and labels.
    public init(
        _ items: [Item],
        @ViewBuilder center: () -> Center,
        @ViewBuilder satellite: @escaping (Item) -> Satellite
    ) {
        let uniqueItems = SphereOrbitGeometry.uniqueItems(items)
        self.items = uniqueItems.enumerated().map { index, item in
            SphereOrbitSatelliteItem(item: item, position: Double(index) / Double(uniqueItems.count))
        }
        self.itemIDs = uniqueItems.map(\.id)
        self.center = center()
        self.satellite = satellite
    }

    /// The center and orbiting child views, with motion resolved from the environment.
    public var body: some View {
        let phase = SphereOrbitGeometry.phase(configuration.phase.radians)
        let duration = SphereOrbitGeometry.positive(
            motion.revolutionDuration, fallback: theme.motion.orbitalRevolutionDuration)
        let moving = SphereOrbitGeometry.shouldAnimate(
            requested: !motion.isPaused, reduceMotion: reduceMotion, voiceOver: voiceOverEnabled,
            sceneActive: scenePhase == .active, hasItems: !items.isEmpty
        )
        SphereOrbitCanvasLayout(idealSide: theme.spacing.sixUnits * 6) {
            GeometryReader { geometry in
                let side = min(geometry.size.width, geometry.size.height)
                let orbitRadius = SphereOrbitGeometry.positive(
                    configuration.radius,
                    fallback: side
                        * (configuration.style == .ring
                            ? SphereOrbitGeometry.ringRadiusRatio : SphereOrbitGeometry.spatialRadiusRatio)
                )
                TimelineView(.animation(paused: !moving)) { context in
                    let currentElapsed = elapsed + (animationStartedAt.map { context.date.timeIntervalSince($0) } ?? 0)
                    let turns = SphereOrbitGeometry.turns(elapsed: currentElapsed, duration: duration)
                    let orientation = SphereOrbitGeometry.orientation(
                        elapsed: currentElapsed, revolutionDuration: duration, pitch: motion.pitch, roll: motion.roll
                    )
                    SphereOrbitFrame(
                        items: items, itemIDs: itemIDs, style: configuration.style, side: side,
                        radius: orbitRadius, turns: turns, orientation: orientation,
                        phase: phase,
                        showsOrbit: configuration.showsOrbit, animatesChanges: motion.animatesChanges,
                        center: center, satellite: satellite
                    )
                    .frame(width: geometry.size.width, height: geometry.size.height)
                }
            }
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
    let items: [SphereOrbitSatelliteItem<Item>]
    let itemIDs: [Item.ID]
    let style: SphereOrbitStyle
    let side: CGFloat
    let radius: CGFloat
    let turns: Double
    let orientation: SphereOrbitGeometry.Orientation
    let phase: Double
    let showsOrbit: Bool
    let animatesChanges: Bool
    let center: Center
    let satellite: (Item) -> Satellite
    @Environment(\.designTheme) private var theme
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        ZStack {
            if showsOrbit {
                SphereOrbitPath(style: style, radius: radius, orientation: orientation)
                    .stroke(theme.colors.border, lineWidth: theme.stroke.hairline)
                    .accessibilityHidden(true)
                    .allowsHitTesting(false)
            }
            center.zIndex(0)
            ForEach(items) { entry in
                satellite(entry.item)
                    .transition(reduceMotion ? .opacity : .scale(scale: 0).combined(with: .opacity))
                    .modifier(
                        SphereOrbitPlacement(
                            position: entry.position, turns: turns, phase: phase,
                            radius: radius, style: style, orientation: orientation
                        )
                    )
                    .animation(
                        animatesChanges && !reduceMotion ? theme.motion.animation(reducingMotion: reduceMotion) : nil,
                        value: entry.position
                    )
            }
            .animation(
                animatesChanges ? theme.motion.animation(reducingMotion: reduceMotion) : nil,
                value: itemIDs
            )
        }
        .frame(width: side, height: side)
    }
}

private struct SphereOrbitSatelliteItem<Item: Identifiable>: Identifiable {
    let item: Item
    let position: Double
    var id: Item.ID { item.id }
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
